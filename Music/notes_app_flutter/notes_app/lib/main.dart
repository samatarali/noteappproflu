import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notes_provider.dart';
import 'services/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/navigation/main_navigation.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  try {
    await Supabase.initialize(
      url: 'https://mlzwtjfminujdhfrmafv.supabase.co',
      anonKey: 'sb_publishable_3hjJ4WwIGN-3A0N_ZrPWBQ_KjGYDqeq',
    );
  } catch (e) {
    initError = e.toString();
    debugPrint("Supabase initialization error: $e");
  }

  runApp(NotesApp(initError: initError));
}

class NotesApp extends StatelessWidget {
  final String? initError;
  const NotesApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Notes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: initError != null
                ? SupabaseErrorScreen(error: initError!)
                : const AuthGate(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/home': (context) => const MainNavigation(initialIndex: 0),
              '/favorites': (context) => const MainNavigation(initialIndex: 1),
              '/create': (context) => const MainNavigation(initialIndex: 2),
              '/categories': (context) => const MainNavigation(initialIndex: 3),
              '/settings': (context) => const MainNavigation(initialIndex: 4),
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return const MainNavigation();
        }

        return const LoginScreen();
      },
    );
  }
}

class SupabaseErrorScreen extends StatelessWidget {
  final String error;
  const SupabaseErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.redAccent,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cillad Database! / Database Connection Error!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fadlan hubi internet-kaaga ama hubi in shaqada database-ku ay sax tahay. / Please check your internet connection or verify your database setup.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: double.infinity,
                    child: SelectableText(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // A refresh or trigger can be made, or let the user hot-restart.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6342E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Isku day mar kale / Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
