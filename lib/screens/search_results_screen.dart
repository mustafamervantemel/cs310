// FILE: lib/screens/search_results_screen.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_repository.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _searchText = '';
  String _selectedCourse = 'All';

  @override
  Widget build(BuildContext context) {
    final repo = NoteRepository.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCourse,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'CS204', child: Text('CS204')),
                    DropdownMenuItem(value: 'NS102', child: Text('NS102')),
                    DropdownMenuItem(value: 'MATH306', child: Text('MATH306')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCourse = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<NoteModel>>(
              valueListenable: repo.notes,
              builder: (context, notes, _) {
                final filtered = notes.where((n) {
                  final matchText = _searchText.isEmpty ||
                      n.title.toLowerCase().contains(_searchText) ||
                      n.courseCode.toLowerCase().contains(_searchText);
                  final matchCourse = _selectedCourse == 'All' ||
                      n.courseCode == _selectedCourse;
                  return matchText && matchCourse;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No results.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final note = filtered[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(
                        note.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text('₺${note.price.toStringAsFixed(0)}'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/noteDetail',
                          arguments: note,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
