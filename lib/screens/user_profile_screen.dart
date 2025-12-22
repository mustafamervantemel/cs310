import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final email = authProvider.userEmail ?? 'user@sabanciuniv.edu';
    final name = email.split('@').first.toUpperCase();
    
    final isDark = themeProvider.isDarkMode;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildAvatar(isDark),
                  const SizedBox(height: 16),
                  Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(fontSize: 14, color: subtextColor)),
                  const SizedBox(height: 24),
                  _buildStatsRow(context, isDark, cardColor),
                  const SizedBox(height: 32),
                  _buildSettingsSection(context, authProvider, themeProvider, isDark, cardColor, textColor, subtextColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32)),
            const Expanded(child: Text('Profile', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Stack(
      children: [
        CircleAvatar(radius: 50, backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300], child: const Icon(Icons.person, size: 50, color: Colors.white)),
        Positioned(
          bottom: 0, right: 0,
          child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: const Icon(Icons.edit, size: 16, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDark, Color cardColor) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Purchased Notes', Icons.shopping_bag, () => Navigator.pushNamed(context, '/purchasedNotes'), isDark, cardColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Uploaded Notes', Icons.cloud_upload, () => Navigator.pushNamed(context, '/uploadedNotes'), isDark, cardColor)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, IconData icon, VoidCallback onTap, bool isDark, Color cardColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor, 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.coral.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.coral)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider, ThemeProvider themeProvider, bool isDark, Color cardColor, Color textColor, Color subtextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('General Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subtextColor)),
          const SizedBox(height: 16),
          _buildTile(Icons.dark_mode_outlined, 'Dark Mode', textColor, trailing: Switch(value: themeProvider.isDarkMode, onChanged: (_) => themeProvider.toggleTheme(), activeColor: AppColors.accent)),
          Divider(height: 24, color: isDark ? Colors.grey[700] : null),
          _buildTile(Icons.phone_android, 'About App', textColor, onTap: () => _showAbout(context)),
          Divider(height: 24, color: isDark ? Colors.grey[700] : null),
          _buildTile(Icons.logout, 'Log Out', textColor, textColor: AppColors.coral, onTap: () => _logout(context, authProvider)),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, Color defaultTextColor, {Widget? trailing, VoidCallback? onTap, Color? textColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: textColor ?? defaultTextColor, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? defaultTextColor))),
          trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('SuNote'), content: const Text('Version 1.0.0\n\nCS310 Mobile App Development Project\nSabancı University'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]));
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Log Out'), content: const Text('Are you sure?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log Out', style: TextStyle(color: AppColors.coral)))]));
    if (confirm == true && context.mounted) {
      await authProvider.signOut();
      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
  }
}
