import 'dart:async';

import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../remote/turso_client.dart';

/// Writes transactions locally first and schedules cloud replication.
class TransactionRepository {
  TransactionRepository({
    required this.database,
    required this.tursoClient,
    this.onSyncError,
  });

  final AppDatabase database;
  final TursoClient tursoClient;

  /// Receives background sync failures; pending rows remain available to retry.
  final void Function(Object error, StackTrace stackTrace)? onSyncError;

  /// Atomically creates a transaction and adjusts its account balance.
  ///
  /// The returned future covers only the local commit. Sync is intentionally
  /// detached so poor connectivity cannot block the user's write.
  Future<void> createTransaction({
    required String accountId,
    required String categoryId,
    required int amountCents,
    required String description,
    required DateTime date,
    String? receiptUrl,
    required String id,
  }) async {
    final userId = tursoClient.authService.currentUserId;
    await database.transaction(() async {
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              userId: userId,
              accountId: accountId,
              categoryId: categoryId,
              amountCents: amountCents,
              description: description,
              date: date.toUtc().toIso8601String(),
              receiptUrl: receiptUrl ?? '',
              isSynced: const Value(false),
            ),
          );
      await (database.update(database.accounts)
            ..where((account) => account.id.equals(accountId))
            ..where((account) => account.userId.equals(userId)))
          .write(
            AccountsCompanion.custom(
              balanceCents:
                  database.accounts.balanceCents + Constant(amountCents),
              isSynced: const Constant(false),
            ),
          );
    });

    unawaited(_syncInBackground());
  }

  Future<void> _syncInBackground() async {
    try {
      await tursoClient.pushLocalChanges();
    } catch (error, stackTrace) {
      onSyncError?.call(error, stackTrace);
    }
  }
}
