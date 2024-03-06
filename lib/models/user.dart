class User {
  final num user_id;
  final String username;
  final String email;
  final String password;
  final String profile_picture;
  final DateTime birth;
  final num profile_id;
  String system;
  String? bio;
  final bool public;

  User({
    required this.user_id,
    required this.username,
    required this.email,
    required this.password,
    required this.profile_picture,
    required this.birth,
    this.system = 'metrico',
    this.bio,
    required this.profile_id,
    required this.public,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      user_id: json['user_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      profile_picture: json['profile_picture'],
      birth: DateTime.parse(json['birth']), // ISO 8601
      profile_id: json['profile_id'],
      public: json['public'],
      bio: json['bio'],
      system: json['system'],
    );
  }
}
