class AppUser {
  final String id;
  final String fullName;
  final String phone;
  final String? email;

  /// Optional — the sign-up form collects it for business accounts.
  final String? businessName;
  final bool phoneVerified;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.businessName,
    this.phoneVerified = false,
  });

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? businessName,
    bool? phoneVerified,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }
}
