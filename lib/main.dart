import 'package:flutter/material.dart';

import 'screens/world/world_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SaveEarthApp());
}

class SaveEarthApp extends StatelessWidget {
  const SaveEarthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const WorldScreen(),
    );
  }
}
