import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/phone_number.dart';
import '../../providers/auth_provider.dart';

/// Create Account. Redesigned to match the Home screen's visual language
/// while keeping the existing sign-up fields (name, business name, phone,
/// email, password, confirmation) so the local OTP flow keeps working.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _isValid = false;
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _firstNameController,
      _lastNameController,
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
    _firstNameController.dispose();
    _lastNameController.dispose();
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

    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    final businessName = _businessNameController.text.trim();
    await context.read<AuthProvider>().register(
      fullName: fullName,
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

  String? _validateName(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? 'Enter your $field' : null;

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
    if (value.isEmpty) return null;
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
        _validateName(_firstNameController.text, 'first name') == null &&
        _validateName(_lastNameController.text, 'last name') == null &&
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 24, 25, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.5,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Get on the road in minutes.',
                  style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PillField(
                        key: const Key('register_first_name_field'),
                        controller: _firstNameController,
                        hint: 'First Name',
                        textInputAction: TextInputAction.next,
                        validator: (v) => _validateName(v, 'first name'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PillField(
                        key: const Key('register_last_name_field'),
                        controller: _lastNameController,
                        hint: 'Last Name',
                        textInputAction: TextInputAction.next,
                        validator: (v) => _validateName(v, 'last name'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PillField(
                  key: const Key('register_business_name_field'),
                  controller: _businessNameController,
                  hint: 'Business name (optional)',
                  textInputAction: TextInputAction.next,
                  validator: _validateBusinessName,
                ),
                const SizedBox(height: 12),
                _PillField(
                  key: const Key('register_phone_field'),
                  controller: _phoneController,
                  hint: 'Phone',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const [CambodianPhoneFormatter()],
                  validator: validateCambodianPhone,
                ),
                const SizedBox(height: 12),
                _PillField(
                  key: const Key('register_email_field'),
                  controller: _emailController,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
                _PillField(
                  key: const Key('register_password_field'),
                  controller: _passwordController,
                  hint: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    key: const Key('register_show_password_button'),
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _PillField(
                  key: const Key('register_confirm_password_field'),
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validateConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    key: const Key('register_show_confirm_password_button'),
                    tooltip: _obscureConfirm
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _TermsAcceptance(
                  onUnavailable: _notImplemented,
                  onChanged: _onTermsChanged,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    key: const Key('register_create_account_button'),
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('register_continue_guest_button'),
                  onPressed: () => context.go('/home'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text(
                    'Continue as guest',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        key: const Key('register_go_to_login_button'),
                        onTap: () => context.go('/login'),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded pill field mirroring the Home screen's rounded-surface language.
class _PillField extends StatelessWidget {
  const _PillField({
    super.key,
    required this.controller,
    required this.hint,
    required this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?) validator;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 16, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16, color: AppColors.inkSoft),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 20, color: AppColors.inkSoft),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: AppColors.ink, width: 1.2),
        errorBorder: _border(color: AppColors.danger),
        focusedErrorBorder: _border(color: AppColors.danger, width: 1.2),
      ),
    );
  }

  static OutlineInputBorder _border({
    Color color = AppColors.border,
    double width = 1,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: color, width: width),
  );
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
                    activeColor: AppColors.primary,
                    checkColor: AppColors.onPrimary,
                    side: BorderSide(
                      color: state.hasError
                          ? AppColors.danger
                          : AppColors.border,
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
                      color: AppColors.inkSoft,
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
