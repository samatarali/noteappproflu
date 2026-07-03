import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/note_model.dart';
import '../../services/notes_provider.dart';
import '../../services/supabase_service.dart';

class CreateNoteScreen extends StatefulWidget {
  final Note? existingNote;
  const CreateNoteScreen({super.key, this.existingNote});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  NoteCategory _selectedCategory = NoteCategory.personal;
  bool _isLoading = false;

  bool get isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _selectedCategory = widget.existingNote!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedCategory = NoteCategory.personal;
    });
  }

  Future<void> _saveNote({bool isDraft = false}) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fadlan geli Title!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = context.read<NotesProvider>();
      final userId = SupabaseService.currentUser?.id ?? '';

      final note = Note(
        id: widget.existingNote?.id ?? const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        isDraft: isDraft,
        createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await provider.updateNote(note);
      } else {
        await provider.createNote(note);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDraft ? 'Draft Saved Successfully! 📝' : 'Note Saved Successfully! 🎉'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (isEditing) {
          Navigator.pop(context);
        } else {
          _clearForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCategoryChip(NoteCategory category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.deepPurple : Colors.orange.shade700),
      label: Text(label, style: TextStyle(color: isSelected ? Colors.deepPurple : Colors.black87, fontWeight: FontWeight.w600)),
      selected: isSelected,
      selectedColor: Colors.purple.shade50,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
      ),
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedCategory = category);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Create",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.grid_view_rounded, size: 16, color: Colors.deepPurple),
                        SizedBox(width: 4),
                        Text("Templates", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text("Start writing something amazing ✨", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.description_outlined, color: Colors.deepPurple, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text("New Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text("Title", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Enter note title...",
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("Category", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple, fontSize: 13)),
                    const SizedBox(height: 8),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildCategoryChip(NoteCategory.personal, "Personal", Icons.person_outline),
                          const SizedBox(width: 8),
                          _buildCategoryChip(NoteCategory.work, "Work", Icons.business_center_outlined),
                          const SizedBox(width: 8),
                          _buildCategoryChip(NoteCategory.study, "Study", Icons.school_outlined),
                          const SizedBox(width: 8),
                          _buildCategoryChip(NoteCategory.ideas, "Ideas", Icons.lightbulb_outline),
                          const SizedBox(width: 8),
                          _buildCategoryChip(NoteCategory.other, "Other", Icons.category_outlined),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    const Text("Note Content", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple, fontSize: 13)),
                    const SizedBox(height: 8),

                    // ========== NOTE CONTENT AYAA HADDA LA MID DHIGAY TITLE-KA ==========
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Start writing your note...",
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white, // Cadaan
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildUtilityButton(Icons.access_time, "Add Reminder"),
                          const SizedBox(width: 8),
                          _buildUtilityButton(Icons.local_offer_outlined, "Add Tags"),
                          const SizedBox(width: 8),
                          _buildUtilityButton(Icons.palette_outlined, "Add Color"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.insert_drive_file_outlined, size: 18, color: Colors.deepPurple),
                      label: const Text("Save Draft", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade50,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _saveNote(isDraft: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18, color: Colors.white),
                      label: Text(isEditing ? "Update Note" : "Create Note", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        elevation: 2,
                        shadowColor: Colors.deepPurple.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _saveNote(isDraft: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}