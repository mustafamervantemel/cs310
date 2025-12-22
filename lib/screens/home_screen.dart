import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'CS204', 'icon': Icons.computer, 'color': AppColors.categoryBlue},
    {'name': 'MATH306', 'icon': Icons.calculate, 'color': AppColors.categoryPurple},
    {'name': 'HIST191', 'icon': Icons.history_edu, 'color': AppColors.categoryOrange},
    {'name': 'ECON201', 'icon': Icons.attach_money, 'color': AppColors.categoryGreen},
    {'name': 'CS310', 'icon': Icons.phone_android, 'color': AppColors.categoryCyan},
    {'name': 'NS101', 'icon': Icons.science, 'color': AppColors.categoryPink},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(NoteModel note) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return note.courseCode.toLowerCase().contains(q) ||
        note.title.toLowerCase().contains(q) ||
        note.description.toLowerCase().contains(q);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/searchResults');
        break;
      case 2:
        Navigator.pushNamed(context, '/uploadNote');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    // Theme-aware colors
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.navy;
    final subtextColor = isDark ? Colors.grey[400] : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
            decoration: const BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Top Row
                Row(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Welcome Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authProvider.userEmail?.split('@').first ?? 'Student',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cart Icon
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/checkout'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by course, keyword or week...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    suffixIcon: const Icon(Icons.search, color: AppColors.navy),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchQuery = category['name'];
                            _searchController.text = category['name'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark ? null : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: category['color'],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  category['icon'],
                                  color: isDark ? Colors.white : AppColors.navy,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                category['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: subtextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Best Sellers / Notes from Firebase
                  Text(
                    'Best Sellers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // StreamBuilder for real-time notes
                  StreamBuilder<List<NoteModel>>(
                    stream: notesProvider.getNotesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text('Error: ${snapshot.error}'),
                              ],
                            ),
                          ),
                        );
                      }

                      final allNotes = snapshot.data ?? [];
                      final notes = allNotes.where(_matchesSearch).toList();

                      if (notes.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No notes yet.\nUpload your first note!'
                                      : 'No notes match "$_searchQuery"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return _buildNoteCard(note, isDark, cardColor, textColor, subtextColor!);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColors.navy,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud_upload_outlined),
                label: 'Upload',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, bool isDark, Color cardColor, Color textColor, Color subtextColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/noteDetail', arguments: note);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getCategoryColor(note.courseCode),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(note.courseCode),
                size: 36,
                color: isDark ? Colors.white : AppColors.navy,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${note.courseCode} - ${note.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.description,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.star, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${note.stars} STARS',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₺${note.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String courseCode) {
    if (courseCode.startsWith('CS')) return AppColors.categoryBlue;
    if (courseCode.startsWith('MATH')) return AppColors.categoryPurple;
    if (courseCode.startsWith('HIST')) return AppColors.categoryOrange;
    if (courseCode.startsWith('ECON')) return AppColors.categoryGreen;
    if (courseCode.startsWith('NS')) return AppColors.categoryPink;
    return AppColors.categoryCyan;
  }

  IconData _getCategoryIcon(String courseCode) {
    if (courseCode.startsWith('CS')) return Icons.computer;
    if (courseCode.startsWith('MATH')) return Icons.calculate;
    if (courseCode.startsWith('HIST')) return Icons.history_edu;
    if (courseCode.startsWith('ECON')) return Icons.attach_money;
    if (courseCode.startsWith('NS')) return Icons.science;
    return Icons.book;
  }
}
