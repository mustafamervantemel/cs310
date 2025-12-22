import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_provider.dart';

class PurchasedNotesScreen extends StatelessWidget {
  const PurchasedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.userId;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32)),
                  const Spacer(),
                  Text(authProvider.userEmail?.split('@').first ?? 'User', style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [Text('SEARCH', style: TextStyle(color: Colors.white70)), Spacer(), Icon(Icons.search, color: Colors.white70)]),
              ),
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [Text('Purchased Notes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.keyboard_arrow_down, color: Colors.white)]),
            ),

            const SizedBox(height: 16),

            // Notes List
            Expanded(
              child: StreamBuilder<List<NoteModel>>(
                stream: notesProvider.getPurchasedNotesStream(userId ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final notes = snapshot.data ?? [];

                  if (notes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No purchased notes yet', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                            child: const Text('Browse Notes', style: TextStyle(color: AppColors.accent)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) => _buildNoteCard(context, notes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/noteDetail', arguments: note),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.categoryBlue, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description, color: AppColors.navy, size: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${note.courseCode} - ${note.title}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                  const SizedBox(height: 4),
                  Text(note.createdBy, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 16), const SizedBox(width: 4), const Text('Purchased', style: TextStyle(color: AppColors.success, fontSize: 12))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
