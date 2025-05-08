class UploadedFile {
  final String id;
  final String name;
  final String url;

  UploadedFile({required this.id, required this.name, required this.url});

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'],
      name: json['name'],
      url: json['url'],
    );
  }
}