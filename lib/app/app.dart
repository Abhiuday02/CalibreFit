import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget.
///
/// Uses [ConsumerWidget] so the router and theme providers are observable.
class CalibreFitApp extends ConsumerWidget {
  const CalibreFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CalibreFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
