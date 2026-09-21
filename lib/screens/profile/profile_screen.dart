import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_vehicles.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_pill_field.dart';

/// Local guest/signed-in profile. Edits are stored in [ProfileProvider] and
/// [SharedPreferences] so they persist across runs during UX testing.
/// Sign-in is optional; guest users can reach this screen and use the app.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().user;
    final auth = context.watch<AuthProvider>();
    final isSignedIn = auth.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ProfileHeader(user: profile),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                if (!isSignedIn) ...[
                  _SignInSyncCard(onPressed: () => context.go('/login')),
                  const SizedBox(height: 20),
                ],
                _MenuGroup(
                  children: [
                    _MenuRow(
                      icon: Icons.history,
                      label: 'Ride History',
                      value: '${mockRideHistory.length} rides',
                      onTap: () => _requireSignIn(
                        context,
                        'sync your ride history',
                      ),
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.credit_card,
                      label: 'Payment Method',
                      value: 'Not Set',
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      value: 'On',
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => _requireSignIn(
                        context,
                        'change your settings',
                      ),
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                    ),
                    const _MenuDivider(),
                    _MenuRow(
                      icon: Icons.info_outline,
                      label: 'Legal & About',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isSignedIn) ...[
                  OutlinedButton.icon(
                    key: const Key('profile_logout_button'),
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Log out'),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      key: const Key('profile_clear_auth_button'),
                      onPressed: () =>
                          context.read<AuthProvider>().clearLocalAuthData(),
                      child: const Text(
                        'Dev: clear local account',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppNavTab.profile,
        onTap: (tab) {
          if (tab == AppNavTab.profile) return;
          if (tab == AppNavTab.home) {
            context.go('/home');
            return;
          }
          if (tab == AppNavTab.map) {
            context.go('/map');
            return;
          }
          if (tab == AppNavTab.rentals) {
            context.go('/rentals');
            return;
          }
          if (tab == AppNavTab.saved) {
            context.go('/saved');
            return;
          }
        },
      ),
    );
  }

  void _requireSignIn(BuildContext context, String benefit) {
    if (context.read<AuthProvider>().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Working locally — $benefit.'),
          backgroundColor: AppColors.ink,
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SignInPrompt(benefit: benefit),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to guest mode.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('profile_confirm_logout_button'),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pop();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

/// Shared card treatment for the profile header and the grouped menu list.
const _cardDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ],
);

/// Consolidated user header: a single white rounded card with the avatar,
/// name + contact info, and an edit action.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final name = user.fullName.trim().isEmpty
        ? 'Local Rider'
        : user.fullName.trim();
    final initial = name[0].toUpperCase();
    final contact = _contactLine(user);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration,
        child: Row(
          children: [
            _Avatar(initial: initial),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('profile_edit_button'),
              onPressed: () => _showEditSheet(context),
              icon: const Icon(Icons.edit_outlined, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }

  String _contactLine(AppUser user) {
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    final phone = user.phone.trim();
    return phone.isEmpty ? 'guest@gonow.app' : phone;
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _EditProfileSheet(),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.inkSurfaceAlt,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Electric Lime sign-in entry point shown to guest users above the menu.
class _SignInSyncCard extends StatelessWidget {
  const _SignInSyncCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('profile_sign_in_button'),
        onPressed: onPressed,
        child: const Text('Sign In to Sync Data'),
      ),
    );
  }
}

/// White rounded container grouping the menu rows into a single card.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.divider,
    );
  }
}

/// Modular menu row: leading icon, Title Case label, trailing detail, chevron.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _showComingSoon(context, label),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkSoft,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label is coming soon.'),
        backgroundColor: AppColors.ink,
      ),
    );
  }
}

/// Contextual "Sign In to Sync Data" prompt with Sign In / Continue as Guest.
class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.benefit});

  final String benefit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In to Sync Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account or log in to $benefit across devices.',
              style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('prompt_sign_in_button'),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/login');
                },
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const Key('prompt_continue_guest_button'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue as Guest'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().user;
    _name = TextEditingController(text: user.fullName);
    _phone = TextEditingController(text: user.phone);
    _email = TextEditingController(text: user.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<ProfileProvider>().update(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 25),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('profile_name_field'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('profile_phone_field'),
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('profile_email_field'),
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppPillField.height,
              child: ElevatedButton(
                key: const Key('profile_save_button'),
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Text(
                        'Save changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
