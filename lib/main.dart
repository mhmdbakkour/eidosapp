import 'package:csci410project/features/mindmap/providers/theme_provider.dart';
import 'package:csci410project/features/mindmap/view/mindmap_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'features/mindmap/adapters/connection_adapter.dart';
import 'features/mindmap/adapters/node_adapter.dart';
import 'features/mindmap/adapters/node_group_adapter.dart';
import 'features/mindmap/models/connection_model.dart';
import 'features/mindmap/models/node_group_model.dart';
import 'features/mindmap/models/node_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter(NodeAdapter());
  Hive.registerAdapter(NodeGroupAdapter());
  Hive.registerAdapter(ConnectionAdapter());

  await Hive.openBox<Node>('nodesBox');
  await Hive.openBox<NodeGroup>('nodeGroupsBox');
  await Hive.openBox<Connection>('connectionsBox');

  runApp(const ProviderScope(child: EidosApp()));
}

class EidosApp extends ConsumerWidget {
  const EidosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Eidos',
      theme: ThemeData.light(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const MindMapPage(),
    );
  }
}
