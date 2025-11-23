import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/mindmap_canvas.dart';

class MindMapPage extends StatefulWidget {
  const MindMapPage({super.key});

  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('assets/Eidos.svg', height: 30, width: 30),
            const SizedBox(width: 10),
            const Text("EIDOS"),
          ],
        ),
        backgroundColor: Color(0xff1e1e1e),
        foregroundColor: Colors.white,
      ),
      body: MindMapCanvas(),
    );
  }
}
