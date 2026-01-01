import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';

class UploadedNotesScreen extends StatelessWidget {
  const UploadedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final userId = authProvider.userId;
    
    final isDark = themeProvider.isDarkMode;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.navy;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white.withOpacity(0.95);

    return Scaffold(
      backgroundColor: bgColor,
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

            

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [Text('Uploaded Notes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.keyboard_arrow_down, color: Colors.white)]),
            ),

            const SizedBox(height: 16),

            // Notes List
            Expanded(
              child: StreamBuilder<List<NoteModel>>(
                stream: notesProvider.getUserNotesStream(userId ?? ''),
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
                          Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No uploaded notes yet', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) => _buildNoteCard(context, notes[index], isDark, cardColor),
                  );
                },
              ),
            ),

            // Upload Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/uploadNote'),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 8),
                    const Text('Upload note', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note, bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 70, 
            height: 70, 
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : AppColors.categoryBlue, 
              borderRadius: BorderRadius.circular(12),
            ), 
            child: Icon(Icons.description, color: isDark ? Colors.white : AppColors.navy, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${note.courseCode} - ${note.title}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.coral)),
                const SizedBox(height: 4),
                Text(note.description, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/editNote', arguments: note),
                      child: Row(children: [Icon(Icons.edit, size: 14, color: AppColors.coral), const SizedBox(width: 4), Text('Edit', style: TextStyle(color: AppColors.coral, fontSize: 12))]),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _deleteNote(context, note),
                      child: Row(children: [const Icon(Icons.delete, size: 14, color: Colors.red), const SizedBox(width: 4), const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12))]),
                    ),
                    const Spacer(),
                    Text('₺${note.price.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.coral)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(BuildContext context, NoteModel note) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Note'), content: const Text('Are you sure you want to delete this note?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red)))]));
    if (confirm == true) {
      await context.read<FirestoreService>().deleteNote(note.id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted'), backgroundColor: AppColors.success));
    }
  }
}
