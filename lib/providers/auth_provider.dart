import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Holds auth/session state for the app. Talks to a mock in-memory "backend"
/// for now — swap the bodies of these methods for real API calls once the
/// Golang/Fiber backend is available.
class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  String? _pendingPhone;

  // Forgot-password flow. Independent of `_user` since the person is not
  // signed in while resetting — an email/phone identifier and a "did the
  // code check out" flag are all the next two screens need.
  String? _resetIdentifier;
  bool _resetCodeVerified = false;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null && _user!.phoneVerified;
  String? get pendingPhone => _pendingPhone;
  String? get resetIdentifier => _resetIdentifier;
  bool get resetCodeVerified => _resetCodeVerified;

  Future<void> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? businessName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      phone: phone,
      email: email,
      businessName: businessName,
      phoneVerified: false,
    );
    _pendingPhone = phone;
    notifyListeners();
  }

  Future<void> login({required String phone, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: 'Returning Rider',
      phone: phone,
      phoneVerified: true,
    );
    notifyListeners();
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final valid = code.length == 6;
    if (valid && _user != null) {
      _user = _user!.copyWith(phoneVerified: true);
      _pendingPhone = null;
      notifyListeners();
    }
    return valid;
  }

  void logout() {
    _user = null;
    _pendingPhone = null;
    notifyListeners();
  }

  /// Clears the local session data used by the profile development flow.
  void clearLocalAuthData() => logout();

  Future<void> requestPasswordReset(String identifier) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _resetIdentifier = identifier;
    _resetCodeVerified = false;
    notifyListeners();
  }

  Future<bool> verifyPasswordResetCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final valid = code.length == 6;
    if (valid) {
      _resetCodeVerified = true;
      notifyListeners();
    }
    return valid;
  }

  Future<void> resetPassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _resetIdentifier = null;
    _resetCodeVerified = false;
    notifyListeners();
  }
}
