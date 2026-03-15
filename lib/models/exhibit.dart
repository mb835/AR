/// Data model for museum exhibit entries.
class Exhibit {
  const Exhibit({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.modelPath,
    required this.markerPath,
  });

  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String modelPath;
  final String markerPath;

  factory Exhibit.fromJson(Map<String, dynamic> json) {
    return Exhibit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imagePath: json['image_path'] as String,
      modelPath: json['model_path'] as String,
      markerPath: json['marker_path'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image_path': imagePath,
        'model_path': modelPath,
        'marker_path': markerPath,
      };
}
