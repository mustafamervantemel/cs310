import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../utils/app_colors.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteModel note =
    ModalRoute.of(context)!.settings.arguments as NoteModel;

    /// Web ve Mobil için çalışan preview görseli seç
    String? previewImage = kIsWeb ? note.imageUrl : note.imagePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/checkout'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // CARD
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
                  Text(note.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Course: ${note.courseCode}"),
                  Text("Instructor: ${note.instructor}"),
                  const SizedBox(height: 4),
                  Text("Price: ₺${note.price.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TA
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage("https://picsum.photos/200"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.taName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text("${note.taRole} · ${note.courseCode}",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/taProfile');
                  },
                  child: const Text("View Profile"),
                )
              ],
            ),

            const SizedBox(height: 16),

            // ADD TO CART
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('"${note.title}" added to cart.')));
                },
                child: const Text("Add to Cart"),
              ),
            ),

            const SizedBox(height: 16),

            const Text("Preview",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),

            // TAP TO PREVIEW AREA
            GestureDetector(
              onTap: () {
                if (previewImage == null || previewImage.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Preview image not available"),
                  ));
                  return;
                }

                showDialog(
                  context: context,
                  builder: (_) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text("Preview – First Page",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),

                          // EXPLANATION
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              note.description,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // IMAGE INSIDE POPUP (WEB + MOBILE)
                          SizedBox(
                            height: 400,
                            child: InteractiveViewer(
                              child: kIsWeb
                                  ? Image.network(previewImage!, fit: BoxFit.cover)
                                  : Image.file(File(previewImage!), fit: BoxFit.cover),
                            ),
                          ),

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          )
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
                  color: Colors.grey.shade400,
                  image: previewImage != null
                      ? DecorationImage(
                    image: kIsWeb
                        ? NetworkImage(previewImage!)
                        : FileImage(File(previewImage!)) as ImageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  )
                      : null,
                ),
                child: const Center(
                  child: Text(
                    "Tap to Preview",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
