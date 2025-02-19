class User {
  final int userId;
  final String username;
  final String fullName;
  final String phoneNumber;

  User({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}
