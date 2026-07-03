import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_theme.dart';
import '../../services/notes_provider.dart';

class QuickAccessSettingsScreen extends StatefulWidget {
  const QuickAccessSettingsScreen({super.key});

  @override
  State<QuickAccessSettingsScreen> createState() => _QuickAccessSettingsScreenState();
}

class _QuickAccessSettingsScreenState extends State<QuickAccessSettingsScreen> {
  String _language = 'en';
  bool _isLoading = true;

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'title': 'Quick Access',
      'sub': 'Choose which quick shortcuts appear on the home screen.',
      'home': 'Home',
      'home_sub': 'Show Home in quick access',
      'favorites': 'Favorites',
      'favorites_sub': 'Show Favorites in quick access',
      'categories': 'Categories',
      'categories_sub': 'Show Categories in quick access',
      'settings': 'Settings',
      'settings_sub': 'Show Settings in quick access',
      'compact': 'Compact quick button',
      'compact_sub': 'Show one quick access button instead of separate shortcuts.',
      'saved': 'Quick access saved',
      'no_items': 'No quick access items selected',
    },
    'so': {
      'title': 'Degdegga Gelitaanka',
      'sub': 'Dooro shortcuts-ka degdegga ah ee ka muuqda bogga guriga.',
      'home': 'Guri',
      'home_sub': 'Tus Guri quick access',
      'favorites': 'Jecel',
      'favorites_sub': 'Tus Jecel quick access',
      'categories': 'Qaybo',
      'categories_sub': 'Tus Qaybo quick access',
      'settings': 'Dejinta',
      'settings_sub': 'Tus Dejinta quick access',
      'compact': 'Badhamka degdega ah hal meel',
      'compact_sub': 'Tus hal badhan oo keliya halkii aad ka arki lahayd shortcuts gooni gooni ah.',
      'saved': 'Quick access waa la keydiyey',
      'no_items': 'Wax quick access ah lama xulan',
    }
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _language = prefs.getString('app_language') ?? 'en';
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _t(String key) {
    return _translations[_language]?[key] ?? key;
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9EAE)),
      ),
      trailing: Switch(
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _t('title'),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  _t('sub'),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF9E9EAE)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _toggleTile(
                        icon: Icons.home_outlined,
                        title: _t('home'),
                        subtitle: _t('home_sub'),
                        value: provider.quickHome,
                        color: const Color(0xFF4F46E5),
                        onChanged: (value) {
                          provider.updateQuickAccessSetting('quick_access_home', value);
                        },
                      ),
                      _divider(),
                      _toggleTile(
                        icon: Icons.star_outline_rounded,
                        title: _t('favorites'),
                        subtitle: _t('favorites_sub'),
                        value: provider.quickFavorites,
                        color: const Color(0xFFF59E0B),
                        onChanged: (value) {
                          provider.updateQuickAccessSetting('quick_access_favorites', value);
                        },
                      ),
                      _divider(),
                      _toggleTile(
                        icon: Icons.folder_open_outlined,
                        title: _t('categories'),
                        subtitle: _t('categories_sub'),
                        value: provider.quickCategories,
                        color: const Color(0xFF10B981),
                        onChanged: (value) {
                          provider.updateQuickAccessSetting('quick_access_categories', value);
                        },
                      ),
                      _divider(),
                      _toggleTile(
                        icon: Icons.settings_outlined,
                        title: _t('settings'),
                        subtitle: _t('settings_sub'),
                        value: provider.quickSettings,
                        color: const Color(0xFF3B82F6),
                        onChanged: (value) {
                          provider.updateQuickAccessSetting('quick_access_settings', value);
                        },
                      ),
                      _divider(),
                      _toggleTile(
                        icon: Icons.category_outlined,
                        title: _t('compact'),
                        subtitle: _t('compact_sub'),
                        value: provider.compactQuickAccess,
                        color: AppColors.primary,
                        onChanged: (value) {
                          provider.updateQuickAccessSetting('quick_access_compact', value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: Color(0xFFF2F2F7),
      indent: 16,
      endIndent: 16,
    );
  }
}
