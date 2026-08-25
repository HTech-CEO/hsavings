import 'package:flutter/material.dart';

import 'src/config/environment.dart';
import 'src/services/auth_service.dart';
import 'src/app.dart';

export 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize(
    supabaseUrl: Environment.supabaseUrl,
    supabasePublishableKey: Environment.supabasePublishableKey,
  );
  runApp(const HSavingsApp());
}
