import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../services/notes_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_theme.dart';
import '../notes/create_note_screen.dart';
import '../notes/my_notes_screen.dart';
import '../notes/search_screen.dart';
import '../notes/trash_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final user = SupabaseService.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User';
    final userEmail = user?.email ?? 'user@example.com';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      drawer: _buildDrawer(context, provider, userName, userEmail, initials),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadNotes(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ========== HEADER ==========
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) => GestureDetector(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.menu_rounded,
                                  color: Color(0xFF1A1A2E),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                'All your notes, organized beautifully',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9EAE),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
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
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ========== WELCOME BANNER ==========
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEE9FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back! 👋',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                'You have ${provider.totalNotes} notes in ${provider.categoryCount} categories.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9E9EAE),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
                          ).then((_) => provider.loadNotes()),
                          icon: const Icon(Icons.add, size: 15),
                          label: const Text('New Note'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ========== STATS ROW ==========
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _statCard(Icons.description_outlined, '${provider.totalNotes}', 'Total Notes', AppColors.primary),
                      const SizedBox(width: 10),
                      _statCard(Icons.star_outline_rounded, '${provider.categoryCount}', 'Categories', const Color(0xFFFFA726)),
                      const SizedBox(width: 10),
                      _statCard(Icons.calendar_today_outlined, '${provider.todayCount}', 'Today', const Color(0xFF4CAF50)),
                      const SizedBox(width: 10),
                      _statCard(Icons.push_pin_outlined, '${provider.pinnedCount}', 'Pinned', const Color(0xFF7C6FCD)),
                    ],
                  ),
                ),
              ),

              // ========== CATEGORIES HEADER ==========
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen())),
                        child: const Text('View all', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),

              // ========== CATEGORIES LIST ==========
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        _categoryRow('All Notes', provider.totalNotes.toString(), Icons.note_alt_rounded, const Color(0xFF7C6FCD), () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen()));
                        }),
                        _divider(),
                        _categoryRow('Personal', provider.countForCategory(NoteCategory.personal).toString(), Icons.person_rounded, const Color(0xFF2196F3), () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen()));
                        }),
                        _divider(),
                        _categoryRow('Work', provider.countForCategory(NoteCategory.work).toString(), Icons.work_rounded, const Color(0xFF4CAF50), () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen()));
                        }),
                        _divider(),
                        _categoryRow('Study', provider.countForCategory(NoteCategory.study).toString(), Icons.menu_book_rounded, const Color(0xFFFF6B6B), () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen()));
                        }),
                        _divider(),
                        _categoryRow('Ideas', provider.countForCategory(NoteCategory.ideas).toString(), Icons.lightbulb_outline_rounded, const Color(0xFFFFA726), () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen()));
                        }),
                        _divider(),
                        _categoryRow('More', provider.othersCount.toString(), Icons.more_horiz_rounded, const Color(0xFF9E9EAE), () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen()));
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNoteScreen())).then((_) => provider.loadNotes()),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }

  // ========== DRAWERS MENU ==========
  Widget _buildDrawer(BuildContext context, NotesProvider provider, String name, String email, String initials) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            accountEmail: Text(email, style: TextStyle(color: Colors.white.withOpacity(0.8))),
          ),

          // Core Notes Section
          ListTile(
            leading: const Icon(Icons.note_alt_rounded, color: Color(0xFF1A1A2E)),
            title: const Text('My Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A2E))),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyNotesScreen()));
            },
          ),

          // 🌟 FEATURE-KA CUSUB: Favorites (Kuwa aad jeceshahay)
          ListTile(
            leading: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent),
            title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A2E))),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreenPlaceholder()));
            },
          ),

          // Qaybta Trash-ka
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Color(0xFF1A1A2E)),
            title: const Text('Trash', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A2E))),
            trailing: provider.trashedNotes.isNotEmpty
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${provider.trashedNotes.length}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error),
              ),
            )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrashScreen()),
              );
            },
          ),

          const Divider(indent: 16, endIndent: 16),

          // Settings Section
          ListTile(
            leading: const Icon(Icons.person_rounded, color: Color(0xFF1A1A2E)),
            title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A2E))),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreenPlaceholder(userName: name, userEmail: email)));
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings_rounded, color: Color(0xFF1A1A2E)),
            title: const Text('App Settings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A2E))),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),

          // Dark Mode Switch
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded, color: Color(0xFF1A1A2E)),
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A2E))),
            activeColor: AppColors.primary,
            value: _isDarkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _isDarkModeEnabled = value;
              });
            },
          ),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 15)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9EAE)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(String title, String count, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A2E))),
              ],
            ),
            Text(count, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0), indent: 16, endIndent: 16);
  }
}

// ================= PLACEHOLDERS =================

class ProfileScreenPlaceholder extends StatelessWidget {
  final String userName;
  final String userEmail;
  const ProfileScreenPlaceholder({super.key, required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings", style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, backgroundColor: AppColors.primary, child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(userEmail, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 🌟 SCREEN-KA CUSUB EE FAVORITES-KA
class FavoritesScreenPlaceholder extends StatelessWidget {
  const FavoritesScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites", style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.favorite_border_rounded, size: 80, color: Colors.pinkAccent),
            SizedBox(height: 20),
            Text(
              "No Favorite Notes Yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            SizedBox(height: 10),
            Text(
              "Mark notes as favorites to see them here.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}