import 'dart:math' as math; // Waxaa loo baahan yahay Password Generator-ka
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../../services/supabase_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String _language = 'en';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Shuruudaha Password-ka
  bool get _hasEightChars => _passwordController.text.length >= 8;
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text &&
          _passwordController.text.isNotEmpty;

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'title': 'Create Your Account',
      'sub': 'Join Notes and organize your ideas beautifully.',
      'name': 'Full Name',
      'name_hint': 'Enter your full name',
      'email': 'Email',
      'email_hint': 'Enter your email',
      'pass': 'Password',
      'pass_hint': 'Create a password',
      'confirm': 'Confirm Password',
      'confirm_hint': 'Confirm your password',
      'agree_start': 'I agree to the ',
      'agree_terms': 'Terms of Service',
      'agree_and': ' and ',
      'agree_privacy': 'Privacy Policy',
      'signup': 'Sign Up',
      'or': 'or continue with',
      'already': 'Already have an account? ',
      'signin': 'Sign in',
      'pass_req':
      'Use at least 8 characters with a mix of letters (caps included) & numbers',
      'err_name': 'Please enter your full name',
      'err_email': 'Please enter your email',
      'err_req': 'Please fulfill all password requirements',
      'err_match': 'Passwords do not match',
      'err_agree': 'Please agree to the Terms of Service',
      'gen_pass': 'Generate Strong Password',
    },
    'so': {
      'title': 'Fure Koonto',
      'sub': 'Isdiiwaangeli si aad u bilowdo qoraalada',
      'name': 'Magaca Buuxa',
      'name_hint': 'Geli magacaaga oo buuxa',
      'email': 'Imeelka',
      'email_hint': 'Geli ciwaankaaga imeelka',
      'pass': 'Furaha sirta ah',
      'pass_hint': 'Abuur fure sir ah',
      'confirm': 'Xaqiiji Furaha',
      'confirm_hint': 'Ku celi furaha sirta ah',
      'agree_start': 'Waxaan ogolahay ',
      'agree_terms': 'Shuruudaha Adeegga',
      'agree_and': ' iyo ',
      'agree_privacy': 'Shuruucda Khaaska ah',
      'signup': 'Isdiiwaangeli',
      'or': 'ama ku sii soco',
      'already': 'Miyaad leedahay koonto? ',
      'signin': 'Soo gal',
      'pass_req':
      'Adeegso ugu yaraan 8 xaraf oo isugu jira xarfo waaweyn iyo tiro',
      'err_name': 'Fadlan geli magacaaga oo buuxa',
      'err_email': 'Fadlan geli ciwaanka imeelka',
      'err_req': 'Fadlan buuxi dhammaan shuruudaha furaha sirta ah',
      'err_match': 'Furayaashu isku mid ma aha',
      'err_agree': 'Fadlan ogolaataa shuruudaha adeegga',
      'gen_pass': 'Abuur Fure Sir ah oo Adag',
    }
  };

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _t(String key) {
    return _translations[_language]?[key] ?? key;
  }

  // Function dhalinaya Password aad u adag
  void _generateStrongPassword() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*';
    const allChars = '$uppercase$lowercase$numbers$symbols';

    final rand = math.Random.secure();

    // Hubi in ugu yaraan mid kasta uu ku jiro si shuruuduhu u buuxsamaan
    List<String> passwordList = [
      uppercase[rand.nextInt(uppercase.length)],
      lowercase[rand.nextInt(lowercase.length)],
      numbers[rand.nextInt(numbers.length)],
      symbols[rand.nextInt(symbols.length)],
    ];

    // Buuxi xarfaha dhiman ilaa uu ka gaaro 12 xaraf
    for (int i = 0; i < 8; i++) {
      passwordList.add(allChars[rand.nextInt(allChars.length)]);
    }

    // Isku dhex dhiqi xarfaha si ay qaab random ah u yeeshaan
    passwordList.shuffle(rand);
    final strongPassword = passwordList.join();

    setState(() {
      _passwordController.text = strongPassword;
      _confirmPasswordController.text = strongPassword;
      // Ka dhig kuwo muuqda si uu qofku u arko uuna u koobiyeysto
      _obscurePassword = false;
      _obscureConfirm = false;
    });
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showSnackBar(_t('err_name'), isError: true);
      return;
    }
    if (email.isEmpty) {
      _showSnackBar(_t('err_email'), isError: true);
      return;
    }
    if (!_hasEightChars || !_hasNumber || !_hasUppercase) {
      _showSnackBar(_t('err_req'), isError: true);
      return;
    }
    if (!_passwordsMatch) {
      _showSnackBar(_t('err_match'), isError: true);
      return;
    }
    if (!_agreedToTerms) {
      _showSnackBar(_t('err_agree'), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: name,
      );
      if (mounted) {
        _showSnackBar(
          _language == 'en'
              ? 'Account created! Please check your email to verify.'
              : 'Koontada waa la furay! Fadlan hubi imeelkaaga si aad u xaqiijiso.',
          isError: false,
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.signInWithGoogle();
      if (mounted) {
        _showSnackBar(
          _language == 'en'
              ? 'Google Sign-Up successful!'
              : 'Waxaad ku guulaysatay isdiiwaangalinta Google!',
          isError: false,
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar(
        _language == 'en'
            ? 'Google sign-up was cancelled or failed.'
            : 'Isdiiwaangalinta Google waa la baajiyay ama way fashilantay.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Nidaamka rasmiga ah ee Wave Background-ka hoose
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.22,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF1EEFF), Color(0xFFE5DEFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                // Cabirkan wuxuu xaddidayaa balaadhka si uu ugu muuqdo mid kooban S20 Ultra iyo tablets-ka
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    size: 20, color: Color(0xFF0F172A)),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              ActionChip(
                                label: Text(
                                  _language == 'en' ? 'Af-Soomaali' : 'English',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6342E8)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _language = _language == 'en' ? 'so' : 'en';
                                  });
                                },
                                backgroundColor: const Color(0xFFF1EEFF),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF1EEFF),
                                  borderRadius: BorderRadius.circular(26)),
                              child: const Icon(Icons.description_rounded,
                                  color: Color(0xFF6342E8), size: 42),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _t('title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _t('sub'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 28),

                          // Full Name
                          Text(_t('name'),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(
                                _t('name_hint'), Icons.person_outline_rounded),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          Text(_t('email'),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(
                                _t('email_hint'), Icons.mail_outline_rounded),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_t('pass'),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A))),
                              GestureDetector(
                                onTap: _generateStrongPassword,
                                child: Text(
                                  _t('gen_pass'),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6342E8)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(
                                _t('pass_hint'), Icons.lock_outline_rounded,
                                isPassword: true,
                                obscure: _obscurePassword, onToggle: () {
                              setState(
                                      () => _obscurePassword = !_obscurePassword);
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(_t('pass_req'),
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 16),

                          // Confirm Password
                          Text(_t('confirm'),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(
                                _t('confirm_hint'), Icons.lock_outline_rounded,
                                isPassword: true,
                                obscure: _obscureConfirm, onToggle: () {
                              setState(
                                      () => _obscureConfirm = !_obscureConfirm);
                            }),
                          ),
                          const SizedBox(height: 16),

                          // Terms Agreement
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (v) => setState(
                                          () => _agreedToTerms = v ?? false),
                                  activeColor: const Color(0xFF6342E8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  side: const BorderSide(
                                      color: Color(0xFFCBD5E1), width: 1.5),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                          () => _agreedToTerms = !_agreedToTerms),
                                  child: RichText(
                                    text: TextSpan(
                                      text: _t('agree_start'),
                                      style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500),
                                      children: [
                                        TextSpan(
                                            text: _t('agree_terms'),
                                            style: const TextStyle(
                                                color: Color(0xFF6342E8),
                                                fontWeight: FontWeight.w700)),
                                        TextSpan(text: _t('agree_and')),
                                        TextSpan(
                                            text: _t('agree_privacy'),
                                            style: const TextStyle(
                                                color: Color(0xFF6342E8),
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Button Sign Up
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6342E8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                                : Text(_t('signup'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5)),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                      color: Color(0xFFE2E8F0), thickness: 1)),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(_t('or'),
                                    style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                              const Expanded(
                                  child: Divider(
                                      color: Color(0xFFE2E8F0), thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Buttons (Waxaa lagu saxay Icon-ka Google)
                          Row(
                            children: [
                              Expanded(
                                child: _googleSocialButton(
                                  label: 'Google',
                                  onPressed:
                                  _isLoading ? null : _signUpWithGoogle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _socialButton(
                                  label: 'Apple',
                                  icon: Icons.apple,
                                  color: Colors.black,
                                  onPressed: _isLoading ? null : () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _socialButton(
                                  label: 'Facebook',
                                  icon: Icons.facebook,
                                  color: const Color(0xFF1877F2),
                                  onPressed: _isLoading ? null : () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_t('already'),
                                  style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(_t('signin'),
                                    style: const TextStyle(
                                        color: Color(0xFF6342E8),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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

  InputDecoration _inputDecoration(String hint, IconData prefix,
      {bool isPassword = false, bool obscure = false, VoidCallback? onToggle}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(prefix, color: const Color(0xFF6342E8), size: 22),
      suffixIcon: isPassword
          ? IconButton(
          onPressed: onToggle,
          icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF94A3B8),
              size: 22))
          : null,
      filled: true,
      fillColor: const Color(0xFFFAFAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6342E8), width: 1.5)),
    );
  }

  // Badhanka Rasmiga ah ee Google (Midabada leh)
  Widget _googleSocialButton(
      {required String label, required VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide.none,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image-kan wuxuu si toos ah u soo jiidayaa logo-ga saxda ah ee Google adigoo aan asset ku darin
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
              height: 22,
              width: 22,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.g_mobiledata, size: 24),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(
      {required String label,
        required IconData icon,
        required Color color,
        required VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide.none,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.3);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.2);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint =
    Offset(size.width - (size.width / 4), size.height * 0.4);
    var secondEndPoint = Offset(size.width, size.height * 0.15);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
