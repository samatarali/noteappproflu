import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../utils/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onPin;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onPin,
    this.onFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = note.category;
    final dateStr = DateFormat('MMM d, yyyy').format(note.updatedAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 24),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title.isEmpty ? 'Untitled Note' : note.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.content.isEmpty ? 'No content yet' : note.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: category.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                if (note.isPinned)
                  GestureDetector(
                    onTap: onPin,
                    child: const Icon(Icons.push_pin_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                if (note.isFavorite)
                  Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 18),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textLight, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _optionTile(context, Icons.push_pin_outlined,
                note.isPinned ? 'Unpin Note' : 'Pin Note', onPin),
            _optionTile(context, Icons.star_outline_rounded,
                note.isFavorite ? 'Remove Favorite' : 'Add to Favorites', onFavorite),
            _optionTile(context, Icons.delete_outline_rounded, 'Move to Trash',
                onDelete, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback? onTap, {
        bool isDestructive = false,
      }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }
}
