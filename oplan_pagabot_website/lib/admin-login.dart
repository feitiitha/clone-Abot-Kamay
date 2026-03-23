import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage-admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  // ── Form State ───────────────────────────────────────────────────────────────
  String _username = '';
  String _password = '';
  bool _obscureText = true;
  bool _rememberMe = false;

  // ── Lockout State ────────────────────────────────────────────────────────────
  int _attempts = 0;
  DateTime? _lockoutUntil;
  bool _requiresCaptcha = false;
  bool _captchaSolved = false;
  bool _isSuspended = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogin() {
    if (_isSuspended) {
      _showError('Permanent account suspension until manually unlocked by another super-admin.');
      return;
    }
    if (_lockoutUntil != null) {
      final now = DateTime.now();
      if (now.isBefore(_lockoutUntil!)) {
        final remaining = _lockoutUntil!.difference(now).inSeconds;
        _showError('Account locked out for $remaining more seconds.');
        return;
      } else {
        _lockoutUntil = null;
      }
    }
    if (_requiresCaptcha && !_captchaSolved) {
      _showError('Please complete the CAPTCHA requirement before logging in.');
      return;
    }

    // Dummy validation to trigger lockout
    if (_username != "superadmin" || _password != "admin123") {
      setState(() {
        _attempts++;
        if (_attempts >= 10) {
          _isSuspended = true;
          _showError('Permanent account suspension until manually unlocked by another super-admin.');
        } else if (_attempts >= 5) {
          _lockoutUntil = DateTime.now().add(const Duration(minutes: 15));
          _showError('5 Attempts reached: 15-minute lockout applied. Email notification sent to admin.');
        } else if (_attempts >= 3) {
          _lockoutUntil = DateTime.now().add(const Duration(minutes: 1));
          _requiresCaptcha = true;
          _captchaSolved = false;
          _showError('3 Attempts reached: 1-minute lockout. CAPTCHA required for next login.');
        } else {
          _showError('Invalid login. Attempt $_attempts.');
        }
      });
      return;
    }

    // Success reset
    _attempts = 0;
    _requiresCaptcha = false;
    _captchaSolved = false;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminDashboardHomepage(),
      ),
    );
  }


  // ── Carousel State ───────────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;

  // FIX 2: Slowed down — 7 s interval, 800 ms animation (was 4 s / 600 ms)
  static const _kCarouselInterval = Duration(seconds: 7);
  static const _kCarouselAnimation = Duration(milliseconds: 800);

  final List<Map<String, String>> _slides = [
    {
      'text':
          'The aim of OPLAN PAG-ABOT is to reach out and provide comprehensive '
          'support and services to street dwellers to help them reintegrate into '
          'society and improve their quality of life.',
      'image': 'assets/images/IMG-main-oplan_landing page.png',
    },
    {
      'text':
          'Enhancing public safety by connecting vulnerable individuals in street '
          'situations with proper care and responsive local facilities.',
      'image': 'assets/images/IMG-main-oplan_landing page.png',
    },
    {
      'text':
          'A unified platform committed to reducing street situations and building '
          'a more compassionate region for everyone.',
      'image': 'assets/images/IMG-main-oplan_landing page.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startCarousel();
  }

  void _startCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(_kCarouselInterval, (_) {
      if (_pageController.hasClients) {
        final next = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          next,
          duration: _kCarouselAnimation,
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  // FIX 2b: Clicking a dot jumps immediately AND resets the auto-timer
  void _jumpToPage(int index) {
    _carouselTimer?.cancel();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _startCarousel(); // restart timer from this point
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Outer page background
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/bg_final-admin-login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isDesktop ? 1000 : 450,
              height: isDesktop ? 620 : null,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(flex: 5, child: _buildLeftCarousel()),
                          Expanded(flex: 5, child: _buildRightForm()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildLeftCarousel(isMobile: true),
                          _buildRightForm(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Left Side: Carousel ──────────────────────────────────────────────────────
  Widget _buildLeftCarousel({bool isMobile = false}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(36, 36, 36, 28),
      height: isMobile ? 520 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Image.asset(
            'assets/images/main-logo.png',
            height: 38,
            errorBuilder: (_, __, ___) => Text(
              'DSWD',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: const Color(0xFF283891),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Slide content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) {
                final slide = _slides[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          slide['image']!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF0FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_rounded,
                              size: 56,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Slide text
                    Expanded(
                      flex: 2,
                      child: Text(
                        slide['text']!,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: const Color(0xFF6B7280),
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // FIX 2: Clickable dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final isActive = _currentPage == i;
              return GestureDetector(
                onTap: () => _jumpToPage(i), // tap to jump
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: isActive ? 28 : 10, // active dot stretches into pill
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF283891)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF283891)
                          : Colors.grey[400]!,
                      width: 1,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Right Side: Login Form ───────────────────────────────────────────────────
  Widget _buildRightForm() {
    return Container(
      // FIX 1: bg-admin-login-gradient.png applied here as DecorationImage
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg/bg-admin-login-gradient.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Center(
                child: Column(
                  children: [
                    Text(
                      'Log in',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF283891),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 120,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF283891),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── Username ──
              _FieldLabel(label: 'Username'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Enter Username',
                iconPath: 'assets/icon/mail.png',
                fallbackIcon: Icons.mail_outline_rounded,
                onChanged: (val) => setState(() => _username = val),
              ),
              const SizedBox(height: 20),

              // ── Password ──
              _FieldLabel(label: 'Password'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Enter Password',
                iconPath: 'assets/icon/lock.png',
                fallbackIcon: Icons.lock_outline_rounded,
                isPassword: true,
                onChanged: (val) => setState(() => _password = val),
              ),

              // FIX 3: Single consolidated password hint row (Fixed height to prevent container movement)
              SizedBox(
                height: 70,
                child: _password.isNotEmpty
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _PasswordHintRow(password: _password),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 10),

              // ── Remember me / Forgot password ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                          activeColor: const Color(0xFF283891),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember Password',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF283891),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── CAPTCHA Display (Dynamic) ──
              if (_requiresCaptcha) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _captchaSolved,
                            onChanged: (v) {
                              setState(() => _captchaSolved = v ?? false);
                            },
                            activeColor: const Color(0xFF15803D),
                          ),
                          Text(
                            "I'm not a robot",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: DC.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.security, color: Colors.blue[800], size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Login Button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283891),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required String iconPath,
    required IconData fallbackIcon,
    bool isPassword = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        obscureText: isPassword && _obscureText,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey[400],
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13),
            child: Image.asset(
              iconPath,
              width: 18,
              height: 18,
              color: Colors.grey[500],
              errorBuilder: (_, __, ___) =>
                  Icon(fallbackIcon, size: 18, color: Colors.grey[500]),
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

// ── Field Label ────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// ── FIX 3: Single password hint widget ────────────────────────────────────────
// Shows ONE compact row that says "Password requirements not met" or "✓ Looks good!"
// instead of listing 3 separate validation rows while typing.
class _PasswordHintRow extends StatelessWidget {
  final String password;
  const _PasswordHintRow({required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final reqLen = password.length >= 8;
    final reqUpper = password.contains(RegExp(r'[A-Z]'));
    final reqLower = password.contains(RegExp(r'[a-z]'));
    final reqNum = password.contains(RegExp(r'[0-9]'));
    final reqSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    final allMet = reqLen && reqUpper && reqLower && reqNum && reqSpecial;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: allMet
            ? const Color(0xFFEAFBF0) // soft green bg
            : const Color(0xFFFFF3F3), // soft red bg
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: allMet
              ? const Color(0xFF34C777).withOpacity(0.4)
              : const Color(0xFFE84545).withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              allMet ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              size: 15,
              color: allMet ? const Color(0xFF1A7A48) : const Color(0xFFBF4040),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              allMet
                  ? 'Password looks good!'
                  : 'Must be 8+ characters, include a capital & lowercase letter, a number, and a special character.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: allMet
                    ? const Color(0xFF1A7A48)
                    : const Color(0xFFBF4040),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
