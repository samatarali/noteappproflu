import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // 1. WAXAA LA SOO DARAY
import '../../services/supabase_service.dart';
import '../../services/theme_provider.dart';
import '../../utils/app_theme.dart';
import 'quick_access_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'en';
  bool _isNotificationOn = true;
  bool _isLoading = false;

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'settings': 'Settings',
      'sub': 'Manage your preferences and account',
      'pref': 'Preferences',
      'appearance': 'Appearance',
      'appearance_sub': 'Choose light or dark theme',
      'lang': 'Language',
      'lang_sub': 'Dooro luqadda app-ka (Somali)',
      'notif': 'Notifications',
      'notif_sub': 'Manage your notification preferences',
      'privacy': 'Privacy & Security',
      'privacy_sub': 'Manage privacy settings',
      'edit_profile': 'Edit Profile',
      'edit_profile_sub': 'Update your name and profile details',
      'logout': 'Log Out',
      'logout_sub': 'Sign out from your account',
      'logout_confirm': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'save': 'Save',
      'profile_title': 'Update Profile',
      'full_name': 'Full Name',
      'theme_light': 'Light Mode',
      'theme_dark': 'Dark Mode',
      'theme_system': 'System Settings',
      'success_profile': 'Profile updated successfully!',
      'success_lang': 'Language changed successfully!',
      'quick_access': 'Quick Access',
      'quick_access_sub': 'Choose which shortcuts appear on the home screen.',
      'configure': 'Configure',
      'uploading': 'Uploading image...',
      'avatar_success': 'Profile picture updated!',
    },
    'so': {
      'settings': 'Habeeyaha',
      'sub': 'Maamul doorbidyadaada iyo koontadaada',
      'pref': 'Doorashooyinka',
      'appearance': 'Muqaalka App-ka',
      'appearance_sub': 'Dooro habka iftiinka ama madowga',
      'lang': 'Luqadda / Language',
      'lang_sub': 'Choose app language (English)',
      'notif': 'Ogeysiisyada',
      'notif_sub': 'Maamul ogeysiisyadaada iyo fariimaha',
      'privacy': 'Amniga & Khaaska',
      'privacy_sub': 'Maamul amniga iyo sirta koontada',
      'edit_profile': 'Wax ka badal Profile-ka',
      'edit_profile_sub': 'Cusbooneysii magacaaga iyo xogtaada',
      'logout': 'Ka Bax App-ka',
      'logout_sub': 'Ka bax koontadaada hadda',
      'logout_confirm': 'Ma hubtaa inaad rabto inaad ka baxdo app-ka?',
      'cancel': 'Iska daa',
      'save': 'Badbaadi',
      'profile_title': 'Cusbooneysii Profile-ka',
      'full_name': 'Magacaaga oo Buuxa',
      'theme_light': 'Habka Iftiinka',
      'theme_dark': 'Habka Madowga',
      'theme_system': 'Nidaamka Telefoonka',
      'success_profile': 'Profile-ka waa la cusbooneysiiyay!',
      'success_lang': 'Luqadda waa la beddelay!',
      'quick_access': 'Quick Access',
      'quick_access_sub': 'Dooro shortcuts-ka ka muuqda bogga guriga.',
      'configure': 'Hagaaji',
      'uploading': 'Sawirka ayaa la soo raryaa...',
      'avatar_success': 'Sawirka profile-ka waa la beddelay!',
    }
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('app_language') ?? 'en';
      _isNotificationOn = prefs.getBool('app_notifications') ?? true;
    });
  }

  Future<void> _toggleLanguage() async {
    final newLang = _language == 'en' ? 'so' : 'en';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', newLang);
    setState(() {
      _language = newLang;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translations[_language]!['success_lang']!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _toggleNotifications() async {
    final newNotif = !_isNotificationOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_notifications', newNotif);
    setState(() {
      _isNotificationOn = newNotif;
    });
  }

  String _t(String key) {
    return _translations[_language]?[key] ?? key;
  }

  // ========== 📸 SHAYGA CUSUB: PICK & UPLOAD AVATAR TO SUPABASE ==========
  Future<void> _pickAndUploadAvatar() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Si sawirka uusan u weynaan
    );

    if (image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      // Magac gaar ah u sii sawirka adigoo isticmaalaya User ID
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 1. Upload u garee Supabase Storage bucket-ka magaciisu yahay 'avatars'
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(fileName, bytes);

      // 2. Soo qabo Public URL-ka sawirkaas
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // 3. Ku cusbooneysii user metadata-ha 'avatar_url'
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('avatar_success')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Edit Profile Dialog (Name only)
  void _editProfile(String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(_t('profile_title'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: _t('full_name'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_t('cancel'),
                      style: const TextStyle(color: Colors.grey)),
                ),
                _isLoading
                    ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(color: AppColors.primary))
                    : ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    setDialogState(() => _isLoading = true);
                    try {
                      await Supabase.instance.client.auth.updateUser(
                        UserAttributes(data: {'full_name': name}),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_t('success_profile')),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } finally {
                      setDialogState(() => _isLoading = false);
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: Text(_t('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Theme selector bottom sheet
  void _showThemeSelector(ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('appearance'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _themeOptionTile(themeProvider, ThemeMode.light,
                  Icons.light_mode_rounded, _t('theme_light')),
              const SizedBox(height: 8),
              _themeOptionTile(themeProvider, ThemeMode.dark,
                  Icons.dark_mode_rounded, _t('theme_dark')),
              const SizedBox(height: 8),
              _themeOptionTile(themeProvider, ThemeMode.system,
                  Icons.settings_brightness_rounded, _t('theme_system')),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOptionTile(ThemeProvider themeProvider, ThemeMode mode,
      IconData icon, String label) {
    final isSelected = themeProvider.themeMode == mode;
    return GestureDetector(
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : Colors.grey, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  // REUSABLE AVATAR WIDGET (Durbadiiba sawirka soo bandhiga ama xarfaha)
  Widget _buildAvatarWidget(String initials, String? avatarUrl, double size, {bool showEditIcon = false}) {
    return GestureDetector(
      onTap: _pickAndUploadAvatar,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(size * 0.28),
              image: avatarUrl != null
                  ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: avatarUrl == null
                ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.4,
                ),
              ),
            )
                : null,
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(size * 0.28),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final user = SupabaseService.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User';
    final email = user?.email ?? '';
    final avatarUrl = user?.userMetadata?['avatar_url']; // Soo qabo sawirka hadduu jiro
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    String currentThemeLabel = _t('theme_system');
    if (themeProvider.themeMode == ThemeMode.light) currentThemeLabel = _t('theme_light');
    if (themeProvider.themeMode == ThemeMode.dark) currentThemeLabel = _t('theme_dark');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('settings'),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _t('sub'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E9EAE),
                          ),
                        ),
                      ],
                    ),
                    _buildAvatarWidget(initials, avatarUrl, 44), // Header Avatar
                  ],
                ),
              ),
            ),

            // ========== PROFILE CARD ==========
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      _buildAvatarWidget(initials, avatarUrl, 56, showEditIcon: true), // Main Profile Avatar
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF1A1A2E)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF9E9EAE)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary),
                        onPressed: () => _editProfile(userName),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ========== PREFERENCES BOX ==========
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('pref'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
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
                          _buildSettingItem(
                            icon: Icons.palette_outlined,
                            title: _t('appearance'),
                            subtitle: _t('appearance_sub'),
                            trailing: currentThemeLabel,
                            iconBg: const Color(0xFF8B5CF6),
                            onTap: () => _showThemeSelector(themeProvider),
                          ),
                          _divider(),
                          _buildSettingItem(
                            icon: Icons.language_rounded,
                            title: _t('lang'),
                            subtitle: _t('lang_sub'),
                            trailing: _language == 'en' ? 'English' : 'Soomaali',
                            iconBg: const Color(0xFF3B82F6),
                            onTap: _toggleLanguage,
                          ),
                          _divider(),
                          _buildSettingItem(
                            icon: Icons.flash_on_outlined,
                            title: _t('quick_access'),
                            subtitle: _t('quick_access_sub'),
                            trailing: _t('configure'),
                            iconBg: const Color(0xFF8B5CF6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QuickAccessSettingsScreen(),
                              ),
                            ),
                          ),
                          _divider(),
                          _buildSettingItem(
                            icon: _isNotificationOn
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_off_outlined,
                            title: _t('notif'),
                            subtitle: _t('notif_sub'),
                            trailing: _isNotificationOn ? 'On' : 'Off',
                            iconBg: const Color(0xFF10B981),
                            onTap: _toggleNotifications,
                          ),
                          _divider(),
                          _buildSettingItem(
                            icon: Icons.lock_outline_rounded,
                            title: _t('privacy'),
                            subtitle: _t('privacy_sub'),
                            trailing: 'Secured',
                            iconBg: const Color(0xFFF59E0B),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Privacy settings are automatically secured.'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ========== LOGOUT CARD ==========
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
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _t('logout'),
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      _t('logout_sub'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9E9EAE)),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.error,
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    required Color iconBg,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconBg, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9EAE)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailing,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9EAE)),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Color(0xFFCCCCDD),
          ),
        ],
      ),
      onTap: onTap,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(_t('logout_confirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t('cancel'), style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/signup');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(_t('logout')),
          ),
        ],
      ),
    );
  }
}