/// Data model for museum exhibit entries.
class Exhibit {
  const Exhibit({
    required this.id,
    required this.title,
    required this.description,
    required this.modelPath,
    required this.markerId,
  });

  final String id;
  final String title;
  final String description;
  final String modelPath;
  final String markerId;

  factory Exhibit.fromJson(Map<String, dynamic> json) {
    return Exhibit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      modelPath: json['model_path'] as String,
      markerId: json['marker_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'model_path': modelPath,
        'marker_id': markerId,
      };
}
