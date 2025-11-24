import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/comment_card.dart';
import '../widgets/stat_info_card.dart';

class TaProfileScreen extends StatelessWidget {
  const TaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aboutText =
        "I'm a Computer Science student passionate about creating efficient, "
        "reliable, and user-friendly software solutions. I enjoy frontend/backend, "
        "learning new technologies, and building apps. My goal is to improve and "
        "contribute to meaningful projects.";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Profile/Mervan Çelebi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage('https://picsum.photos/200'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mervan Çelebi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Mervan.celebi@sabanciuniv.edu',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: const [
                StatInfoCard(
                  icon: Icons.star,
                  title: 'Total Review',
                  value: '4.1/5',
                ),
                StatInfoCard(
                  icon: Icons.download,
                  title: 'Total Downloads',
                  value: '247',
                ),
                StatInfoCard(
                  icon: Icons.note,
                  title: 'Total Notes',
                  value: '17',
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                aboutText,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Comments:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            const CommentCard(
              avatarUrl: 'https://picsum.photos/201',
              name: 'Ahmet Pek',
              comment: 'Great TA, explains things clearly!',
              starCount: 5,
            ),
          ],
        ),
      ),
    );
  }
}
