import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _language = 'en';

  // 👈 Waxaan ka saarnay 'late' si aan uga fogaano cilladda ka muuqata image_b6101e.png
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'title': 'Welcome Back!',
      'sub': 'Sign in to continue to your notes',
      'email': 'Email',
      'email_hint': 'Enter your email',
      'pass': 'Password',
      'pass_hint': 'Enter your password',
      'forgot': 'Forgot password?',
      'signin': 'Sign In',
      'or': 'or continue with',
      'dont_have': "Don't have an account? ",
      'signup': 'Sign up',
      'empty_error': 'Please fill in all fields',
      'gen_error': 'An error occurred. Try again.',
    },
    'so': {
      'title': 'Ku Soo Dhowow!',
      'sub': 'Soo gal si aad u sii wadato qoraaladaada',
      'email': 'Imeelka',
      'email_hint': 'Geli ciwaankaaga imeelka',
      'pass': 'Furaha sirta ah',
      'pass_hint': 'Geli furaha sirta ah',
      'forgot': 'Miyaad ilowday furaha?',
      'signin': 'Soo Gal',
      'or': 'ama ku sii soco',
      'dont_have': 'Miyaanad lahayn koonto? ',
      'signup': 'Isdiiwaangeli',
      'empty_error': 'Fadlan buuxi meelaha bannaan oo dhan',
      'gen_error': 'Cillad ayaa dhacday. Fadlan isku day markale.',
    }
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController?.dispose(); // 👈 Safe dispose
    super.dispose();
  }

  String _t(String key) {
    return _translations[_language]?[key] ?? key;
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(_t('empty_error'), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.signIn(email: email, password: password);
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar(_t('gen_error'), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.signInWithGoogle();
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar(_t('gen_error'), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = size.height - padding.top - padding.bottom;

    // Badbaado haddii animation-ku uusan weli diyaarsanayn inta lagu jiro reload-ka
    if (_fadeAnimation == null || _slideAnimation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bottom Organic Wave Shape
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.20,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF3EFFF), Color(0xFFE8E0FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Main Form Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: availableHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Language Switcher
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _language = _language == 'en' ? 'so' : 'en';
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1EEFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _language == 'en' ? 'Af-Soomaali' : 'English',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6342E8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: availableHeight * 0.03),

                          // Logo Icon
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F0FF),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: Color(0xFF6342E8),
                                size: 48,
                              ),
                            ),
                          ),
                          SizedBox(height: availableHeight * 0.04),

                          // Welcoming Title & Subtitle
                          Text(
                            _t('title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _t('sub'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: availableHeight * 0.04),

                          // Email Label
                          Text(
                            _t('email'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Email Input Field
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: _t('email_hint'),
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFF6342E8), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password Label
                          Text(
                            _t('pass'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Password Input Field
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: _t('pass_hint'),
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF94A3B8),
                                  size: 22,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFF6342E8), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                _t('forgot'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6342E8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: availableHeight * 0.04),

                          // Sign In Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6342E8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                                : Text(
                              _t('signin'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(height: availableHeight * 0.03),

                          // "or continue with" Divider
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _t('or'),
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                            ],
                          ),
                          SizedBox(height: availableHeight * 0.025),

                          // Social Buttons Row
                          Row(
                            children: [
                              Expanded(
                                child: _socialButton(
                                  label: 'Google',
                                  iconWidget: CustomPaint(
                                    size: const Size(18, 18),
                                    painter: GoogleLogoPainter(),
                                  ),
                                  onPressed: _isLoading ? null : _signInWithGoogle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _socialButton(
                                  label: 'Apple',
                                  iconWidget: const Icon(Icons.apple, color: Colors.black, size: 22),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _socialButton(
                                  label: 'Facebook',
                                  iconWidget: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Don't have an account? Sign up
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _t('dont_have'),
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                  ),
                                  child: Text(
                                    _t('signup'),
                                    style: const TextStyle(color: Color(0xFF6342E8), fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required Widget iconWidget,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 4.5
      ..strokeCap = StrokeCap.square;

    final Rect rect = Rect.fromCircle(center: Offset(r, r), radius: r - paint.strokeWidth / 2);

    paint.color = const Color(0xFEEA4335);
    canvas.drawArc(rect, -2.5, 1.4, false, paint);

    paint.color = const Color(0xFEFBBC05);
    canvas.drawArc(rect, -3.9, 1.4, false, paint);

    paint.color = const Color(0xFE34A853);
    canvas.drawArc(rect, 0.3, 2.2, false, paint);

    paint.color = const Color(0xFE4285F4);
    canvas.drawArc(rect, -1.1, 1.4, false, paint);

    final Paint fillPaint = Paint()
      ..color = const Color(0xFE4285F4)
      ..style = PaintingStyle.fill;

    final double height = size.width / 4.5;

    canvas.drawRect(
      Rect.fromLTWH(r, r - height / 2, r * 0.95, height),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.5);

    final firstControlPoint = Offset(size.width * 0.3, size.height * 0.2);
    final firstEndPoint = Offset(size.width * 0.65, size.height * 0.5);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.85, size.height * 0.7);
    final secondEndPoint = Offset(size.width, size.height * 0.4);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}