class UserProfile {
  final String id;
  final String name;
  final String role;
  final bool isApprovedShopkeeper;

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.isApprovedShopkeeper = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      role: json['role']?.toString() ?? 'student',
      isApprovedShopkeeper: json['is_approved_shopkeeper'] == true,
    );
  }
}
