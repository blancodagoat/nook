import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/repository_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppTheme.setSystemUIOverlayStyle();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Create repository and seed data before running app
  final container = ProviderContainer();
  final repository = container.read(repositoryProvider);
  await repository.seedData();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LedgerApp(),
    ),
  );
}
