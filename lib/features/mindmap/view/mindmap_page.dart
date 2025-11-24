import 'package:csci410project/features/mindmap/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/mindmap_canvas.dart';

class MindMapPage extends ConsumerStatefulWidget {
  const MindMapPage({super.key});

  @override
  ConsumerState<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends ConsumerState<MindMapPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('assets/Eidos.svg', height: 30, width: 30),
            const SizedBox(width: 10),
            const Text("EIDOS"),
          ],
        ),
        backgroundColor: Color(0xff2e2e2e),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: MindMapCanvas(),
    );
  }
}
