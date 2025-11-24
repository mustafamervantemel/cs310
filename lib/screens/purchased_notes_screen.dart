// FILE: lib/screens/purchased_notes_screen.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';

class PurchasedNotesScreen extends StatefulWidget {
  const PurchasedNotesScreen({super.key});

  @override
  State<PurchasedNotesScreen> createState() => _PurchasedNotesScreenState();
}

class _PurchasedNotesScreenState extends State<PurchasedNotesScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final repo = NoteRepository.instance;
    final purchased = repo.purchasedNotes;

    final filtered = purchased.where((note) {
      return note.title.toLowerCase().contains(searchText.toLowerCase()) ||
          note.instructor.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF101733),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101733),
        elevation: 0,
        title: const Text(
          "Purchased Notes",
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
            child: filtered.isEmpty
                ? const Center(
              child: Text(
                "No purchased notes yet.",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final note = filtered[i];

                final image = note.imageUrl ?? note.imagePath ?? "";

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/noteDetail",
                      arguments: note.id,
                    );
                  },
                  child: Container(
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
                            height: 70,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // TEXT INFO
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
                              const SizedBox(height: 4),
                              Text(
                                note.instructor,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "₺${note.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
