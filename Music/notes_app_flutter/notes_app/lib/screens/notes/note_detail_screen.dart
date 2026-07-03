import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../services/notes_provider.dart';
import '../../utils/app_theme.dart';
import 'create_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    // Waxaan u beddelnay 'watch' si UI-gu toos u isbeddelo marka Pin ama Favorite la riixo
    final provider = context.watch<NotesProvider>();

    // Si loogu raadeeyo isbeddelada hadda dhacaya ee note-ka dhexdiisa ah
    final liveNote = provider.notes.firstWhere(
          (n) => n.id == note.id,
      orElse: () => note,
    );

    final dateStr = DateFormat('MMMM d, yyyy • h:mm a').format(liveNote.updatedAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A1A2E)),
        ),
        title: const Text(
          'Note Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        actions: [
          // ========== PIN BUTTON ==========
          IconButton(
            onPressed: () => provider.togglePin(liveNote),
            icon: Icon(
              liveNote.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: liveNote.isPinned ? AppColors.primary : const Color(0xFF9E9EAE),
              size: 22,
            ),
          ),
          // ========== FAVORITE BUTTON ==========
          IconButton(
            onPressed: () => provider.toggleFavorite(liveNote),
            icon: Icon(
              liveNote.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: liveNote.isFavorite ? const Color(0xFFFFA726) : const Color(0xFF9E9EAE),
              size: 22,
            ),
          ),
          // ========== EDIT BUTTON ==========
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateNoteScreen(existingNote: liveNote),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 22),
          ),
          // ========== DELETE (TRASH) BUTTON ==========
          IconButton(
            onPressed: () => _showDeleteDialog(context, provider, liveNote),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: liveNote.category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(liveNote.category.icon, color: liveNote.category.color, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          liveNote.category.name,
                          style: TextStyle(
                            color: liveNote.category.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    liveNote.title.isEmpty ? 'Untitled Note' : liveNote.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Date
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9EAE),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFEEEEEE)),
                  ),

                  // Content
                  Text(
                    liveNote.content.isEmpty ? 'No content...' : liveNote.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                      height: 1.7,
                    ),
                  ),

                  // Tags
                  if (liveNote.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: liveNote.tags
                          .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Quick Access Navigation
          _buildQuickAccess(context),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickAccessItem(context, Icons.home_rounded, 'Home'),
              _quickAccessItem(context, Icons.star_outline_rounded, 'Favorites'),
              _quickAccessItem(context, Icons.add_circle_rounded, 'Create'),
              _quickAccessItem(context, Icons.folder_outlined, 'Categories'),
              _quickAccessItem(context, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAccessItem(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (label == 'Favorites') {
          Navigator.pushReplacementNamed(context, '/favorites');
        } else if (label == 'Create') {
          Navigator.pushReplacementNamed(context, '/create');
        } else if (label == 'Categories') {
          Navigator.pushReplacementNamed(context, '/categories');
        } else if (label == 'Settings') {
          Navigator.pushReplacementNamed(context, '/settings');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF9E9EAE), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9EAE),
            ),
          ),
        ],
      ),
    );
  }

  // ========== MODIFIED DELETE DIALOG WITH FUNCTIONAL UNDO ==========
  void _showDeleteDialog(BuildContext context, NotesProvider provider, Note currentNote) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Move to Trash',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
        ),
        content: const Text(
          'Are you sure you want to move this note to trash?',
          style: TextStyle(fontSize: 14, color: Color(0xFF9E9EAE)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9EAE))),
          ),
          ElevatedButton(
            onPressed: () {
              // 1. U rari Trash dhanka Provider-ka
              provider.trashNote(currentNote);

              // 2. Xir Dialog-ga iyo Screen-ka hadda
              Navigator.pop(dialogContext);
              Navigator.pop(context);

              // 3. Muuji ogeysiis hoose (SnackBar) oo leh badhanka Undo (Hadda waa furantahay!)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note moved to Trash'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF1A1A2E),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.primary,
                    onPressed: () {
                      // Kani hadda si toos ah ayuu u shaqaynayaa oo dib ayuu u soo celinayaa!
                      provider.restoreNote(currentNote);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Trash'),
          ),
        ],
      ),
    );
  }
}