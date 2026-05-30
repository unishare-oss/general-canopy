import 'package:flutter/material.dart';
import 'package:canopy/core/router/shell_scaffold.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});
  @override
  Widget build(BuildContext context) => const TabPlaceholder(
        title: 'You',
        subtitle: 'Profile & settings',
      );
}
