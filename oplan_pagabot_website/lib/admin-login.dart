import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminLoginPage(),
    ),
  );
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  // Password Validation States
  String _password = '';
  bool _obscureText = true;
  bool _rememberMe = false;

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasNumberOrSpecial =>
      _password.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'));

  // Carousel Controller
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;

  final List<String> _carouselText = [
    'The aim of OPLAN PAG-ABOT is to reach out and provide comprehensive support and services to street dwellers to help them reintegrate into society and improve their quality of life.',
    'Enhancing public safety by connecting vulnerable individuals in street situations with proper care and responsive local facilities.',
    'A unified platform committed to reducing street situations and building a more compassionate region for everyone.',
  ];

  @override
  void initState() {
    super.initState();
    _startCarousel();
  }

  void _startCarousel() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _carouselText.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
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
    final bool isDesktop = size.width > 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              height: isDesktop ? 600 : null,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
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

  // ── Left Side Carousel ───────────────────────────────────────────────────────
  Widget _buildLeftCarousel({bool isMobile = false}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(40),
      height: isMobile ? 500 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Image.asset(
            'assets/images/main-logo.png',
            height: 38,
            errorBuilder: (_, __, ___) => const Text(
              'DSWD Logo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
          // Carousel Image & Text
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _carouselText.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/IMG-main-oplan_landing page.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Text('Image Preview'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _carouselText[index],
                        textAlign: TextAlign.left,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _carouselText.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? const Color(0xFF283891) // DSWD Blue
                      : Colors.grey[300],
                  border: Border.all(
                    color: _currentPage == index
                        ? const Color(0xFF283891)
                        : Colors.grey[400]!,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Right Side Form ──────────────────────────────────────────────────────────
  Widget _buildRightForm() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg/bg-admin-login-gradient.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Center(
                child: Column(
                  children: [
                    Text(
                      'Log in',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF283891),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120, // Wider line in reference
                      height: 1.5,
                      color: const Color(0xFF283891),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Username input
              Text(
                'Username',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Enter Username',
                iconPath: 'assets/icon/mail.png',
              ),
              const SizedBox(height: 20),

              // Password input
              Text(
                'Password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Enter Password',
                iconPath: 'assets/icon/lock.png',
                isPassword: true,
                onChanged: (val) {
                  setState(() {
                    _password = val;
                  });
                },
              ),

              // Password Validation Feedbacks
              if (_password.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ValidationRow(
                  label: 'Required 8 characters minimum',
                  isValid: _hasMinLength,
                ),
                _ValidationRow(
                  label: 'Required 1 capital letter minimum',
                  isValid: _hasUppercase,
                ),
                _ValidationRow(
                  label: 'Required 1 special character or number (@/134...)',
                  isValid: _hasNumberOrSpecial,
                ),
              ],

              const SizedBox(height: 20),

              // Remember & Forgot
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
                          onChanged: (val) {
                            setState(() => _rememberMe = val ?? false);
                          },
                          activeColor: const Color(0xFF283891),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember Password',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF283891),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283891),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
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
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey[400],
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              iconPath,
              width: 18,
              height: 18,
              color: Colors.grey[500],
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
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  final String label;
  final bool isValid;
  const _ValidationRow({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isValid ? Colors.green : Colors.red,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: isValid ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
