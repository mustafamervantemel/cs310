import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'CS', 'MATH', 'HIST', 'ECON', 'NS'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(NoteModel note) {
    if (_searchQuery.isEmpty && _selectedCategory == 'All') return true;
    
    bool matchesQuery = _searchQuery.isEmpty ||
        note.courseCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.description.toLowerCase().contains(_searchQuery.toLowerCase());

    bool matchesCategory = _selectedCategory == 'All' ||
        note.courseCode.toUpperCase().startsWith(_selectedCategory);

    return matchesQuery && matchesCategory;
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            color: AppColors.navy,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by course, keyword or week...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox(),
                    isDense: true,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val ?? 'All'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Results List
          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream: notesProvider.getNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allNotes = snapshot.data ?? [];
                final notes = allNotes.where(_matchesSearch).toList();

                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No notes found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) => _buildNoteCard(notes[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/noteDetail', arguments: note),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Row(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.categoryBlue, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description, color: AppColors.navy, size: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${note.courseCode} - ${note.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(note.description, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('₺${note.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                      const SizedBox(width: 12),
                      Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.shopping_cart, color: Colors.white, size: 16)),
                      const Spacer(),
                      const Icon(Icons.star, color: AppColors.star, size: 16),
                      Text(' ${note.stars}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 2) Navigator.pushNamed(context, '/uploadNote');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload_outlined), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
