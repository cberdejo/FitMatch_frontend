class User {
  final num user_id;
  String username;
  String email;
  String? password;
  String? profile_picture;
  DateTime? birth;
  final num profile_id;
  String system;
  String? bio;
  bool public;

  User({
    required this.user_id,
    required this.username,
    required this.email,
    this.password,
    this.profile_picture,
    this.birth,
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
      birth: json['birth'] == null ? null : DateTime.parse(json['birth']),
      profile_id: json['profile_id'],
      public: json['public'],
      bio: json['bio'],
      system: json['system'],
    );
  }
}
