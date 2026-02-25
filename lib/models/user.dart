class User {
  final String id; // Changed from int to String (UUID)
  final String username;
  final String email;
  final String? role;
  final String? mobileNumber;
  final String? countryCode;
  final String? country;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.role,
    this.mobileNumber,
    this.countryCode,
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      mobileNumber: json['mobile_number'] ?? json['mobileNumber'],
      countryCode: json['country_code'] ?? json['countryCode'],
      country: json['country'],
    );
  }
}
