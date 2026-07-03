// // pinned_notes_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/notes_provider.dart';
// import '../../models/note_model.dart';
// import '../../utils/app_theme.dart';
// import '../notes/create_note_screen.dart';
// import '../notes/edit_note_screen.dart';
//
// class PinnedNotesScreen extends StatelessWidget {
//   const PinnedNotesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<NotesProvider>();
//     final pinnedNotes = provider.pinnedNotes;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Column(
//           children: [
//             Text(
//               'Pinned Notes',
//               style: TextStyle(
//                 color: Color(0xFF1A1A2E),
//                 fontWeight: FontWeight.w800,
//                 fontSize: 18,
//               ),
//             ),
//             Text(
//               'Important notes kept on top',
//               style: TextStyle(
//                 color: Color(0xFF9E9EAE),
//                 fontSize: 11,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5FA),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 16),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search_rounded, color: Color(0xFF1A1A2E)),
//             onPressed: () {
//               // TODO: Implement search in pinned notes
//             },
//           ),
//         ],
//       ),
//       body: pinnedNotes.isEmpty
//           ? _buildEmptyState()
//           : RefreshIndicator(
//         onRefresh: () => provider.loadNotes(),
//         color: AppColors.primary,
//         child: ListView.builder(
//           padding: const EdgeInsets.all(20),
//           physics: const BouncingScrollPhysics(),
//           itemCount: pinnedNotes.length,
//           itemBuilder: (context, index) {
//             final note = pinnedNotes[index];
//             return _buildPinnedCard(context, provider, note);
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
//           ).then((_) => provider.loadNotes());
//         },
//         backgroundColor: AppColors.primary,
//         shape: const CircleBorder(),
//         child: const Icon(Icons.add_rounded, color: Colors.white),
//       ),
//     );
//   }
//
//   // ========== UI: EMPTY STATE (MARAN) ==========
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.02),
//                   blurRadius: 20,
//                   spreadRadius: 5,
//                 )
//               ],
//             ),
//             child: Icon(
//               Icons.push_pin_outlined,
//               size: 70,
//               color: const Color(0xFF7C6FCD).withOpacity(0.4),
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Pinned Notes',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1A1A2E),
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             'Pin important notes to keep them on top.',
//             style: TextStyle(
//               fontSize: 13,
//               color: Color(0xFF9E9EAE),
//             ),
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
//               ).then((_) => context.read<NotesProvider>().loadNotes());
//             },
//             icon: const Icon(Icons.add_rounded, size: 18),
//             label: const Text('Create a Note'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ========== UI: PINNED NOTE CARD ==========
//   Widget _buildPinnedCard(BuildContext context, NotesProvider provider, Note note) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.black.withOpacity(0.01)),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           decoration: const BoxDecoration(
//             border: Border(
//               left: BorderSide(color: Color(0xFF7C6FCD), width: 5),
//             ),
//           ),
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Category Badge
//                     _buildCategoryBadge(note.category),
//                     const SizedBox(height: 10),
//                     // Title
//                     Text(
//                       note.title.isEmpty ? 'Untitled Note' : note.title,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                         color: Color(0xFF1A1A2E),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     // Content preview
//                     Text(
//                       note.content.isEmpty ? 'No content description' : note.content,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Color(0xFF8E8E9E),
//                         fontSize: 13,
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     // Date
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.access_time_rounded,
//                           size: 12,
//                           color: Colors.grey.withOpacity(0.6),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _formatDate(note.updatedAt),
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.withOpacity(0.6),
//                           ),
//                         ),
//                         if (note.isFavorite) ...[
//                           const SizedBox(width: 12),
//                           const Icon(
//                             Icons.favorite_rounded,
//                             size: 12,
//                             color: Colors.pinkAccent,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Favorite',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: Colors.pinkAccent.withOpacity(0.8),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // ACTION BUTTONS
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Unpin button
//                   _circleActionButton(
//                     icon: Icons.push_pin_rounded,
//                     color: const Color(0xFF7C6FCD),
//                     tooltip: 'Unpin',
//                     onTap: () {
//                       provider.togglePin(note);
//                       _showSnackBar(context, 'Note unpinned 📌', const Color(0xFF7C6FCD));
//                     },
//                   ),
//                   const SizedBox(height: 8),
//                   // Favorite button
//                   _circleActionButton(
//                     icon: note.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
//                     color: note.isFavorite ? Colors.pinkAccent : Colors.grey,
//                     tooltip: note.isFavorite ? 'Remove from favorites' : 'Add to favorites',
//                     onTap: () {
//                       provider.toggleFavorite(note);
//                       _showSnackBar(
//                         context,
//                         note.isFavorite ? 'Removed from favorites 💔' : 'Added to favorites ❤️',
//                         note.isFavorite ? Colors.grey : Colors.pinkAccent,
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 8),
//                   // Edit button
//                   _circleActionButton(
//                     icon: Icons.edit_rounded,
//                     color: const Color(0xFF4CAF50),
//                     tooltip: 'Edit',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => EditNoteScreen(note: note),
//                         ),
//                       ).then((_) => provider.loadNotes());
//                     },
//                   ),
//                   const SizedBox(height: 8),
//                   // Delete/Trash button
//                   _circleActionButton(
//                     icon: Icons.delete_outline_rounded,
//                     color: AppColors.error,
//                     tooltip: 'Move to Trash',
//                     onTap: () => _confirmMoveToTrash(context, provider, note),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Category Badge Widget
//   Widget _buildCategoryBadge(NoteCategory category) {
//     final categoryData = _getCategoryData(category);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: categoryData.color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             categoryData.icon,
//             size: 12,
//             color: categoryData.color,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             categoryData.name,
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//               color: categoryData.color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Circle Action Button
//   Widget _circleActionButton({
//     required IconData icon,
//     required Color color,
//     required String tooltip,
//     required VoidCallback onTap,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.08),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: color, size: 18),
//         ),
//       ),
//     );
//   }
//
//   // Confirm move to trash dialog
//   void _confirmMoveToTrash(BuildContext context, NotesProvider provider, Note note) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(
//           children: [
//             Icon(Icons.delete_outline_rounded, color: AppColors.error),
//             SizedBox(width: 8),
//             Text('Move to Trash?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           ],
//         ),
//         content: Text('Are you sure you want to move "${note.title.isEmpty ? 'Untitled' : note.title}" to trash?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9EAE), fontWeight: FontWeight.w600)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () {
//               provider.trashNote(note);
//               Navigator.pop(dialogContext);
//               _showSnackBar(context, 'Note moved to trash 🗑️', AppColors.error);
//             },
//             child: const Text('Move to Trash', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Format date
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
//
//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
//
//   // Get category data
//   Map<String, dynamic> _getCategoryData(NoteCategory category) {
//     switch (category) {
//       case NoteCategory.personal:
//         return {
//           'name': 'Personal',
//           'icon': Icons.person_rounded,
//           'color': const Color(0xFF2196F3),
//         };
//       case NoteCategory.work:
//         return {
//           'name': 'Work',
//           'icon': Icons.work_rounded,
//           'color': const Color(0xFF4CAF50),
//         };
//       case NoteCategory.study:
//         return {
//           'name': 'Study',
//           'icon': Icons.menu_book_rounded,
//           'color': const Color(0xFFFF6B6B),
//         };
//       case NoteCategory.ideas:
//         return {
//           'name': 'Ideas',
//           'icon': Icons.lightbulb_outline_rounded,
//           'color': const Color(0xFFFFA726),
//         };
//       case NoteCategory.other:
//         return {
//           'name': 'Other',
//           'icon': Icons.more_horiz_rounded,
//           'color': const Color(0xFF9E9EAE),
//         };
//       default:
//         return {
//           'name': 'All',
//           'icon': Icons.note_alt_rounded,
//           'color': const Color(0xFF7C6FCD),
//         };
//     }
//   }
//
//   // SnackBar
//   void _showSnackBar(BuildContext context, String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }