import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/note_model.dart';
import '../../services/notes_provider.dart';
import '../../utils/app_theme.dart';
import '../navigation/main_navigation.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _customCategories = [];
  bool _isLocalLoading = true;

  final List<Map<String, dynamic>> _defaultCategories = [
    {
      'id': '1',
      'title': 'All Notes',
      'icon': Icons.note_alt_rounded,
      'color': const Color(0xFF7C6FCD),
      'category': NoteCategory.all
    },
    {
      'id': '2',
      'title': 'Personal',
      'icon': Icons.person_rounded,
      'color': const Color(0xFFFFA726),
      'category': NoteCategory.personal
    },
    {
      'id': '3',
      'title': 'Work',
      'icon': Icons.work_rounded,
      'color': const Color(0xFF4CAF50),
      'category': NoteCategory.work
    },
    {
      'id': '4',
      'title': 'Study',
      'icon': Icons.school_rounded,
      'color': const Color(0xFFFF6B6B),
      'category': NoteCategory.study
    },
    {
      'id': '5',
      'title': 'Ideas',
      'icon': Icons.lightbulb_outline_rounded,
      'color': const Color(0xFF2196F3),
      'category': NoteCategory.ideas
    },
    {
      'id': '6',
      'title': 'More',
      'icon': Icons.more_horiz_rounded,
      'color': const Color(0xFF9E9EAE),
      'category': NoteCategory.other
    },
  ];

  final List<Color> _availableColors = [
    const Color(0xFF7C6FCD),
    const Color(0xFF2196F3),
    const Color(0xFF4CAF50),
    const Color(0xFFFF6B6B),
    const Color(0xFFFFA726),
    const Color(0xFF9E9EAE),
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
    const Color(0xFF795548),
    const Color(0xFF607D8B),
  ];

  final List<IconData> _availableIcons = [
    Icons.folder_rounded,
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.shopping_cart_rounded,
    Icons.travel_explore_rounded,
    Icons.fitness_center_rounded,
    Icons.music_note_rounded,
    Icons.movie_rounded,
    Icons.book_rounded,
    Icons.code_rounded,
    Icons.gamepad_rounded,
    Icons.pets_rounded,
    Icons.restaurant_rounded,
    Icons.flight_takeoff_rounded,
    Icons.local_mall_rounded,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
      _loadCustomCategories();
    });
  }

  // Load custom categories from SharedPreferences
  Future<void> _loadCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('custom_categories');
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        setState(() {
          _customCategories = decoded.map((item) {
            return {
              'id': item['id'],
              'title': item['title'],
              'icon': IconData(item['icon'], fontFamily: 'MaterialIcons'),
              'color': Color(item['color']),
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading custom categories: $e');
    } finally {
      setState(() => _isLocalLoading = false);
    }
  }

  // Save custom categories to SharedPreferences
  Future<void> _saveCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> toSave = _customCategories.map((item) {
        return {
          'id': item['id'],
          'title': item['title'],
          'icon': (item['icon'] as IconData).codePoint,
          'color': (item['color'] as Color).value,
        };
      }).toList();
      await prefs.setString('custom_categories', jsonEncode(toSave));
    } catch (e) {
      debugPrint('Error saving custom categories: $e');
    }
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => _AddCategoryDialog(
        availableColors: _availableColors,
        availableIcons: _availableIcons,
        onSave: (title, icon, color) async {
          setState(() {
            _customCategories.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'title': title,
              'icon': icon,
              'color': color,
            });
          });
          await _saveCustomCategories();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category added successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _editCategory(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => _EditCategoryDialog(
        category: category,
        availableColors: _availableColors,
        availableIcons: _availableIcons,
        onSave: (title, icon, color) async {
          setState(() {
            category['title'] = title;
            category['icon'] = icon;
            category['color'] = color;
          });
          await _saveCustomCategories();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteCategory(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content:
        Text('Are you sure you want to delete "${category['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _customCategories.remove(category);
              });
              await _saveCustomCategories();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deleted!'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER ==========
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Organize your notes beautifully by category',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9EAE),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ========== ALL CATEGORIES SUMMARY CARD ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
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
                      child: const Icon(
                        Icons.folder_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'All Categories',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '${_defaultCategories.length + _customCategories.length} categories • ${provider.totalNotes} notes',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9EAE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ========== SYSTEM & MY CATEGORIES SECTION ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  GestureDetector(
                    onTap: _addCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Add Category',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ========== LIST OF CATEGORIES ==========
            Expanded(
              child: _isLocalLoading
                  ? const Center(
                  child:
                  CircularProgressIndicator(color: AppColors.primary))
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount:
                _defaultCategories.length + _customCategories.length,
                itemBuilder: (context, index) {
                  // Display default first, then custom
                  if (index < _defaultCategories.length) {
                    final item = _defaultCategories[index];
                    final count = _getNoteCount(item, provider);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCategoryCard(
                        title: item['title'],
                        count: count,
                        icon: item['icon'],
                        color: item['color'],
                        isDefault: true,
                        onTap: () {
                          provider.selectCategory(item['category']);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MainNavigation(
                                    initialIndex: 0)),
                                (route) => false,
                          );
                        },
                      ),
                    );
                  } else {
                    final item = _customCategories[
                    index - _defaultCategories.length];
                    final count = _getNoteCount(item, provider);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCategoryCard(
                        title: item['title'],
                        count: count,
                        icon: item['icon'],
                        color: item['color'],
                        isDefault: false,
                        onTap: () {
                          // Search notes matching custom category title
                          provider.search(item['title']);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MainNavigation(
                                    initialIndex: 0)),
                                (route) => false,
                          );
                        },
                        onEdit: () => _editCategory(item),
                        onDelete: () => _deleteCategory(item),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get note count based on category type
  int _getNoteCount(Map<String, dynamic> item, NotesProvider provider) {
    if (item.containsKey('category')) {
      final cat = item['category'] as NoteCategory;
      if (cat == NoteCategory.all) return provider.totalNotes;
      if (cat == NoteCategory.other) return provider.othersCount;
      return provider.countForCategory(cat);
    } else {
      // For custom categories, count by matching tag dynamically
      final title = item['title'].toString().toLowerCase();
      return provider.allNotes.where((n) {
        return !n.isTrashed && n.tags.any((t) => t.toLowerCase() == title);
      }).length;
    }
  }

  Widget _buildCategoryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required bool isDefault,
    required VoidCallback onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$count notes',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9EAE),
                    ),
                  ),
                ],
              ),
            ),
            if (!isDefault) ...[
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit,
                      color: AppColors.primary, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 16),
                ),
              ),
            ] else
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCCCCDD),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ========== ADD CATEGORY DIALOG ==========
class _AddCategoryDialog extends StatefulWidget {
  final List<Color> availableColors;
  final List<IconData> availableIcons;
  final Function(String, IconData, Color) onSave;

