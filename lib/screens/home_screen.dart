// FILE: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late final NoteRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = NoteRepository.instance;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('SuNote'),
        actions: [
          // Sağ üst: Sepet ikonu
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/checkout');
            },
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search notes by course (e.g. CS204, NS102...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Popular Notes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// Dinamik + filtrelenmiş not listesi
          Expanded(
            child: ValueListenableBuilder<List<NoteModel>>(
              valueListenable: _repo.notes,
              builder: (context, allNotes, _) {
                final notes =
                allNotes.where(_matchesSearch).toList(growable: false);

                if (notes.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No notes yet. Upload your first note!'
                          : 'No notes match your search.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/noteDetail',
                            arguments: note,
                          );
                        },
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          note.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('₺${note.price.toStringAsFixed(0)}'),
                            const SizedBox(height: 4),
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// Bottom bar: Home / Upload / Profile
          Container(
            padding:
            const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Zaten Home'dayız
                    },
                    child: const Text('Home'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/uploadNote');
                    },
                    child: const Text('Upload'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: const Text('Profile'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
