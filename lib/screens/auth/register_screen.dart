import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/tab_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/phone_number.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_pill_field.dart';
import '../../widgets/app_primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _isValid = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _businessNameController,
      _phoneController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.addListener(_recomputeValidity);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final businessName = _businessNameController.text.trim();
    await context.read<AuthProvider>().register(
      fullName: _nameController.text.trim(),
      phone: phoneDigits(_phoneController.text),
      password: _passwordController.text,
      email: _emailController.text.trim(),
      businessName: businessName.isEmpty ? null : businessName,
    );

    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/verify-otp');
  }

  void _notImplemented(String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what is not wired up yet.')));
  }

  String? _validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter your name' : null;

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Enter your email';
    final looksLikeEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(value);
    return looksLikeEmail ? null : 'Enter a valid email';
  }

  String? _validateBusinessName(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null; // Optional — blank registers as a person.
    if (value.length < 2) return 'Business name is too short';
    if (value.length > 50) return 'Business name is too long';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Include at least one letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) return 'Include at least one number';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Re-enter your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _onTermsChanged(bool accepted) {
    _termsAccepted = accepted;
    _recomputeValidity();
  }

  void _recomputeValidity() {
    final valid =
        _validateName(_nameController.text) == null &&
        _validateBusinessName(_businessNameController.text) == null &&
        validateCambodianPhone(_phoneController.text) == null &&
        _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        _validateConfirmPassword(_confirmPasswordController.text) == null &&
        _termsAccepted;
    if (valid != _isValid) setState(() => _isValid = valid);
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
          'Register',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 72),
                // The design breaks this line explicitly rather than wrapping.
                const Text(
                  'Lets Register\nAccount',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 21),
                const Text(
                  'Hello user , you have agreatful journey',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 29),
                AppPillField(
                  controller: _nameController,
                  hint: 'Name',
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                ),
                const SizedBox(height: 11),
                AppPillField(
                  controller: _businessNameController,
                  hint: 'Buissness name (optional)',
                  textInputAction: TextInputAction.next,
                  validator: _validateBusinessName,
                ),
                const SizedBox(height: 11),
                AppPillField(
                  controller: _phoneController,
                  hint: 'Phone',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const [CambodianPhoneFormatter()],
                  validator: validateCambodianPhone,
                ),
                const SizedBox(height: 11),
                AppPillField(
                  controller: _emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 11),
                AppPillField(
                  controller: _passwordController,
                  hint: 'Password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 11),
                AppPillField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 16),
                _TermsAcceptance(
                  onUnavailable: _notImplemented,
                  onChanged: _onTermsChanged,
                ),
                const SizedBox(height: 19),
                AppPrimaryButton(
                  label: 'Register Now',
                  loading: _loading,
                  isValid: _isValid,
                  onPressed: _submit,
                ),
                const SizedBox(height: 33),
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
                            goWithSlide(context, '/login', reverse: true),
                        behavior: HitTestBehavior.opaque,
                        child: const Text(
                          'Login',
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

/// Terms + privacy consent, as a [FormField] so `_formKey.validate()` blocks
/// submission until it is ticked — same pass as the text validators.
///
/// Neither document has a route yet, so the two links report back through
/// [onUnavailable] the way the login screen handles its unwired actions.
class _TermsAcceptance extends StatefulWidget {
  const _TermsAcceptance({
    required this.onUnavailable,
    required this.onChanged,
  });

  final void Function(String what) onUnavailable;
  final ValueChanged<bool> onChanged;

  @override
  State<_TermsAcceptance> createState() => _TermsAcceptanceState();
}

class _TermsAcceptanceState extends State<_TermsAcceptance> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => widget.onUnavailable('Terms of Service');
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => widget.onUnavailable('Privacy Policy');
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    );

    return FormField<bool>(
      initialValue: false,
      validator: (accepted) => (accepted ?? false)
          ? null
          : 'Accept the Terms and Privacy Policy to continue',
      builder: (state) {
        final accepted = state.value ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label: 'Accept the Terms of Service and Privacy Policy',
                  child: Checkbox(
                    value: accepted,
                    onChanged: (v) {
                      state.didChange(v ?? false);
                      widget.onChanged(v ?? false);
                    },
                    activeColor: AppColors.ink,
                    checkColor: AppColors.onDark,
                    side: BorderSide(
                      color: state.hasError
                          ? AppColors.danger
                          : AppColors.fieldBorder,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: linkStyle,
                          recognizer: _termsTap,
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: linkStyle,
                          recognizer: _privacyTap,
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              ),
          ],
        );
      },
    );
  }
}
