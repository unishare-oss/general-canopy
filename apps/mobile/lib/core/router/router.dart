import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/auth/presentation/screens/welcome_screen.dart';
import 'package:canopy/features/home/presentation/screens/home_screen.dart';

part 'router.g.dart';

// ---------------------------------------------------------------------------
// Notifier — watches auth + guest state, calls notifyListeners on change so
// GoRouter re-evaluates redirects when the session changes.
// ---------------------------------------------------------------------------

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<Object?>>(
      authStateProvider,
      (prev, next) => notifyListeners(),
    );
    _ref.listen<bool>(guestModeProvider, (prev, next) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);
    final isGuest = _ref.read(guestModeProvider);

    // Hold all redirects while Firebase is still restoring the session, so a
    // deep link isn't bounced to /welcome before auth resolves.
    if (!authAsync.hasValue) return null;

    final isAuthenticated = authAsync.value != null;
    const authRoutes = {'/welcome'};
    final currentPath = state.uri.path;

    // 1. No session and not a guest → force /welcome, preserving the URL.
    if (!isAuthenticated && !isGuest) {
      if (!authRoutes.contains(currentPath)) {
        final encoded = Uri.encodeComponent(state.uri.toString());
        return '/welcome?redirect=$encoded';
      }
      return null;
    }

    // 2. Authenticated/guest sitting on /welcome → honour redirect or go home.
    if ((isAuthenticated || isGuest) && authRoutes.contains(currentPath)) {
      final redirectParam = state.uri.queryParameters['redirect'];
      if (redirectParam != null && redirectParam.isNotEmpty) {
        final decoded = Uri.decodeComponent(redirectParam);
        // Only follow in-app paths to prevent open-redirect abuse.
        if (decoded.startsWith('/') && !decoded.contains('://')) {
          return decoded;
        }
      }
      return '/home';
    }

    // 3. Root → /home.
    if (currentPath == '/') return '/home';

    return null;
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

@riverpod
GoRouter router(Ref ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
