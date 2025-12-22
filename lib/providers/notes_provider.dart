/// FILE: lib/providers/notes_provider.dart
/// Notes state management using Provider pattern
/// Handles CRUD operations with Firestore and real-time updates

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';

class NotesProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<NoteModel> _allNotes = [];
  List<NoteModel> _userNotes = [];
  List<NoteModel> _purchasedNotes = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NoteModel> get allNotes => _allNotes;
  List<NoteModel> get userNotes => _userNotes;
  List<NoteModel> get purchasedNotes => _purchasedNotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Stream of all notes (real-time updates)
  Stream<List<NoteModel>> getNotesStream() {
    return _firestoreService.getNotesStream();
  }

  /// Stream of user's uploaded notes
  Stream<List<NoteModel>> getUserNotesStream(String userId) {
    return _firestoreService.getUserNotesStream(userId);
  }

  /// Stream of user's purchased notes
  Stream<List<NoteModel>> getPurchasedNotesStream(String userId) {
    return _firestoreService.getPurchasedNotesStream(userId);
  }

  /// Get a single note by ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      return await _firestoreService.getNoteById(noteId);
    } catch (e) {
      _errorMessage = 'Error fetching note: $e';
      notifyListeners();
      return null;
    }
  }

  /// Create a new note
  Future<bool> createNote({
    required String title,
    required String courseCode,
    required String instructor,
    required double price,
    required String description,
    required String taName,
    required String taRole,
    required String createdBy,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final note = NoteModel(
        id: '', // Will be set by Firestore
        title: title,
        courseCode: courseCode,
        instructor: instructor,
        price: price,
        description: description,
        taName: taName,
        taRole: taRole,
        imagePath: imagePath,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createNote(note);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error creating note: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing note
  Future<bool> updateNote({
    required String noteId,
    required String title,
    required String description,
    required double price,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateNote(
        noteId: noteId,
        title: title,
        description: description,
        price: price,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating note: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a note
  Future<bool> deleteNote(String noteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteNote(noteId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting note: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Purchase a note (add to user's purchased list)
  Future<bool> purchaseNote({
    required String noteId,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.purchaseNote(noteId: noteId, userId: userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error purchasing note: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if user has purchased a note
  Future<bool> hasUserPurchased(String noteId, String userId) async {
    try {
      return await _firestoreService.hasUserPurchased(noteId, userId);
    } catch (e) {
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
