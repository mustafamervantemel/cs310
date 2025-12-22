/// FILE: lib/models/note_model.dart
/// Note model class with Firestore serialization support

import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String courseCode;
  final String description;
  final double price;
  final String createdBy;
  final String? createdByName;
  final DateTime? createdAt;
  final String? fileName;
  final int stars;
  final int totalSells;
  
  // Legacy fields for compatibility
  final String? instructor;
  final String? taName;
  final String? taRole;
  final String? imageUrl;
  final String? imagePath;

  NoteModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.description,
    required this.price,
    required this.createdBy,
    this.createdByName,
    this.createdAt,
    this.fileName,
    this.stars = 0,
    this.totalSells = 0,
    this.instructor,
    this.taName,
    this.taRole,
    this.imageUrl,
    this.imagePath,
  });

  /// Short preview for lists
  String get preview {
    const maxChars = 90;
    if (description.length <= maxChars) return description;
    return '${description.substring(0, maxChars)}...';
  }

  /// Convert NoteModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'courseCode': courseCode,
      'description': description,
      'price': price,
      'createdBy': createdBy,
      'createdByName': createdByName ?? '',
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'fileName': fileName,
      'stars': stars,
      'totalSells': totalSells,
      'instructor': instructor ?? '',
      'taName': taName ?? '',
      'taRole': taRole ?? '',
      'imageUrl': imageUrl,
      'imagePath': imagePath,
    };
  }

  /// Create NoteModel from Firestore document
  factory NoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NoteModel(
      id: documentId,
      title: map['title'] ?? '',
      courseCode: map['courseCode'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      fileName: map['fileName'],
      stars: map['stars'] ?? 0,
      totalSells: map['totalSells'] ?? 0,
      instructor: map['instructor'],
      taName: map['taName'],
      taRole: map['taRole'],
      imageUrl: map['imageUrl'],
      imagePath: map['imagePath'],
    );
  }

  /// Create a copy with updated fields
  NoteModel copyWith({
    String? id,
    String? title,
    String? courseCode,
    String? description,
    double? price,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    String? fileName,
    int? stars,
    int? totalSells,
    String? instructor,
    String? taName,
    String? taRole,
    String? imageUrl,
    String? imagePath,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      description: description ?? this.description,
      price: price ?? this.price,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      fileName: fileName ?? this.fileName,
      stars: stars ?? this.stars,
      totalSells: totalSells ?? this.totalSells,
      instructor: instructor ?? this.instructor,
      taName: taName ?? this.taName,
      taRole: taRole ?? this.taRole,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
