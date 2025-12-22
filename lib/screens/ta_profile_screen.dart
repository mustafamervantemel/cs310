import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';

class TaProfileScreen extends StatelessWidget {
  const TaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final isDark = themeProvider.isDarkMode;
    
    // Get arguments from navigation
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userId = args?['userId'] ?? '';
    final userName = args?['userName'] ?? 'Unknown User';
    
    // Theme-aware colors
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            color: AppColors.navy,
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32)),
                Expanded(child: Text('Profile/$userName', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Photo
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50, 
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey, 
                        child: const Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.grey[850]! : Colors.white, width: 2)),
                          child: const Icon(Icons.check, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('TA Profile', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text('$userName@sabanciuniv.edu', style: TextStyle(color: subtextColor)),

                  const SizedBox(height: 24),

                  // Stats Row - Stream user's notes to get real stats
                  StreamBuilder<List<NoteModel>>(
                    stream: notesProvider.getUserNotesStream(userId),
                    builder: (context, snapshot) {
                      final userNotes = snapshot.data ?? [];
                      final totalNotes = userNotes.length;
                      final totalDownloads = userNotes.fold<int>(0, (sum, note) => sum + note.totalSells);
                      
                      return Row(
                        children: [
                          _buildStatBox('Total\nReview', '4.1/5', Icons.star, isDark, cardColor, textColor),
                          const SizedBox(width: 12),
                          _buildStatBox('Total\nDownloads', '$totalDownloads', Icons.download, isDark, cardColor, textColor),
                          const SizedBox(width: 12),
                          _buildStatBox('Total\nNotes', '$totalNotes', Icons.description, isDark, cardColor, textColor),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : AppColors.categoryBlue, 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About Yourself:', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 12),
                        Text(
                          "I'm a Computer Science student passionate about creating efficient, reliable, and user-friendly software solutions. I enjoy working on both frontend and backend development, learning new technologies, and turning ideas into real, functional applications.",
                          style: TextStyle(color: subtextColor, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comments Section
                  Align(alignment: Alignment.centerLeft, child: Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
                  const SizedBox(height: 16),
                  _buildComment('Ahmet P.', 'Great notes, very helpful!', isDark, cardColor, textColor, subtextColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, bool isDark, Color cardColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor, 
          borderRadius: BorderRadius.circular(12), 
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(children: [
              Icon(icon, color: isDark ? Colors.white70 : AppColors.navy, size: 18), 
              const SizedBox(width: 6), 
              Flexible(child: Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey))),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(6)), 
              child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment(String name, String text, bool isDark, Color cardColor, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: isDark ? Colors.grey[700] : null, child: const Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)), 
            const SizedBox(height: 4), 
            Text(text, style: TextStyle(color: subtextColor)),
          ])),
        ],
      ),
    );
  }
}
