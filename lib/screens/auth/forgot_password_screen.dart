import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_back_arrow.dart';
import '../../widgets/app_pill_field.dart';
import '../../widgets/app_primary_button.dart';

/// First step of the forgot-password flow (Figma: "Forget Password?").
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _loading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_recomputeValidity);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? v) => (v == null || v.trim().isEmpty)
      ? 'Enter your email, phone or username'
      : null;

  void _recomputeValidity() {
    final valid = _validateIdentifier(_identifierController.text) == null;
    if (valid != _isValid) setState(() => _isValid = valid);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<AuthProvider>().requestPasswordReset(
      _identifierController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    context.push('/reset-password/code');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              AppBackArrow(onTap: () => context.pop()),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Forget Password?',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 21),
                        const Text(
                          'Enter you email or phone number to change '
                          'password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 29),
                        AppPillField(
                          controller: _identifierController,
                          hint: 'Email & Username',
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: _validateIdentifier,
                        ),
                        const SizedBox(height: 19),
                        AppPrimaryButton(
                          label: 'Continue',
                          loading: _loading,
                          isValid: _isValid,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
