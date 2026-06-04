import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:canopy/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:canopy/features/auth/presentation/screens/welcome_screen.dart';
import 'package:canopy/core/router/shell_scaffold.dart';
import 'package:canopy/features/discover/presentation/screens/discover_screen.dart';
import 'package:canopy/features/discover/presentation/screens/sapling_detail_screen.dart';
import 'package:canopy/features/grove/presentation/screens/grove_screen.dart';
import 'package:canopy/features/map/presentation/screens/map_screen.dart';
import 'package:canopy/features/impact/presentation/screens/impact_screen.dart';
import 'package:canopy/features/you/presentation/screens/you_screen.dart';

part 'router.g.dart';

// ---------------------------------------------------------------------------
// Notifier — watches auth + guest + onboarding state, calls notifyListeners
// on change so GoRouter re-evaluates redirects when the session changes.
// ---------------------------------------------------------------------------

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<Object?>>(
      authStateProvider,
      (prev, next) => notifyListeners(),
    );
    _ref.listen<bool>(guestModeProvider, (prev, next) => notifyListeners());
    _ref.listen<OnboardingState>(
      onboardingProvider,
      (prev, next) => notifyListeners(),
    );
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);
    final isGuest = _ref.read(guestModeProvider);

    // Hold all redirects while Firebase is still restoring the session, so a
    // deep link isn't bounced to /welcome before auth resolves.
    if (!authAsync.hasValue) return null;

    final user = authAsync.value;
    final isAuthenticated = user != null && !user.isAnonymous;
    final currentPath = state.uri.path;
    const authRoutes = {'/welcome', '/onboarding'};

    // Case 1: No session and not a guest → force /welcome, preserving the URL.
    if (!isAuthenticated && !isGuest) {
      if (!authRoutes.contains(currentPath)) {
        return '/welcome?redirect=${Uri.encodeComponent(currentPath)}';
      }
      return null;
    }

    // Case 2: Authenticated but onboarding not complete → /onboarding.
    // Guest users are exempt — they have no Firestore document.
    if (isAuthenticated && user.onboardingComplete == false) {
      return currentPath == '/onboarding' ? null : '/onboarding';
    }

    // Case 3: Authenticated + onboarding complete, sitting on an auth route
    // → honour redirect param or default to /grove.
    if (isAuthenticated && authRoutes.contains(currentPath)) {
      final redirectParam = state.uri.queryParameters['redirect'];
      if (redirectParam != null &&
          redirectParam.startsWith('/') &&
          !redirectParam.contains('://')) {
        return redirectParam;
      }
      return '/grove';
    }

    // Guest on /welcome → /grove.
    if (isGuest && currentPath == '/welcome') return '/grove';

    // Root → /grove.
    if (currentPath == '/') return '/grove';

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
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Top-level route so it can be pushed from any tab (Discover or Map).
      GoRoute(
        path: '/sapling/:id',
        builder: (context, state) =>
            SaplingDetailScreen(saplingId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (c, s) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/grove', builder: (c, s) => const GroveScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/impact', builder: (c, s) => const ImpactScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/you', builder: (c, s) => const YouScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}
