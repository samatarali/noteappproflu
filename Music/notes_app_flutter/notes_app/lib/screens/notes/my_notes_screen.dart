import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../services/notes_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/note_card.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';

class MyNotesScreen extends StatefulWidget {
  const MyNotesScreen({super.key});

  @override
  State<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends State<MyNotesScreen> {
  String selectedCategory = 'All';

  // Midabada gaarka ah ee qayb kasta (Category Colors)
  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.primary;

    switch (category.toLowerCase()) {
      case 'personal':
        return const Color(0xFF2196F3); // Blue
      case 'work':
        return const Color(0xFF4CAF50); // Green
      case 'study':
        return const Color(0xFFFF6B6B); // Red
      case 'ideas':
        return const Color(0xFFFFA726); // Orange
      default:
        return AppColors.primary; // Main Theme Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final allNotes = provider.notes;

    // Sifaynta qoraalada iyadoo laga ilaalinayo Null Errors
    final filteredNotes = allNotes.where((note) {
      if (selectedCategory == 'All') return true;
      if (note.category == null) return false;

      final noteStyle = note.category.toString().split('.').last.toLowerCase();
      return noteStyle == selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // ========== HEADERKAAN MARNABA MEESHA KAMA BAXAYO ==========
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Notes',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          // Badhan muujinaya tirada qoraalada category-ga la doortay
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(selectedCategory).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$selectedCategory: ${filteredNotes.length}',
              style: TextStyle(
                color: _getCategoryColor(selectedCategory),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== BADHAMADA QAYBAHA (Kuwani hadda dusha ayay ku dheggan yihiin) ==========
            Container(
              height: 46,
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Personal'),
                  _buildFilterChip('Work'),
                  _buildFilterChip('Study'),
                  _buildFilterChip('Ideas'),
                ],
              ),
            ),

            // ========== KALIYA REFRESH IYO LIISKA QORAALADA AYAA SCROLL NOQONAYA ==========
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.loadNotes(),
                color: AppColors.primary,
                child: provider.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                    : filteredNotes.isEmpty
                    ? _buildEmptyState(context, provider)
                    : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final noteCategoryStr = note.category?.toString().split('.').last ?? 'All';
                    final categoryColor = _getCategoryColor(noteCategoryStr);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(color: categoryColor, width: 5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A1A2E).withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
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
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
        ).then((_) => provider.loadNotes()),
        backgroundColor: _getCategoryColor(selectedCategory),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'New Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  // Badhamada Sifaynta (Chips)
  Widget _buildFilterChip(String label) {
    final isSelected = selectedCategory == label;
    final activeColor = _getCategoryColor(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFEAEAEA),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6E6E82),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // Muqaalka marka qoraal la waayo (Empty State)
  Widget _buildEmptyState(BuildContext context, NotesProvider provider) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)
                  ],
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 44,
                  color: _getCategoryColor(selectedCategory).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                selectedCategory == 'All' ? 'Lama helo wax qoraal ah' : 'Ma laha qoraal $selectedCategory ah',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              Text(
                'Riix badhanka hoose si aad u qorto qoraal cusub oo ah $selectedCategory.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF9E9EAE), height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
                ).then((_) => provider.loadNotes()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getCategoryColor(selectedCategory),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Abuur Qoraal', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}