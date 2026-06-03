import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/domain/entities/auth_exception.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:canopy/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:canopy/shared/theme/app_colors.dart';

enum _AuthMode { signIn, signUp }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

typedef WelcomeScreen = AuthScreen;

class _AuthScreenState extends ConsumerState<AuthScreen> {
  _AuthMode _mode = _AuthMode.signIn;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _consentChecked = false;
  bool _consentError = false;
  bool _isLoading = false;
  bool _googleLoading = false;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      _mode = _mode == _AuthMode.signIn ? _AuthMode.signUp : _AuthMode.signIn;
      _serverError = null;
      _consentChecked = false;
      _consentError = false;
    });
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on StateError {
      // cancelled — silent
    } on AuthException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.userMessage)));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (e) {
      if (mounted) setState(() => _serverError = e.userMessage);
    } catch (_) {
      if (mounted)
        setState(
          () => _serverError = 'Something went wrong. Please try again.',
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _serverError = null;
      _consentError = !_consentChecked;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_consentChecked) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (e) {
      if (mounted) setState(() => _serverError = e.userMessage);
    } catch (e, st) {
      debugPrint('Sign-up error: $e\n$st');
      if (mounted)
        setState(
          () => _serverError = 'Something went wrong. Please try again.',
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSignUp = _mode == _AuthMode.signUp;

    return Scaffold(
      backgroundColor: cs.primary,
      body: Column(
        children: [
          // ── Hero ──────────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.park_rounded,
                      size: 72,
                      color: cs.onPrimary.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Canopy',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Adopt a tree. Keep it alive.\nCool your city.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form card ─────────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: _buildForm(context, isSignUp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isSignUp) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode tabs
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _Tab(
                  label: 'Sign in',
                  selected: !isSignUp,
                  onTap: () {
                    if (isSignUp) _switchMode();
                  },
                ),
                _Tab(
                  label: 'Create account',
                  selected: isSignUp,
                  onTap: () {
                    if (!isSignUp) _switchMode();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Google
          GoogleSignInButton(
            onPressed: _handleGoogleSignIn,
            isLoading: _googleLoading,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: Divider(color: cs.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: ac.mutedForeground),
                ),
              ),
              Expanded(child: Divider(color: cs.outlineVariant)),
            ],
          ),
          const SizedBox(height: 16),

          if (isSignUp) ...[
            AuthTextField(
              key: const ValueKey('name'),
              label: 'Name',
              hint: 'Jane Smith',
              controller: _nameController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2)
                  return 'Name must be at least 2 characters';
                return null;
              },
            ),
            const SizedBox(height: 10),
          ],

          AuthTextField(
            key: const ValueKey('email'),
            label: 'Email',
            hint: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 10),

          AuthTextField(
            key: const ValueKey('password'),
            label: 'Password',
            hint: isSignUp ? 'Min. 8 characters' : 'Your password',
            controller: _passwordController,
            obscureText: true,
            textInputAction: isSignUp
                ? TextInputAction.next
                : TextInputAction.done,
            autofillHints: [
              isSignUp ? AutofillHints.newPassword : AutofillHints.password,
            ],
            onFieldSubmitted: isSignUp ? null : (_) => _handleSignIn(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (isSignUp && v.length < 8)
                return 'Password must be at least 8 characters';
              return null;
            },
          ),

          if (isSignUp) ...[
            const SizedBox(height: 10),
            AuthTextField(
              key: const ValueKey('confirm-password'),
              label: 'Confirm password',
              hint: 'Repeat your password',
              controller: _confirmPasswordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _handleSignUp(),
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'Please confirm your password';
                if (v != _passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _consentChecked,
                  onChanged: (v) => setState(() {
                    _consentChecked = v ?? false;
                    if (_consentChecked) _consentError = false;
                  }),
                  activeColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: ac.textSecondary),
                  ),
                ),
              ],
            ),
            if (_consentError) ...[
              const SizedBox(height: 4),
              Text(
                'You must accept the Terms to create an account',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            ],
          ],

          if (_serverError != null) ...[
            const SizedBox(height: 8),
            Text(
              _serverError!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],

          const SizedBox(height: 16),
          FilledButton(
            onPressed: (isSignUp && !_consentChecked) || _isLoading
                ? null
                : (isSignUp ? _handleSignUp : _handleSignIn),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _isLoading
                  ? 'Please wait…'
                  : (isSignUp ? 'Create account' : 'Sign in'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onPrimary,
              ),
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () =>
                  ref.read(authRepositoryProvider).signInAnonymously(),
              style: TextButton.styleFrom(foregroundColor: ac.mutedForeground),
              child: Text(
                'Browse as guest',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ac.mutedForeground),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
