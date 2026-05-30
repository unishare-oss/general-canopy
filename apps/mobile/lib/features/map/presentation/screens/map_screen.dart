import 'package:flutter/material.dart';
import 'package:canopy/core/router/shell_scaffold.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const TabPlaceholder(title: 'Map', subtitle: 'Saplings near you');
}
