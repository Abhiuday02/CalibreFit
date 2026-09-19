import 'package:calibrefit/app/app.dart';
import 'package:calibrefit/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  runApp(const ProviderScope(child: CalibreFitApp()));
}
