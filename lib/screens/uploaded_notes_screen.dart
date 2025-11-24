// FILE: lib/screens/uploaded_notes_screen.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';

class UploadedNotesScreen extends StatefulWidget {
  const UploadedNotesScreen({super.key});

  @override
  State<UploadedNotesScreen> createState() => _UploadedNotesScreenState();
}

class _UploadedNotesScreenState extends State<UploadedNotesScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final repo = NoteRepository.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF101733),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101733),
        elevation: 0,
        title: const Text(
          "Uploaded Notes",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => searchText = v),
              ),
            ),
          ),

          Expanded(
            child: ValueListenableBuilder<List<NoteModel>>(
              valueListenable: repo.notes,
              builder: (context, notes, _) {
                final uploaded = notes.where((n) => n.taName == "You").toList();

                final filtered = uploaded.where((note) {
                  return note.title.toLowerCase().contains(searchText.toLowerCase()) ||
                      note.description.toLowerCase().contains(searchText.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "You have not uploaded any notes yet.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final note = filtered[i];
                    final image = note.imageUrl ?? note.imagePath ?? "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              image,
                              height: 65,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  note.description,
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "₺${note.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black54),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/editNote",
                                arguments: note,
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // UPLOAD NOTE BUTTON
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/uploadNote");
              },
              child: Column(
                children: const [
                  Icon(Icons.cloud_upload, color: Colors.white, size: 42),
                  SizedBox(height: 4),
                  Text(
                    "Upload Note",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
