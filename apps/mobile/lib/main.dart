import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:canopy/core/firebase/firebase_init.dart';
import 'package:canopy/core/router/router.dart';
import 'package:canopy/shared/theme/providers/font_size_provider.dart';
import 'package:canopy/shared/theme/providers/theme_provider.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  await Hive.initFlutter();
  // Persists the theme + font-size preferences. Add feature-specific boxes
  // here as you build them.
  await Hive.openBox('settings');
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(activeThemeProvider);
    final fontStep = ref.watch(fontSizeProvider);
    final textScale = fontSizeScales[fontStep];
    return MaterialApp.router(
      title: 'Canopy',
      theme: theme,
      // Cross-fade ThemeData over 240ms so a theme switch reads as a
      // smooth transition instead of a single-frame layout snap.
      themeAnimationDuration: const Duration(milliseconds: 240),
      themeAnimationCurve: Curves.easeOutCubic,
      routerConfig: router,
      // Apply the app's font-size preference *on top of* the platform's
      // MediaQuery text scale, so OS accessibility scaling and the in-app
      // preference compound instead of one replacing the other.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final platformFactor = mq.textScaler.scale(1.0);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(platformFactor * textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
