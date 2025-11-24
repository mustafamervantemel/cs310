// FILE: lib/screens/uploaded_notes_screen.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';

class UploadedNotesScreen extends StatelessWidget {
  const UploadedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = NoteRepository.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Notes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<NoteModel>>(
              valueListenable: repo.notes,
              builder: (context, notes, _) {
                // Basit filtre: senin upload ettiğin notlar
                final uploaded = notes.where((n) => n.taName == 'You').toList();

                if (uploaded.isEmpty) {
                  return const Center(
                    child: Text('You have not uploaded any notes yet.'),
                  );
                }

                return ListView.builder(
                  itemCount: uploaded.length,
                  itemBuilder: (context, index) {
                    final note = uploaded[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text('Price: ₺${note.price.toStringAsFixed(0)}'),
                      trailing: TextButton(
                        onPressed: () {
                          // demo: editi şimdilik boş bırakıyoruz
                        },
                        child: const Text('Edit'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/uploadNote');
                },
                child: const Text('Upload Note'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
