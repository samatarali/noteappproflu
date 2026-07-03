import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notes_provider.dart';
import '../../models/note_model.dart';
import '../../utils/app_theme.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final trashedNotes = provider.trashedNotes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Midab nadiif ah oo fudud
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Trash Bin',
              style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              'Items are stored here temporarily',
              style: TextStyle(color: Color(0xFF9E9EAE), fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          // Badhanka weyn ee lagu sifeeyo Trash-ka haddii uusan maranayn
          if (trashedNotes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: TextButton.icon(
                onPressed: () => _confirmEmptyTrash(context, provider),
                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 18),
                label: const Text('Empty', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
      body: trashedNotes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: trashedNotes.length,
        itemBuilder: (context, index) {
          final note = trashedNotes[index];
          return _buildTrashCard(context, provider, note);
        },
      ),
    );
  }

  // ========== UI: QAABKA EMPTY STATE-KA (MARAN) ==========
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 70,
              color: const Color(0xFF7C6FCD).withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Trash is completely empty',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Any notes you delete will be kept here safely.',
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9EAE)),
          ),
        ],
      ),
    );
  }

  // ========== UI: QAABKA KAARKA QRAALKA TRASH-KA ==========
  Widget _buildTrashCard(BuildContext context, NotesProvider provider, Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.01)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          // Border yar oo bidix ah oo muujinaya in note-ku jiro trash
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.error, width: 5)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title.isEmpty ? 'Untitled Note' : note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.content.isEmpty ? 'No content description' : note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8E8E9E),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // BADHAMADA ACTIONS-KA OO SKINNED AH
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badhanka Restore (Dib u soo celin)
                  _circleActionButton(
                    icon: Icons.settings_backup_restore_rounded,
                    color: const Color(0xFF4CAF50),
                    tooltip: 'Restore',
                    onTap: () {
                      provider.restoreNote(note);
                      _showSnackBar(context, 'Note restored successfully! 🔄', const Color(0xFF4CAF50));
                    },
                  ),
                  const SizedBox(width: 8),
                  // Badhanka Delete Forever (Tirtir weligeed)
                  _circleActionButton(
                    icon: Icons.delete_forever_rounded,
                    color: AppColors.error,
                    tooltip: 'Delete Permanently',
                    onTap: () => _confirmPermanentDelete(context, provider, note.id),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Badhanka goobaabta ah ee Action-ka kaararka
  Widget _circleActionButton({required IconData icon, required Color color, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  // ========== DIALOGS & CONFIRMATIONS ==========

  // 1. Tirtirista hal xabo oo Note ah rasmiga ah
  void _confirmPermanentDelete(BuildContext context, NotesProvider provider, String noteId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Permanently?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text('This action cannot be undone. This item will be removed forever.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9EAE), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.deleteNote(noteId);
              Navigator.pop(dialogContext);
              _showSnackBar(context, 'Note permanently deleted.', AppColors.error);
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 2. Sifeynta Qashinka oo dhan (Empty Trash All)
  void _confirmEmptyTrash(BuildContext context, NotesProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Empty Entire Trash?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text('Are you sure you want to delete all notes in the trash? You will lose them completely.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9EAE), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Hal-mar wada tirtir dhamaan qoraallada Trash-ka ku jira
              final trashedIds = provider.trashedNotes.map((n) => n.id).toList();
              for (var id in trashedIds) {
                provider.deleteNote(id);
              }
              Navigator.pop(dialogContext);
              _showSnackBar(context, 'Trash has been completely cleared.', AppColors.error);
            },
            child: const Text('Empty All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // SnackBar Elegant oo qurxoon
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}