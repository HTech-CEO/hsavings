import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Accounts, Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database in the app support directory.
  static Future<AppDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'hsavings.sqlite'));
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => 1;
}