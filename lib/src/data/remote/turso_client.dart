import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;

import '../../config/environment.dart';
import '../local/app_database.dart';
import '../../services/auth_service.dart';

/// Pushes pending local mutations to a Turso/libSQL HTTP database.
///
/// The database URL may be either a Turso `libsql://` URL or an HTTPS URL.
/// The JWT is kept in Dio's authorization header and should be supplied by a
/// secure configuration layer in the application.
class TursoClient {
  /// Creates a client using compile-time Turso configuration.
  factory TursoClient.fromEnvironment({
    required AppDatabase database,
    required AuthService authService,
    Dio? dio,
  }) {
    Environment.validate();
    return TursoClient(
      database: database,
      authService: authService,
      baseUrl: Environment.tursoUrl,
      authToken: Environment.tursoAuthToken,
      dio: dio,
    );
  }

  TursoClient({
    required this.database,
    required this.authService,
    required String baseUrl,
    required String authToken,
    Dio? dio,
  }) : _dio = dio ?? Dio(),
       _pipelineUrl = _pipelineEndpoint(baseUrl) {
    _dio.options.headers['Authorization'] = 'Bearer $authToken';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  final AppDatabase database;
  final AuthService authService;
  final Dio _dio;
  final String _pipelineUrl;

  /// Sends all unsynced rows belonging to the authenticated user as one batch.
  ///
  /// Local flags are changed only after Turso accepts every statement. A
  /// failed request leaves the rows pending for the next retry.
  Future<void> pushLocalChanges() async {
    final userId = authService.currentUserId;
    final pendingAccounts =
        await (database.select(database.accounts)..where(
              (row) => row.userId.equals(userId) & row.isSynced.equals(false),
            ))
            .get();
    final pendingCategories =
        await (database.select(database.categories)..where(
              (row) => row.userId.equals(userId) & row.isSynced.equals(false),
            ))
            .get();
    final pendingTransactions =
        await (database.select(database.transactions)..where(
              (row) => row.userId.equals(userId) & row.isSynced.equals(false),
            ))
            .get();

    final statements = <Map<String, Object?>>[
      ...pendingAccounts.map((row) => _accountStatement(row, userId)),
      ...pendingCategories.map((row) => _categoryStatement(row, userId)),
      ...pendingTransactions.map((row) => _transactionStatement(row, userId)),
    ];
    if (statements.isEmpty) return;

    final requests = [
      {
        'type': 'execute',
        'stmt': {'sql': 'BEGIN'},
      },
      ...statements.map((statement) => {'type': 'execute', 'stmt': statement}),
      {
        'type': 'execute',
        'stmt': {'sql': 'COMMIT'},
      },
      {'type': 'close'},
    ];
    final response = await _dio.post<Map<String, dynamic>>(
      _pipelineUrl,
      data: {'requests': requests},
    );
    _throwForPipelineErrors(response.data);

    await database.transaction(() async {
      for (final row in pendingAccounts) {
        await (database.update(database.accounts)
              ..where((item) => item.id.equals(row.id)))
            .write(const AccountsCompanion(isSynced: drift.Value(true)));
      }
      for (final row in pendingCategories) {
        await (database.update(database.categories)
              ..where((item) => item.id.equals(row.id)))
            .write(const CategoriesCompanion(isSynced: drift.Value(true)));
      }
      for (final row in pendingTransactions) {
        await (database.update(database.transactions)
              ..where((item) => item.id.equals(row.id)))
            .write(const TransactionsCompanion(isSynced: drift.Value(true)));
      }
    });
  }

  Map<String, Object?> _accountStatement(Account row, String userId) => {
    'sql': '''INSERT INTO accounts
          (id, user_id, name, type, balance_cents)
          VALUES (?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET user_id=excluded.user_id,
          name=excluded.name, type=excluded.type,
          balance_cents=excluded.balance_cents
          WHERE accounts.user_id = ?''',
    'args': [
      _text(row.id),
      _text(userId),
      _text(row.name),
      _text(row.type),
      _integer(row.balanceCents),
      _text(userId),
    ],
  };

  Map<String, Object?> _categoryStatement(Category row, String userId) => {
    'sql': '''INSERT INTO categories
          (id, user_id, name, type, color, icon)
          VALUES (?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET user_id=excluded.user_id,
          name=excluded.name, type=excluded.type, color=excluded.color,
          icon=excluded.icon
          WHERE categories.user_id = ?''',
    'args': [
      _text(row.id),
      _text(userId),
      _text(row.name),
      _text(row.type),
      _text(row.color),
      _text(row.icon),
      _text(userId),
    ],
  };

  Map<String, Object?> _transactionStatement(Transaction row, String userId) =>
      {
        'sql': '''INSERT INTO transactions
          (id, user_id, account_id, category_id, amount_cents,
           description, date, receipt_url)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET user_id=excluded.user_id,
          account_id=excluded.account_id, category_id=excluded.category_id,
          amount_cents=excluded.amount_cents, description=excluded.description,
          date=excluded.date, receipt_url=excluded.receipt_url
          WHERE transactions.user_id = ?''',
        'args': [
          _text(row.id),
          _text(userId),
          _text(row.accountId),
          _text(row.categoryId),
          _integer(row.amountCents),
          _text(row.description),
          _text(row.date),
          _text(row.receiptUrl),
          _text(userId),
        ],
      };

  static Map<String, String> _text(String value) => {
    'type': 'text',
    'value': value,
  };
  static Map<String, String> _integer(int value) => {
    'type': 'integer',
    'value': value.toString(),
  };

  static String _pipelineEndpoint(String baseUrl) {
    var normalized = baseUrl.trim();
    if (normalized.startsWith('libsql://')) {
      normalized = 'https://${normalized.substring('libsql://'.length)}';
    }
    normalized = normalized.replaceFirst(RegExp(r'/*$'), '');
    return normalized.endsWith('/v2/pipeline')
        ? normalized
        : '$normalized/v2/pipeline';
  }

  static void _throwForPipelineErrors(Map<String, dynamic>? body) {
    final results = body?['results'];
    if (results is! List) return;
    final errors = results.whereType<Map>().where(
      (result) => result['type'] == 'error',
    );
    if (errors.isNotEmpty) {
      throw StateError('Turso batch failed: ${errors.first['error']}');
    }
  }
}
