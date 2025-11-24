/// FILE: lib/screens/purchased_notes_screen.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';

class PurchasedNotesScreen extends StatelessWidget {
  const PurchasedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // repository singleton
    final repo = NoteRepository.instance;
    final List<NoteModel> purchased = repo.purchasedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchased Notes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search in your purchased notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (value) {
                // Şimdilik sadece UI – filtreleme eklemedik
              },
            ),
          ),
          Expanded(
            child: purchased.isEmpty
                ? const Center(
              child: Text('You have not purchased any notes yet.'),
            )
                : ListView.builder(
              itemCount: purchased.length,
              itemBuilder: (context, index) {
                final note = purchased[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.courseCode),
                  trailing: Text('₺${note.price.toStringAsFixed(0)}'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/noteDetail',
                      arguments: note.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
