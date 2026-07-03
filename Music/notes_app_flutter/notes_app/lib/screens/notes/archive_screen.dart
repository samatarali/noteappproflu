// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/notes_provider.dart';
// import '../../models/note_model.dart';
// import '../../utils/app_theme.dart';
//
// class ArchiveScreen extends StatelessWidget {
//   const ArchiveScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<NotesProvider>();
//     // FIIRO GAAR AH: Hubi in provider-kaaga uu leeyahay 'archivedNotes'
//     final archivedNotes = provider.archivedNotes;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5FA),
//       appBar: AppBar(
//         title: const Text(
//           'Archive',
//           style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: archivedNotes.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.archive_outlined, size: 80, color: const Color(0xFF9E9EAE).withOpacity(0.5)),
//             const SizedBox(height: 16),
//             const Text(
//               'Archive is empty',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               'Notes you archive will appear here',
//               style: TextStyle(fontSize: 13, color: Color(0xFF9E9EAE)),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: archivedNotes.length,
//         itemBuilder: (context, index) {
//           final note = archivedNotes[index];
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
//               ],
//             ),
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               title: Text(
//                 note.title.isEmpty ? 'Untitled Note' : note.title,
//                 style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
//               ),
//               subtitle: Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   note.content.isEmpty ? 'No content' : note.content,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(color: Color(0xFF9E9EAE), fontSize: 13),
//                 ),
//               ),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // BADHANKA DIB U SOO CELINTA (UNARCHIVE)
//                   IconButton(
//                     icon: const Icon(Icons.unarchive_rounded, color: AppColors.primary),
//                     tooltip: 'Unarchive Note',
//                     onPressed: () {
//                       // FIIRO GAAR AH: Hubi in provider-kaaga uu leeyahay function-kan ama mid la mid ah
//                       provider.unarchiveNote(note);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Note unarchived successfully!'),
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }