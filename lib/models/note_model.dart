/// FILE: lib/models/note_model.dart

class NoteModel {
  final String id;
  final String title;
  final String courseCode;
  final String instructor;
  final double price;
  final String description;
  final String taName;
  final String taRole;
  final String? imageUrl;   // hazır notlar için network resmi
  final String? imagePath;  // senin upload ettiğin local preview resmi

  NoteModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.instructor,
    required this.price,
    required this.description,
    required this.taName,
    required this.taRole,
    this.imageUrl,
    this.imagePath,
  });

  /// Listelerde görünen kısa açıklama
  String get preview {
    const maxChars = 90;
    if (description.length <= maxChars) return description;
    return '${description.substring(0, maxChars)}...';
  }
}
