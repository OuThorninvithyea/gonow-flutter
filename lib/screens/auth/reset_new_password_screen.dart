import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_back_arrow.dart';
import '../../widgets/app_pill_field.dart';
import '../../widgets/app_primary_button.dart';

/// Final step of the forgot-password flow (Figma: "Change Password").
///
/// The Figma subtitle mentions a "current" password, but the frame only has
/// New Password / Confirm New Password fields — there's no current-password
/// field to check against, since the user got here by verifying an email/
/// phone code rather than by being signed in. The copy below drops that
/// stray reference; see PR notes for the flagged discrepancy.
class ResetNewPasswordScreen extends StatefulWidget {
  const ResetNewPasswordScreen({super.key});

  @override
  State<ResetNewPasswordScreen> createState() => _ResetNewPasswordScreenState();
}

class _ResetNewPasswordScreenState extends State<ResetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Re-enter your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<AuthProvider>().resetPassword(_passwordController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed — sign in to continue')),
    );
    context.go('/login');
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
                          'Change Password',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 21),
                        const Text(
                          'Enter and confirm your new password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 29),
                        AppPillField(
                          controller: _passwordController,
                          hint: 'New Password',
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 11),
                        AppPillField(
                          controller: _confirmController,
                          hint: 'Confirm New Password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: _validateConfirm,
                        ),
                        const SizedBox(height: 19),
                        AppPrimaryButton(
                          label: 'Verify',
                          loading: _loading,
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
