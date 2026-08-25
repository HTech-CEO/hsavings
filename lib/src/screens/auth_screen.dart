import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/environment.dart';
import 'home_screen.dart';

/// A unified authentication screen for email sign-in and account creation.
///
/// Supabase must be initialized before this screen is displayed. The screen
/// deliberately uses the official Supabase client directly so the auth flow
/// remains easy to test and follows the package's recommended API.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = _isSignUp
          ? await Supabase.instance.client.auth.signUp(
              email: email,
              password: password,
            )
          : await Supabase.instance.client.auth.signInWithPassword(
              email: email,
              password: password,
            );

      if (!mounted) return;

      // Supabase can create an account without a session when email
      // confirmation is enabled, so explain the next step instead of routing
      // an unauthenticated user into the application.
      if (response.session == null) {
        _showMessage(
          'Account created. Check your email to confirm your address.',
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (mounted) _showMessage(_friendlyAuthMessage(error));
    } catch (_) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Authenticates with the native Google account picker and exchanges the
  /// resulting tokens for a Supabase session.
  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile', 'openid'],
        serverClientId: Environment.googleServerClientId.isEmpty
            ? null
            : Environment.googleServerClientId,
      );
      final googleUser = await googleSignIn.signIn();

      // Cancelling the native account picker is a normal user action.
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google did not return an ID token.');
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (mounted) _showMessage(_friendlyAuthMessage(error));
    } catch (error) {
      if (mounted) {
        _showMessage(_friendlyGoogleMessage(error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyGoogleMessage(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('canceled') || message.contains('cancelled')) {
      return 'Google sign-in was cancelled.';
    }
    if (message.contains('developer_error') ||
        message.contains('developer error') ||
        message.contains('code: 10') ||
        message.contains('statuscode: 10') ||
        message.contains('error code 10')) {
      return 'Google sign-in is not configured for this app. Check the OAuth client ID and package configuration.';
    }
    if (message.contains('play services') || message.contains('unavailable')) {
      return 'Google Play Services is unavailable on this device.';
    }
    return 'Google sign-in failed. Please try again.';
  }

  String _friendlyAuthMessage(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Invalid login credentials.';
    }
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'Email already in use.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    return error.message.isEmpty
        ? 'Authentication failed. Please try again.'
        : error.message;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF174380),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
          ),
        ),
      );
  }

  void _toggleMode() {
    FocusScope.of(context).unfocus();
    setState(() => _isSignUp = !_isSignUp);
    _formKey.currentState?.reset();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return isValid ? null : 'Enter a valid email address.';
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white : const Color(0xFF174380);
    final supportingColor = isDark
        ? const Color(0xFFB7C4D8)
        : const Color(0xFF52657D);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? const Color(0xFF10141A) : const Color(0xFFEAF0F7),
              isDark ? const Color(0xFF1B1F28) : const Color(0xFFF3F6F8),
              isDark ? const Color(0xFF17253A) : const Color(0xFFDDE7F2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BrandMark(color: colors.primary),
                    const SizedBox(height: 28),
                    Text(
                      _isSignUp
                          ? 'Start your healthier money habits.'
                          : 'Welcome back.',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: headingColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isSignUp
                          ? 'Create your account and keep every goal in view.'
                          : 'Your finances are ready when you are.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: supportingColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Card(
                      elevation: 0,
                      color: isDark
                          ? const Color(0xFF1B1F28)
                          : Colors.white.withValues(alpha: 0.94),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: colors.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment<bool>(
                                    value: false,
                                    label: Text('Sign in'),
                                  ),
                                  ButtonSegment<bool>(
                                    value: true,
                                    label: Text('Sign up'),
                                  ),
                                ],
                                selected: {_isSignUp},
                                onSelectionChanged: _isLoading
                                    ? null
                                    : (selection) {
                                        if (selection.isNotEmpty) {
                                          setState(
                                            () => _isSignUp = selection.first,
                                          );
                                          _formKey.currentState?.reset();
                                        }
                                      },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailController,
                                enabled: !_isLoading,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: _validateEmail,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'you@example.com',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                enabled: !_isLoading,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                validator: _validatePassword,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'At least 6 characters',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: _isLoading
                                        ? null
                                        : () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _isLoading ? null : _submit,
                                child: _isLoading
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isSignUp
                                            ? 'Create account'
                                            : 'Sign in',
                                      ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _isLoading ? null : _toggleMode,
                                child: Text(
                                  _isSignUp
                                      ? 'Already have an account? Sign in'
                                      : 'New to HSavings? Create an account',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const _OrDivider(),
                              const SizedBox(height: 16),
                              _GoogleSignInButton(
                                isLoading: _isLoading,
                                onPressed: _signInWithGoogle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your money journey, kept simple.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: supportingColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Separates credential authentication from the social authentication option.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

/// A light, bordered Google button with a small brand-colour logo mark.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const _GoogleLogo(),
        label: const Text('Continue with Google'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1F1F1F),
          backgroundColor: const Color(0xFFF8F9FA),
          disabledForegroundColor: const Color(0xFF6B7280),
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

/// Compact text-based Google mark that avoids bundling an untrusted asset.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/// Compact brand cue that keeps the page recognizable without adding noise.
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_graph_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          'HSavings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF174380),
          ),
        ),
      ],
    );
  }
}
