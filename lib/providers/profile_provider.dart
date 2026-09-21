import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Local guest profile, stored in [SharedPreferences] so edits survive
/// restarts during UX testing. There is no requirement to sign in to use
/// the Profile tab; the default guest account is used until a real auth
/// backend is wired up.
class ProfileProvider extends ChangeNotifier {
  static const _nameKey = 'profile_name';
  static const _phoneKey = 'profile_phone';
  static const _emailKey = 'profile_email';

  AppUser _user = ProfileProvider.guestUser;

  static const guestUser = AppUser(
    id: 'local-guest',
    fullName: 'Local Rider',
    phone: '012 345 678',
    email: 'guest@gonow.app',
  );

  AppUser get user => _user;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _user = _user.copyWith(
        fullName: prefs.getString(_nameKey) ?? _user.fullName,
        phone: prefs.getString(_phoneKey) ?? _user.phone,
        email: prefs.getString(_emailKey) ?? _user.email,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> update({String? fullName, String? phone, String? email}) async {
    _user = AppUser(
      id: _user.id,
      fullName: fullName ?? _user.fullName,
      phone: phone ?? _user.phone,
      email: email ?? _user.email,
    );
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, _user.fullName);
      await prefs.setString(_phoneKey, _user.phone);
      await prefs.setString(_emailKey, _user.email ?? '');
    } catch (_) {}
  }
}
