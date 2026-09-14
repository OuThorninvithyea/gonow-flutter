import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_back_arrow.dart';
import '../../widgets/app_pill_field.dart';
import '../../widgets/app_primary_button.dart';

/// Second step of the forgot-password flow (Figma: "Verification Code").
///
/// Distinct from [OtpVerificationScreen] on purpose — that screen's six
/// separate digit boxes are the register/phone-verify design; this flow
/// uses a single pill field per the reset-password Figma frame.
class ResetPasswordCodeScreen extends StatefulWidget {
  const ResetPasswordCodeScreen({super.key});

  @override
  State<ResetPasswordCodeScreen> createState() =>
      _ResetPasswordCodeScreenState();
}

class _ResetPasswordCodeScreenState extends State<ResetPasswordCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await context.read<AuthProvider>().verifyPasswordResetCode(
      _codeController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.push('/reset-password/new');
    } else {
      setState(() => _error = "That code doesn't look right. Try again.");
    }
  }

  Future<void> _resend() async {
    final identifier = context.read<AuthProvider>().resetIdentifier ?? '';
    await context.read<AuthProvider>().requestPasswordReset(identifier);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code resent')));
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
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 21),
                        const Text(
                          'Enter the verification code sent to your email '
                          'or phone',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 29),
                        AppPillField(
                          controller: _codeController,
                          hint: 'Enter 6-digit code',
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) => (v == null || v.trim().length < 6)
                              ? 'Enter the 6-digit code'
                              : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                        const SizedBox(height: 19),
                        AppPrimaryButton(
                          label: 'Verify',
                          loading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _resend,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'Resend code?',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
