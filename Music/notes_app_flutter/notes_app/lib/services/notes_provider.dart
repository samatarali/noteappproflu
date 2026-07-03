import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../services/supabase_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String? _error;
  NoteCategory _selectedCategory = NoteCategory.all;
  String _searchQuery = '';
  Map<String, int> _stats = {};

  // Quick Access settings
  bool _quickHome = true;
  bool _quickFavorites = true;
  bool _quickCategories = true;
  bool _quickSettings = true;
  bool _compactQuickAccess = false;

  bool get quickHome => _quickHome;
  bool get quickFavorites => _quickFavorites;
  bool get quickCategories => _quickCategories;
  bool get quickSettings => _quickSettings;
  bool get compactQuickAccess => _compactQuickAccess;

  NotesProvider() {
    loadQuickAccessSettings();
  }

  Future<void> loadQuickAccessSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _quickHome = prefs.getBool('quick_access_home') ?? true;
      _quickFavorites = prefs.getBool('quick_access_favorites') ?? true;
      _quickCategories = prefs.getBool('quick_access_categories') ?? true;
      _quickSettings = prefs.getBool('quick_access_settings') ?? true;
      _compactQuickAccess = prefs.getBool('quick_access_compact') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateQuickAccessSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      if (key == 'quick_access_home') _quickHome = value;
      if (key == 'quick_access_favorites') _quickFavorites = value;
      if (key == 'quick_access_categories') _quickCategories = value;
      if (key == 'quick_access_settings') _quickSettings = value;
      if (key == 'quick_access_compact') _compactQuickAccess = value;
      notifyListeners();
    } catch (_) {}
  }

  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  NoteCategory get selectedCategory => _selectedCategory;
  Map<String, int> get stats => _stats;

  // Pinned and Favorite notes (Kaliya kuwa aan trash ahayn)
  List<Note> get pinnedNotes =>
      _notes.where((n) => n.isPinned && !n.isTrashed).toList();
  List<Note> get favoriteNotes =>
      _notes.where((n) => n.isFavorite && !n.isTrashed).toList();
  List<Note> get recentNotes =>
      _notes.where((n) => !n.isTrashed).take(10).toList();

  // CUSUB: Getter soo qabanaya qoraallada Trash-ka ku jira oo kaliya
  List<Note> get trashedNotes => _notes.where((n) => n.isTrashed).toList();

  // Stats getters
  int get totalNotes => _notes.where((n) => !n.isTrashed).length;
  int get pinnedCount => pinnedNotes.length;
  int get favoriteCount => favoriteNotes.length;
  int get categoryCount => 6; // All, Personal, Work, Study, Ideas, More

  // Today's notes count
  int get todayCount {
    final today = DateTime.now();
    return _notes
        .where((n) =>
    !n.isTrashed &&
        n.createdAt.day == today.day &&
        n.createdAt.month == today.month &&
        n.createdAt.year == today.year)
        .length;
  }

  // Count notes for a specific category
  int countForCategory(NoteCategory category) {
    if (category == NoteCategory.all) {
      return _notes.where((n) => !n.isTrashed).length;
    }
    return _notes.where((n) => !n.isTrashed && n.category == category).length;
  }

  // Count for "More" category (Other)
  int get othersCount {
    return _notes
        .where((n) => !n.isTrashed && n.category == NoteCategory.other)
        .length;
  }

  // Load notes from Supabase
  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await SupabaseService.getNotes();
      _stats = await SupabaseService.getNoteStats();
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Select category filter
  void selectCategory(NoteCategory category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  // Search notes
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // Apply both category and search filters
  void _applyFilter() {
    var filtered = _notes.where((note) {
      // Filter out trashed notes (Halkan ayaa guriga ka sifeynaya)
      if (note.isTrashed) return false;

      // Filter by category
      if (_selectedCategory != NoteCategory.all &&
          note.category != _selectedCategory) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(q) ||
            note.content.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    // Sort by pinned first, then by updated date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    _filteredNotes = filtered;
  }

  // Create a new note
  Future<void> createNote(Note note) async {
    try {
      final newNote = await SupabaseService.createNote(note);
      _notes.insert(0, newNote);
      _stats['total'] = (_stats['total'] ?? 0) + 1;
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      final updated = await SupabaseService.updateNote(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updated;
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete a note permanently (Kani waa tirtirid weligeed ah)
  Future<void> deleteNote(String noteId) async {
    try {
      await SupabaseService.deleteNote(noteId);
      _notes.removeWhere((n) => n.id == noteId);
      _stats['total'] = (_stats['total'] ?? 1) - 1;
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Toggle pin status
  Future<void> togglePin(Note note) async {
    try {
      final updated = await SupabaseService.togglePin(note);
      _updateNoteInList(updated);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Note note) async {
    try {
      final updated = await SupabaseService.toggleFavorite(note);
      _updateNoteInList(updated);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== LA SAXAY: Move note to trash ==========
  Future<void> trashNote(Note note) async {
    try {
      final updated = await SupabaseService.trashNote(note);
      // Intii laga tirtiri lahaa, liiska guud ayaan ku dhex cusboonaysiinayna xogtiisa cusub (isTrashed: true)
      _updateNoteInList(updated);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ========== CUSUB: Dib uga soo celinta Trash-ka (Undo) ==========
  Future<void> restoreNote(Note note) async {
    try {
      // Waxaan u diraynaa Supabase xogta iyadoo isTrashed laga dhigay false
      final restoredNote = note.copyWith(isTrashed: false);
      final updated = await SupabaseService.updateNote(restoredNote);
      _updateNoteInList(updated);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update note in the list
  void _updateNoteInList(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _applyFilter();
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  // Reset all filters
  void resetFilters() {
    _selectedCategory = NoteCategory.all;
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }
}