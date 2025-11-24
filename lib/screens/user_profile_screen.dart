import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/stat_info_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _selectedLanguage = 'English';

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About SuNote'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'SuNote is a course-based note sharing app designed for '
                      'Sabancı University students. You can search, upload, '
                      'and purchase lecture notes prepared by other students.',
                ),
                SizedBox(height: 12),
                Text(
                  'This user interface is implemented for CS310 – Phase 2 / 2.2.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'It demonstrates required UI features such as:\n'
                      '• Named routes between all screens\n'
                      '• Utility classes for shared colors and styles\n'
                      '• Asset and network images\n'
                      '• Custom styled cards and lists (with remove actions)\n'
                      '• Forms with validation and AlertDialogs\n'
                      '• Responsive layouts using flexible widgets\n'
                      '• Login / signup flow before accessing the main app.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        String tempSelection = _selectedLanguage;

        return AlertDialog(
          title: const Text('Choose Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: tempSelection,
                onChanged: (value) {
                  setState(() {
                    tempSelection = value ?? 'English';
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Türkçe'),
                value: 'Turkish',
                groupValue: tempSelection,
                onChanged: (value) {
                  setState(() {
                    tempSelection = value ?? 'Turkish';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedLanguage = tempSelection;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'In this prototype, password changes are not implemented.\n\n'
              'In a real app, this would open a secure password change form '
              'or send a reset link to your Sabancı email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out from SuNote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              // Clear navigation stack and go to login screen.
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE HEADER
            Center(
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://picsum.photos/210'),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ILGIN PUHUR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ilgin.puhur@sabanciuniv.edu',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STATS CARDS
            Row(
              children: const [
                StatInfoCard(
                  icon: Icons.shopping_bag,
                  title: 'Purchased Notes',
                  value: '12',
                ),
                StatInfoCard(
                  icon: Icons.upload_file,
                  title: 'Uploaded Notes',
                  value: '4',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ABOUT YOURSELF SECTION
            const Text(
              'About Yourself:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.greyCard.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tell others about yourself...',
                style: TextStyle(fontSize: 13),
              ),
            ),

            const SizedBox(height: 24),

            // GENERAL SETTINGS TITLE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey.shade200,
              child: const Text(
                '  General Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // SETTINGS MENU LIST
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('About App'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showAboutDialog,
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Text('Current: $_selectedLanguage'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showLanguageDialog,
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showChangePasswordDialog,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
