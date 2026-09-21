import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/tab_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_pill_field.dart';
import '../../widgets/app_primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_recomputeValidity);
    _passwordController.addListener(_recomputeValidity);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? v) => (v == null || v.trim().isEmpty)
      ? 'Enter your email, phone or username'
      : null;

  String? _validatePassword(String? v) => (v == null || v.length < 6)
      ? 'Password must be at least 6 characters'
      : null;

  void _recomputeValidity() {
    final valid =
        _validateIdentifier(_identifierController.text) == null &&
        _validatePassword(_passwordController.text) == null;
    if (valid != _isValid) setState(() => _isValid = valid);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // AuthProvider only models phone login for now; the design's field also
    // accepts email and username, so this passes whatever was typed.
    await context.read<AuthProvider>().login(
      phone: _identifierController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  void _notImplemented(String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what is not wired up yet.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sign In',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 115),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Figma sizes this node 270x55.9 — a single line in Outfit.
                    // Roboto is wider, so scale down rather than wrap.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lets Sign you in',
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 37,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Welcome Back ,\nYou have been missed',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                AppPillField(
                  controller: _identifierController,
                  hint: 'Email ,phone & username',
                  textInputAction: TextInputAction.next,
                  validator: _validateIdentifier,
                ),
                const SizedBox(height: 12),
                AppPillField(
                  controller: _passwordController,
                  hint: 'Password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Forgot Password ?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AppPrimaryButton(
                  label: 'Sign in',
                  loading: _loading,
                  isValid: _isValid,
                  onPressed: _submit,
                ),
                const SizedBox(height: 23),
                const _OrDivider(),
                const SizedBox(height: 19),
                _SocialRow(onTap: _notImplemented),
                const SizedBox(height: 36),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already  have an account ?',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPlaceholder,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () =>
                            goWithSlide(context, '/register', reverse: false),
                        behavior: HitTestBehavior.opaque,
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(color: AppColors.rule, thickness: 0.5, height: 0.5),
    );

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.5),
      child: Row(
        children: [
          line,
          SizedBox(width: 6),
          Text(
            'or',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          SizedBox(width: 6),
          line,
        ],
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({required this.onTap});

  final void Function(String provider) onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SocialButton(
            asset: 'assets/images/social/google.svg',
            size: const Size(27, 28),
            label: 'Google sign-in',
            onTap: onTap,
          ),
          const SizedBox(width: 33),
          _SocialButton(
            asset: 'assets/images/social/facebook.svg',
            size: const Size(18, 30.922),
            label: 'Facebook sign-in',
            onTap: onTap,
          ),
          const SizedBox(width: 33),
          _SocialButton(
            asset: 'assets/images/social/apple.svg',
            size: const Size(28, 34),
            label: 'Apple sign-in',
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.asset,
    required this.size,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final Size size;
  final String label;
  final void Function(String provider) onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () => onTap(label),
        behavior: HitTestBehavior.opaque,
        // The icons are 18–28pt wide; pad out to a 44pt minimum tap target.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: size.width,
              height: size.height,
            ),
          ),
        ),
      ),
    );
  }
}
