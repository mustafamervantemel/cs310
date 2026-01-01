import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<void> _editAboutDialog(BuildContext context, String userId, String currentAbout) async {
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final controller = TextEditingController(text: currentAbout);

    final bg = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final sub = isDark ? Colors.grey[300] : Colors.grey[700];

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bg,
          title: Text('Edit About', style: TextStyle(color: textColor)),
          content: TextField(
            controller: controller,
            maxLines: 6,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Write something about yourself...',
              hintStyle: TextStyle(color: sub),
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
              child: Text('Cancel', style: TextStyle(color: sub)),
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
          duration: Duration(seconds: 2),
        ),
      );
      // ✅ snackbar sonrası takılma olmasın diye dialog zaten kapandı; burada sadece return ediyoruz
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
          content: Text('About updated'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ snackbar gösterildi, UI zaten StreamBuilder ile güncellenecek; burada ekstra beklemeye gerek yok
      return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final isDark = themeProvider.isDarkMode;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    final email = authProvider.userEmail ?? 'user@sabanciuniv.edu';
    final name = email.split('@').first.toUpperCase();
    final userId = authProvider.userId;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(isDark, context), // ✅ header'a back tuşu eklendi
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildAvatar(isDark),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(fontSize: 14, color: subtextColor)),

                  const SizedBox(height: 24),

                  _buildStatsRow(context, isDark, cardColor), // ✅ kartlar artık tıklanabilir

                  const SizedBox(height: 20),

                  // ✅ About Yourself (editable from Profile tab)
                  if (userId == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Login to edit your profile info.',
                        style: TextStyle(color: subtextColor),
                      ),
                    )
                  else
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                      builder: (context, snap) {
                        String aboutText = '';
                        if (snap.hasData && snap.data != null && snap.data!.exists) {
                          final data = snap.data!.data() as Map<String, dynamic>?;
                          final raw = data?['about'];
                          if (raw != null) aboutText = raw.toString();
                        }

                        final shownText = aboutText.trim().isEmpty
                            ? 'Tap the edit button to add your description.'
                            : aboutText;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark
                                ? null
                                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'About Yourself:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => _editAboutDialog(
                                      context,
                                      userId,
                                      aboutText.trim().isEmpty ? '' : aboutText,
                                    ),
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: isDark ? Colors.white70 : AppColors.navy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                shownText,
                                style: TextStyle(color: subtextColor, height: 1.5),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  _buildSettingsSection(
                    context,
                    authProvider,
                    themeProvider,
                    isDark,
                    cardColor,
                    textColor,
                    subtextColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Back tuşu eklendi (mevcut UI bozulmadan)
  Widget _buildHeader(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 6, right: 6),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
          child: const Icon(Icons.person, size: 55, color: Colors.white),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.grey[900]! : Colors.white, width: 2),
            ),
            child: const Icon(Icons.edit, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDark, Color cardColor) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            'Purchased Notes',
            Icons.shopping_bag,
            cardColor,
            isDark,
            '/purchasedNotes',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            context,
            'Uploaded Notes',
            Icons.cloud_upload,
            cardColor,
            isDark,
            '/uploadedNotes',
          ),
        ),
      ],
    );
  }

  // ✅ onTap eklendi, UI aynı kaldı
  Widget _statCard(
      BuildContext context,
      String title,
      IconData icon,
      Color cardColor,
      bool isDark,
      String routeName,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent.withOpacity(0.15),
              child: Icon(icon, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.navy),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context,
      AuthProvider authProvider,
      ThemeProvider themeProvider,
      bool isDark,
      Color cardColor,
      Color textColor,
      Color subtextColor,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General Settings',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subtextColor),
          ),
          const SizedBox(height: 16),
          _buildTile(
            Icons.dark_mode_outlined,
            'Dark Mode',
            textColor,
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: AppColors.accent,
            ),
          ),
          Divider(height: 24, color: isDark ? Colors.grey[700] : null),
          _buildTile(
            Icons.phone_android,
            'About App',
            textColor,
            onTap: () => _showAbout(context),
          ),
          Divider(height: 24, color: isDark ? Colors.grey[700] : null),
          _buildTile(
            Icons.logout,
            'Log Out',
            AppColors.coral,
            onTap: () => _logout(context, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
      IconData icon,
      String title,
      Color titleColor, {
        VoidCallback? onTap,
        Widget? trailing,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: titleColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
            ),
            if (trailing != null) trailing else const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About App'),
        content: const Text('SuNote - CS310 Project'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authProvider.signOut();

      // ✅ logout snackbar + sonra route reset
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.success,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
      }
    }
  }
}
