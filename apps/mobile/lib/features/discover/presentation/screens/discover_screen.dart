import 'package:flutter/material.dart';
import 'package:canopy/core/router/shell_scaffold.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) => const TabPlaceholder(
    title: 'Discover',
    subtitle: 'Saplings waiting on your block',
  );
}
