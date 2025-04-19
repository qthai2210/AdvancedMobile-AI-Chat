import 'package:aichatbot/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String email,
    required String name,
    String? directNavigationPath,
    String? accessToken,
    String? refreshToken,
  }) : super(
          id: id,
          email: email,
          name: name,
          directNavigationPath: directNavigationPath,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

  factory UserModel.fromJson(Map<String, dynamic> json, String email,
      {String? name}) {
    return UserModel(
      id: json['user_id'],
      email: email,
      name: name ?? email.split('@').first,
      directNavigationPath: '/chat/detail/new',
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
