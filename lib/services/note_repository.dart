/// FILE: lib/services/note_repository.dart
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';

class NoteRepository {
  // ---- Singleton ----
  NoteRepository._internal();
  static final NoteRepository instance = NoteRepository._internal();

  // ---- Dahili durum ----
  final List<String> _uploadedIds = [];
  final List<String> _purchasedIds = [];

  // Uygulama açıldığında gözükecek örnek notlar
  final ValueNotifier<List<NoteModel>> _notesNotifier =
  ValueNotifier<List<NoteModel>>([
    NoteModel(
      id: 'cs204-recursion',
      title: 'CS204 – Recursion Notes',
      courseCode: 'CS204',
      instructor: 'Dr. Example',
      price: 25,
      description:
      'Detailed recursion notes with examples for factorial, Fibonacci, '
          'backtracking and common exam-style problems.',
      taName: 'Mervan Çelebi',
      taRole: 'Teaching Assistant · CS204',
      createdBy: 'system',
      createdByName: 'Mervan Çelebi',
      imagePath: 'https://picsum.photos/seed/cs204/600/300',
    ),
    NoteModel(
      id: 'ns102-brain',
      title: 'NS102 – Brain Imaging Summary',
      courseCode: 'NS102',
      instructor: 'Unknown',
      price: 20,
      description:
      'Short but dense summary of fMRI, EEG, MEG, PET and BOLD signal '
          'principles. Focused on exam questions.',
      taName: 'Mervan Çelebi',
      taRole: 'Teaching Assistant · NS102',
      createdBy: 'system',
      createdByName: 'Mervan Çelebi',
      imagePath: 'https://picsum.photos/seed/ns102/600/300',
    ),
    NoteModel(
      id: 'math306-final',
      title: 'MATH306 – Final Cheat Sheet',
      courseCode: 'MATH306',
      instructor: 'Unknown',
      price: 30,
      description:
      'Condensed formula sheet and solved examples to prepare for the '
          'MATH306 final exam.',
      taName: 'Mervan Çelebi',
      taRole: 'Teaching Assistant · MATH306',
      createdBy: 'system',
      createdByName: 'Mervan Çelebi',
      imagePath: 'https://picsum.photos/seed/math306/600/300',
    ),
  ]);

  // ---- Dışarıya açılan API ----

  /// Home / Search / Uploaded ekranlarında kullandığın:
  ///   valueListenable: repo.notes
  ValueListenable<List<NoteModel>> get notes => _notesNotifier;

  /// Tüm notlar (sadece okunabilir liste)
  List<NoteModel> get allNotes => List.unmodifiable(_notesNotifier.value);

  /// Market’te gözüken notlar
  List<NoteModel> get marketNotes => allNotes;

  /// Kullanıcı tarafından upload edilenler
  List<NoteModel> get uploadedNotes => allNotes
      .where((note) => _uploadedIds.contains(note.id))
      .toList(growable: false);

  /// Satın alınan notlar
  List<NoteModel> get purchasedNotes => allNotes
      .where((note) => _purchasedIds.contains(note.id))
      .toList(growable: false);

  /// ID ile tek not bulma (NoteDetail için)
  NoteModel getById(String id) {
    return allNotes.firstWhere((n) => n.id == id);
  }

  // ---- Değiştiren metodlar ----

  /// Eski kodun `NoteRepository.instance.add(newNote);` diye çağırıyor.
  /// Bunu upload edilen not olarak da sayalım.
  void add(NoteModel note) => addUploaded(note);
  void updateNote(String id, String newTitle, String newDesc, double newPrice) {
    final current = List<NoteModel>.from(_notesNotifier.value);

    final index = current.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final old = current[index];

    final updated = NoteModel(
      id: old.id,
      title: newTitle,
      courseCode: old.courseCode,
      instructor: old.instructor,
      price: newPrice,
      description: newDesc,
      taName: old.taName,
      taRole: old.taRole,
      imageUrl: old.imageUrl,
      imagePath: old.imagePath,
      createdBy: old.createdBy,
      createdByName: old.createdByName,
    );

    current[index] = updated;
    _notesNotifier.value = current;
  }

  void addUploaded(NoteModel note) {
    if (!_uploadedIds.contains(note.id)) {
      _uploadedIds.add(note.id);
    }
    final current = List<NoteModel>.from(_notesNotifier.value);
    current.add(note);
    _notesNotifier.value = current;
  }

  void removeUploaded(NoteModel note) {
    _uploadedIds.remove(note.id);

    final current = List<NoteModel>.from(_notesNotifier.value);
    current.removeWhere((n) => n.id == note.id);
    _notesNotifier.value = current;

    _purchasedIds.remove(note.id);
  }

  void markPurchased(NoteModel note) {
    if (!_purchasedIds.contains(note.id)) {
      _purchasedIds.add(note.id);
      // Liste değişmemiş olsa bile satın alma durumu değişti, dinleyicilere haber verelim
      _notesNotifier.notifyListeners();
    }
  }
}
