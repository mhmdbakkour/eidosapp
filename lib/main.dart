import 'package:csci410project/features/mindmap/view/mindmap_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EidosApp()));
}

class EidosApp extends StatelessWidget {
  const EidosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eidos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MindMapPage(),
    );
  }
}
