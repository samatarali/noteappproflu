import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notes_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/note_card.dart';
import 'note_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    context.read<NotesProvider>().clearSearch();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final results = provider.notes;

    return Scaffold(
      backgroundColor: Colors.white,
      // 1. APP BAR QURUXDAN (Nadiif ah)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.black),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            tooltip: "Back Home",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 2. SEARCH BAR-KA OO QURUXDAN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4), // Google-style grey
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() => _hasSearched = true);
                    provider.search(value);
                  }
                },
              ),
            ),
          ),

          // 3. BODY: MUUQAALKA XOGTA
          Expanded(
            child: !_hasSearched
                ? _buildEmptyState() // Halkan waa "Blank Canvas"
                : results.isEmpty
                ? const Center(child: Text("No results found"))
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final note = results[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NoteCard(
                    note: note,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
                    ),
                    onPin: () => provider.togglePin(note),
                    onFavorite: () => provider.toggleFavorite(note),
                    onDelete: () => provider.trashNote(note),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget-ka nadiifka ah ee "Madax xanuunka" ka ilaalinaya user-ka
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes_rounded, size: 60, color: Color(0xFFDADCE0)),
          SizedBox(height: 16),
          Text(
            "Ready to search?",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}