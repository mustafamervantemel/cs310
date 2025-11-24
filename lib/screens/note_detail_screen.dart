// FILE: lib/screens/note_detail_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../utils/app_colors.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeScreen'den arguments olarak NoteModel yollamıştık
    final NoteModel note =
    ModalRoute.of(context)!.settings.arguments as NoteModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/checkout');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst bilgi kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Course: ${note.courseCode}'),
                  Text('Instructor: ${note.instructor}'),
                  const SizedBox(height: 4),
                  Text(
                    'Price: ₺${note.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TA bilgisi
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.taName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${note.taRole} · ${note.courseCode}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/taProfile');
                  },
                  child: const Text('View Profile'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Comments:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // Basit comment kartları (widget gibi gözüksün diye)
            Column(
              children: const [
                _CommentTile(
                  name: 'Selin Delikaya',
                  comment: 'Very helpful notes!',
                ),
                SizedBox(height: 6),
                _CommentTile(
                  name: 'Mert Yılmaz',
                  comment: 'Clear explanations and perfect summaries.',
                ),
                SizedBox(height: 6),
                _CommentTile(
                  name: 'Ayşe Karaca',
                  comment: 'Helped me a lot before the quiz!',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Add to Cart butonu (sadece snackbar, repo yok!)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '"${note.title}" added to cart (demo – no backend).'),
                    ),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ),

            const SizedBox(height: 16),

            // PREVIEW TITLE
            const Text(
              'Preview',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

// PREVIEW BOX (blurred if exists)
            GestureDetector(
              onTap: () {
                if (note.imagePath == null || note.imagePath!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preview image is not available.'),
                    ),
                  );
                  return;
                }

                // POPUP – net görüntü + açıklama
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Preview – First Page',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Açıklama
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              note.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // NET GÖRÜNTÜ
                          Flexible(
                            child: InteractiveViewer(
                              child: Image.file(
                                File(note.imagePath!),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                  image: note.imagePath != null && note.imagePath!.isNotEmpty
                      ? DecorationImage(
                    image: FileImage(File(note.imagePath!)),
                    fit: BoxFit.cover,
                    // ❗️BULANIKLIK BURADA
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  )
                      : null,
                ),
                child: const Center(
                  child: Text(
                    'Tap to Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Küçük comment kartı widget'ı
class _CommentTile extends StatelessWidget {
  final String name;
  final String comment;

  const _CommentTile({
    required this.name,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
