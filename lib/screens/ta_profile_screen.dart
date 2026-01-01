import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_provider.dart';
import '../models/note_model.dart';

class TaProfileScreen extends StatelessWidget {
  const TaProfileScreen({super.key});

  Future<void> _editAboutDialog(
      BuildContext context, String userId, String currentAbout) async {
    final controller = TextEditingController(text: currentAbout);
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.grey[300] : Colors.grey[700];

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text('Edit About', style: TextStyle(color: textColor)),
          content: TextField(
            controller: controller,
            maxLines: 6,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Write something about yourself...',
              hintStyle: TextStyle(color: subtextColor),
              filled: true,
              fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: subtextColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    if (result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('About text cannot be empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {
          'about': result,
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final authProvider = context.watch<AuthProvider>();

    final isDark = themeProvider.isDarkMode;

    // Get arguments from navigation
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userId = args?['userId'] ?? '';
    final userName = args?['userName'] ?? 'Unknown User';

    final isOwnProfile =
        authProvider.userId != null && authProvider.userId == userId;

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
            padding: const EdgeInsets.only(
                top: 50, left: 16, right: 16, bottom: 20),
            color: AppColors.navy,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 32),
                ),
                Expanded(
                  child: Text(
                    'Profile/$userName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
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
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                        isDark ? Colors.grey[700] : Colors.grey[200],
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                isDark ? Colors.grey[850]! : Colors.white,
                                width: 2),
                          ),
                          child: const Icon(Icons.check,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('TA Profile',
                      style: TextStyle(color: AppColors.accent, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text('$userName@sabanciuniv.edu',
                      style: TextStyle(color: subtextColor)),

                  const SizedBox(height: 24),

                  // Stats Row - Stream user's notes to get real stats
                  StreamBuilder<List<NoteModel>>(
                    stream: notesProvider.getUserNotesStream(userId),
                    builder: (context, snapshot) {
                      final userNotes = snapshot.data ?? [];
                      final totalNotes = userNotes.length;

                      // ✅ Total Downloads (fallback'li)
                      int totalDownloads = 0;
                      for (final note in userNotes) {
                        int v = 0;

                        // NoteModel alanı: totalSells
                        try {
                          v = note.totalSells;
                        } catch (_) {
                          v = 0;
                        }

                        // Eğer modelde totalSells var ama bazen 0 geliyorsa / field farklıysa:
                        // (NoteModel içinde map yok, o yüzden burada sadece garantileme yapıyoruz.)
                        if (v < 0) v = 0;
                        totalDownloads += v;
                      }

                      // ✅ Total Review (yorumlardan rating ortalaması)
                      int ratingCount = 0;
                      int ratingSum = 0;

                      // Bu sayfada comments kısmını zaten firestore 'notes' collection'dan çekiyorsun.
                      // Aynı yerdeki field isimleriyle ratingleri hesaplamak için burada da notes collection'a bakıyoruz.
                      // (Sadece stats için)
                      //
                      // Not: getUserNotesStream NoteModel döndürüyor ama rating/comment listeleri modelde olmayabilir.
                      // Bu yüzden rating'i direkt firestore query ile almak en doğru yol.
                      //
                      // Aşağıdaki hesaplamayı "snapshot" üzerinden yapabilmek için bir nested stream kullanıyoruz.
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notes')
                            .where('createdBy', isEqualTo: userId)
                            .snapshots(),
                        builder: (context, notesSnap) {
                          if (notesSnap.hasData) {
                            for (final doc in notesSnap.data!.docs) {
                              final data = doc.data() as Map<String, dynamic>;

                              final rawComments = data['comments'] ??
                                  data['commentList'] ??
                                  data['reviews'] ??
                                  data['feedbacks'];

                              if (rawComments is List) {
                                for (final c in rawComments) {
                                  if (c is Map) {
                                    final cm = Map<String, dynamic>.from(c);

                                    dynamic rawRating = cm['rating'] ?? cm['stars'];

                                    int? r;
                                    if (rawRating is int) {
                                      r = rawRating;
                                    } else {
                                      r = int.tryParse('$rawRating');
                                    }

                                    if (r != null && r >= 1 && r <= 5) {
                                      ratingSum += r;
                                      ratingCount += 1;
                                    }
                                  }
                                }
                              }
                            }
                          }

                          final avgRating =
                          ratingCount == 0 ? 0.0 : (ratingSum / ratingCount);
                          final ratingText = '${avgRating.toStringAsFixed(1)}/5';

                          return Row(
                            children: [
                              _buildStatBox('Total\nReview', ratingText, Icons.star,
                                  isDark, cardColor, textColor),
                              const SizedBox(width: 12),
                              _buildStatBox(
                                  'Total\nDownloads',
                                  '$totalDownloads',
                                  Icons.download,
                                  isDark,
                                  cardColor,
                                  textColor),
                              const SizedBox(width: 12),
                              _buildStatBox('Total\nNotes', '$totalNotes',
                                  Icons.description, isDark, cardColor, textColor),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // About Yourself (per-user, editable for own profile)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String aboutText = 'No description yet.';
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.exists) {
                        final data =
                        snapshot.data!.data() as Map<String, dynamic>?;
                        final raw = data?['about'];
                        if (raw != null && raw.toString().trim().isNotEmpty) {
                          aboutText = raw.toString();
                        }
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? null
                              : [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('About Yourself:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textColor)),
                                const Spacer(),
                                if (isOwnProfile)
                                  IconButton(
                                    onPressed: () => _editAboutDialog(
                                      context,
                                      userId,
                                      aboutText == 'No description yet.'
                                          ? ''
                                          : aboutText,
                                    ),
                                    icon: Icon(Icons.edit,
                                        size: 20,
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors.navy),
                                    tooltip: 'Edit',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              aboutText,
                              style: TextStyle(color: subtextColor, height: 1.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Comments Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Comments:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notes')
                        .where('createdBy', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('Failed to load comments.',
                            style: TextStyle(color: subtextColor));
                      }

                      final commentItems = <Map<String, dynamic>>[];

                      for (final doc in snapshot.data?.docs ?? []) {
                        final data = doc.data() as Map<String, dynamic>;
                        final noteTitle =
                        (data['title'] ?? data['noteTitle'] ?? 'Untitled')
                            .toString();

                        final rawComments = data['comments'] ??
                            data['commentList'] ??
                            data['reviews'] ??
                            data['feedbacks'];

                        if (rawComments is List) {
                          for (final c in rawComments) {
                            if (c is Map) {
                              final cm = Map<String, dynamic>.from(c);
                              commentItems.add({
                                'noteTitle': noteTitle,
                                'name': (cm['name'] ??
                                    cm['userName'] ??
                                    cm['displayName'] ??
                                    'Anonymous')
                                    .toString(),
                                'text': (cm['text'] ??
                                    cm['comment'] ??
                                    cm['message'] ??
                                    '')
                                    .toString(),
                                'rating': cm['rating'] ?? cm['stars'],
                                'createdAt': cm['createdAt'] ??
                                    cm['time'] ??
                                    cm['timestamp'],
                              });
                            }
                          }
                        }
                      }

                      commentItems.sort((a, b) {
                        final aTime = _parseTimestamp(a['createdAt']);
                        final bTime = _parseTimestamp(b['createdAt']);

                        if (aTime == null && bTime == null) return 0;
                        if (aTime == null) return 1;
                        if (bTime == null) return -1;
                        return bTime.compareTo(aTime);
                      });

                      if (commentItems.isEmpty) {
                        return Text('No comments yet.',
                            style: TextStyle(color: subtextColor));
                      }

                      return Column(
                        children: commentItems.map((c) {
                          final rating = c['rating'] is int
                              ? c['rating'] as int
                              : int.tryParse('${c['rating']}');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildComment(
                              c['name'] as String,
                              c['noteTitle'] as String,
                              c['text'] as String,
                              rating,
                              isDark,
                              cardColor,
                              textColor,
                              subtextColor,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, bool isDark,
      Color cardColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon,
                    color: isDark ? Colors.white70 : AppColors.navy, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: textColor)),
          ],
        ),
      ),
    );
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;

      final asInt = int.tryParse(value);
      if (asInt != null) {
        if (asInt > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(asInt);
        }
        return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
      }
    }

    return null;
  }

  Widget _buildComment(
      String name,
      String noteTitle,
      String text,
      int? rating,
      bool isDark,
      Color cardColor,
      Color textColor,
      Color subtextColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark ? Colors.grey[700] : null,
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 2),
                Text(noteTitle,
                    style: TextStyle(color: subtextColor, fontSize: 12)),
                const SizedBox(height: 8),
                Text(text, style: TextStyle(color: subtextColor)),
                if (rating != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      5,
                          (i) => Icon(
                        Icons.star,
                        color: i < rating
                            ? AppColors.star
                            : (isDark ? Colors.grey[700] : Colors.grey[300]),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
