/// FILE: lib/services/firestore_service.dart
/// Firestore service layer for all database operations
/// All Firestore calls go through this service (not directly in UI)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  CollectionReference get _notesCollection => _firestore.collection('notes');
  CollectionReference get _purchasesCollection => _firestore.collection('purchases');

  // ==================== CREATE ====================
  
  /// Create a new note document in Firestore
  Future<String> createNote(NoteModel note) async {
    try {
      final docRef = await _notesCollection.add(note.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  // ==================== READ ====================
  
  /// Get all notes as a stream (real-time updates)
  Stream<List<NoteModel>> getNotesStream() {
    return _notesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NoteModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Get notes uploaded by a specific user
  /// Note: Removed orderBy to avoid requiring a composite index
  Stream<List<NoteModel>> getUserNotesStream(String userId) {
    return _notesCollection
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notes = snapshot.docs.map((doc) {
            return NoteModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
          // Sort locally by createdAt descending
          notes.sort((a, b) {
            final aDate = a.createdAt ?? DateTime(1970);
            final bDate = b.createdAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
          return notes;
        });
  }

  /// Get notes purchased by a specific user
  Stream<List<NoteModel>> getPurchasedNotesStream(String userId) {
    return _purchasesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((purchaseSnapshot) async {
          final noteIds = purchaseSnapshot.docs
              .map((doc) => doc['noteId'] as String)
              .toList();
          
          if (noteIds.isEmpty) return <NoteModel>[];
          
          final notesSnapshot = await _notesCollection
              .where(FieldPath.documentId, whereIn: noteIds)
              .get();
          
          return notesSnapshot.docs.map((doc) {
            return NoteModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Get a single note by ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _notesCollection.doc(noteId).get();
      if (doc.exists) {
        return NoteModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get note: $e');
    }
  }

  /// Get a single note as a stream (real-time updates)
  Stream<NoteModel?> getNoteStream(String noteId) {
    return _notesCollection.doc(noteId).snapshots().map((doc) {
      if (doc.exists) {
        return NoteModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    });
  }

  // ==================== UPDATE ====================
  
  /// Update an existing note
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String description,
    required double price,
  }) async {
    try {
      await _notesCollection.doc(noteId).update({
        'title': title,
        'description': description,
        'price': price,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // ==================== DELETE ====================
  
  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).delete();
      
      // Also delete related purchases
      final purchases = await _purchasesCollection
          .where('noteId', isEqualTo: noteId)
          .get();
      
      for (final doc in purchases.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // ==================== PURCHASES ====================
  
  /// Record a purchase
  Future<void> purchaseNote({
    required String noteId,
    required String userId,
  }) async {
    try {
      // Record the purchase
      await _purchasesCollection.add({
        'noteId': noteId,
        'userId': userId,
        'purchasedAt': FieldValue.serverTimestamp(),
      });
      
      // Increment totalSells on the note
      await _notesCollection.doc(noteId).update({
        'totalSells': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to record purchase: $e');
    }
  }

  /// Check if user has purchased a note
  Future<bool> hasUserPurchased(String noteId, String userId) async {
    try {
      final snapshot = await _purchasesCollection
          .where('noteId', isEqualTo: noteId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
