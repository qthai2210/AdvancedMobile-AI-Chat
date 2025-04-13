import 'package:aichatbot/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    String? directNavigationPath,
  }) : super(
          id: id,
          email: email,
          name: name,
          //avatarUrl: avatarUrl,
          accessToken: accessToken,
          refreshToken: refreshToken,
          directNavigationPath: directNavigationPath,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      avatarUrl: json['avatar_url'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      directNavigationPath: json['direct_navigation_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'direct_navigation_path': directNavigationPath,
    };
  }

  // Tạo UserModel từ entity User
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
      directNavigationPath: user.directNavigationPath,
    );
  }
}
