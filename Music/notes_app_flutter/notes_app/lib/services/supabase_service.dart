import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/note_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ==================== AUTH ====================

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  static Future<AuthResponse> signInWithGoogle({
    String? webClientId,
    String? iosClientId,
  }) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google Sign-In was cancelled by the user.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? accessToken = googleAuth.accessToken;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw const AuthException('No ID Token found. Google OAuth is not configured properly.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    return response;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ==================== NOTES ====================

  static Future<List<Note>> getNotes({
    bool? isFavorite,
    bool? isTrashed,
    bool? isArchived,
    bool? isDraft,
    String? category,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    var query = _client
        .from('notes')
        .select()
        .eq('user_id', userId);

    // Sifeyn firfircoon (Dynamic filters) oo loogu talagalay Trash iyo Archive Maxalli ah
    if (isTrashed != null) {
      query = query.eq('is_trashed', isTrashed);
    }

    if (isArchived != null) {
      query = query.eq('is_archived', isArchived);
    }

    if (isFavorite != null) {
      query = query.eq('is_favorite', isFavorite);
    }

    if (isDraft != null) {
      query = query.eq('is_draft', isDraft);
    }

    if (category != null && category != 'all') {
      query = query.eq('category', category);
    }

    final data = await query.order('updated_at', ascending: false);
    return (data as List).map((json) => Note.fromJson(json)).toList();
  }

  static Future<Note> createNote(Note note) async {
    final data = await _client
        .from('notes')
        .insert(note.toJson())
        .select()
        .single();
    return Note.fromJson(data);
  }

  static Future<Note> updateNote(Note note) async {
    final data = await _client
        .from('notes')
        .update(note.toJson())
        .eq('id', note.id)
        .select()
        .single();
    return Note.fromJson(data);
  }

  static Future<void> deleteNote(String noteId) async {
    await _client.from('notes').delete().eq('id', noteId);
  }

  static Future<Note> togglePin(Note note) async {
    return updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  static Future<Note> toggleFavorite(Note note) async {
    return updateNote(note.copyWith(isFavorite: !note.isFavorite));
  }

  static Future<Note> trashNote(Note note) async {
    return updateNote(note.copyWith(isTrashed: true, isPinned: false, isFavorite: false));
  }

  static Future<Note> restoreNote(Note note) async {
    return updateNote(note.copyWith(isTrashed: false));
  }

  static Future<List<Note>> searchNotes(String query) async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('notes')
        .select()
        .eq('user_id', userId)
        .eq('is_trashed', false)
        .eq('is_archived', false)
        .or('title.ilike.%$query%,content.ilike.%$query%')
        .order('updated_at', ascending: false);

    return (data as List).map((json) => Note.fromJson(json)).toList();
  }

  // ==================== STATS ====================

  static Future<Map<String, int>> getNoteStats() async {
    final userId = currentUser?.id;
    if (userId == null) return {};

    final data = await _client
        .from('notes')
        .select('category, is_pinned, is_trashed, is_archived')
        .eq('user_id', userId)
        .eq('is_trashed', false)
        .eq('is_archived', false);

    final notes = data as List;
    final Map<String, int> stats = {
      'total': notes.length,
      'pinned': notes.where((n) => n['is_pinned'] == true).length,
      'personal': notes.where((n) => n['category'] == 'personal').length,
      'work': notes.where((n) => n['category'] == 'work').length,
      'study': notes.where((n) => n['category'] == 'study').length,
      'ideas': notes.where((n) => n['category'] == 'ideas').length,
    };

    return stats;
  }
}