  const _AddCategoryDialog({
    required this.availableColors,
    required this.availableIcons,
    required this.onSave,
  });

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.folder_rounded;
  Color _selectedColor = const Color(0xFF7C6FCD);
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.availableIcons[0];
    _selectedColor = widget.availableColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add New Category',
          style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Category name',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Icon',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: widget.availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = widget.availableIcons[index];
                  final isSelected = _selectedIconIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIconIndex = index;
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1),
                      ),
                      child: Icon(icon,
                          color: isSelected ? AppColors.primary : Colors.grey,
                          size: 24),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Color',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.availableColors.length,
                itemBuilder: (context, index) {
                  final color = widget.availableColors[index];
                  final isSelected = _selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1),
                        ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enter category name'),
                    backgroundColor: Colors.red),
              );
              return;
            }
            widget.onSave(name, _selectedIcon, _selectedColor);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Add Category'),
        ),
      ],
    );
  }
}

// ========== EDIT CATEGORY DIALOG ==========
class _EditCategoryDialog extends StatefulWidget {
  final Map<String, dynamic> category;
  final List<Color> availableColors;
  final List<IconData> availableIcons;
  final Function(String, IconData, Color) onSave;

  const _EditCategoryDialog({
    required this.category,
    required this.availableColors,
    required this.availableIcons,
    required this.onSave,
  });

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late int _selectedIconIndex;
  late int _selectedColorIndex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category['title']);
    _selectedIcon = widget.category['icon'];
    _selectedColor = widget.category['color'];
    _selectedIconIndex = widget.availableIcons.indexOf(_selectedIcon);
    _selectedColorIndex = widget.availableColors.indexOf(_selectedColor);
    if (_selectedIconIndex == -1) _selectedIconIndex = 0;
    if (_selectedColorIndex == -1) _selectedColorIndex = 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit Category',
          style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Category name',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Icon',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: widget.availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = widget.availableIcons[index];
                  final isSelected = _selectedIconIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIconIndex = index;
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1),
                      ),
                      child: Icon(icon,
                          color: isSelected ? AppColors.primary : Colors.grey,
                          size: 24),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Color',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.availableColors.length,
                itemBuilder: (context, index) {
                  final color = widget.availableColors[index];
                  final isSelected = _selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1),
                        ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enter category name'),
                    backgroundColor: Colors.red),
              );
              return;
            }
            widget.onSave(name, _selectedIcon, _selectedColor);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
