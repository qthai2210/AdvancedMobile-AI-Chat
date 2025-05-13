import 'package:equatable/equatable.dart';

/// Model representing user profile data from the /auth/me endpoint
class UserProfileModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final List<String> roles;
  final Map<String, dynamic> geo;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    required this.geo,
  });

  /// Creates a [UserProfileModel] from a JSON map
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      geo: json['geo'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'roles': roles,
      'geo': geo,
    };
  }

  @override
  List<Object?> get props => [id, email, username, roles, geo];
}
