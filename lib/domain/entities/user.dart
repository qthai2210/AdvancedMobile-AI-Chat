class User {
  final String id;
  final String email;
  final String name;
  final String? directNavigationPath;
  final String? accessToken;
  final String? refreshToken;
  //final String? userId;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.directNavigationPath,
    this.accessToken,
    this.refreshToken,
    //this.userId,
  });
}
