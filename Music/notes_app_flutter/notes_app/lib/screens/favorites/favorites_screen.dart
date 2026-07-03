import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../services/notes_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/note_card.dart';
import '../notes/note_detail_screen.dart';
import '../notes/create_note_screen.dart';
import '../notes/search_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final favorites = provider.favoriteNotes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER (Kani hadda waa fixed dusha sare) ==========
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        'Your favorite notes in one place',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9EAE),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: Color(0xFF1A1A2E)),
                    ),
                  ),
                ],
              ),
            ),

            // ========== ALL FAVORITES BANNER (Isna waa fixed) ==========
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('All Favorites',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF1A1A2E))),
                          Text('${favorites.length} notes',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF9E9EAE))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF9E9EAE)),
                  ],
                ),
              ),
            ),

            // ========== FAVORITE NOTES HEADER (Isna waa fixed) ==========
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Favorite Notes',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            // ========== KALIYA QAYBTAAN HOOSE AYAA SCROLL NOQONEYSA ==========
            Expanded(
              child: favorites.isEmpty
                  ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    // Empty State Main Message
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: const [
                            Icon(Icons.star_border_rounded,
                                size: 64, color: Color(0xFFCCCCDD)),
                            SizedBox(height: 16),
                            Text('No favorites yet',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9E9EAE))),
                            SizedBox(height: 8),
                            Text('Pin your important notes',
                                style: TextStyle(color: Color(0xFFCCCCDD))),
                          ],
                        ),
                      ),
                    ),

                    // Footer Message
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: const [
                          Icon(Icons.star_border_rounded,
                              size: 32, color: Color(0xFFCCCCDD)),
                          SizedBox(height: 8),
                          Text('Pin your important notes',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E))),
                          SizedBox(height: 4),
                          Text('Favorite notes you pin will appear here.',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF9E9EAE))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final note = favorites[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: NoteCard(
                      note: note,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailScreen(note: note),
                        ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}