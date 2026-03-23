import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abot Kamay Landing Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D3A8A)),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

// ── Design Tokens ──────────────────────────────────────────────────────────────
class C {
  static const primary = Color(0xFF1D3A8A);
  static const primaryDark = Color(0xFF142970);
  static const primaryLight = Color(0xFF2F55C8);
  static const bgPage = Color(0xFFF4F5FB);
  static const bgHero = Color(0xFFECEEFC);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0D1B3E);
  static const textMid = Color(0xFF3D4F6E);
  static const textSoft = Color(0xFF7A8BAA);
  static const borderLight = Color(0xFFE3E8F7);
  static const tagBlue = Color(0xFFE6EAFF);
  static const tagBlueText = Color(0xFF1D3A8A);
}

// ── Landing Page ───────────────────────────────────────────────────────────────
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scroll = ScrollController();
  final _homeKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _goto(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 680),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 960;

    return Scaffold(
      backgroundColor: C.bgPage,
      extendBodyBehindAppBar: true,
      appBar: _Navbar(
        isDesktop: isDesktop,
        onHome: () => _goto(_homeKey),
        onFeatures: () => _goto(_featuresKey),
        onAbout: () => _goto(_aboutKey),
        onContact: () => _goto(_contactKey),
      ),
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          children: [
            _HeroSection(sectionKey: _homeKey, isDesktop: isDesktop),
            _StatsBar(),
            _FeaturesSection(sectionKey: _featuresKey, isDesktop: isDesktop),
            _AboutSection(sectionKey: _aboutKey, isDesktop: isDesktop),
            _CtaSection(sectionKey: _contactKey),
            _Footer(isDesktop: isDesktop),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: C.primary,
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      ),
    );
  }
}

// ── Navbar ─────────────────────────────────────────────────────────────────────
class _Navbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDesktop;
  final VoidCallback onHome, onFeatures, onAbout, onContact;

  const _Navbar({
    required this.isDesktop,
    required this.onHome,
    required this.onFeatures,
    required this.onAbout,
    required this.onContact,
  });

  @override
  Size get preferredSize => const Size.fromHeight(77);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 72 : 24,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: C.borderLight, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/main-logo.png',
              height: 44,
              errorBuilder: (_, _, _) => Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: C.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'DSWD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: C.primary,
                    ),
                  ),
                ],
              ),
            ),

            if (isDesktop)
              Row(
                children: [
                  _NavLink('Home', onHome),
                  _NavLink('Features', onFeatures),
                  _NavLink('About', onAbout),
                  _NavLink('Contact', onContact),
                ],
              )
            else
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: C.primary,
                  size: 28,
                ),
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink(this.label, this.onTap);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _hover ? C.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _hover ? C.primary : C.textMid,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero Section ───────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isDesktop;
  const _HeroSection({required this.sectionKey, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDE4FF), Colors.white],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 28,
        vertical: isDesktop ? 80 : 48,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: _HeroText()),
                const SizedBox(width: 64),
                Expanded(flex: 10, child: _HeroImageCard()),
              ],
            )
          : Column(
              children: [
                _HeroText(),
                const SizedBox(height: 40),
                _HeroImageCard(),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: C.tagBlue,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: C.primaryLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DSWD Pag-Abot Program',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: C.tagBlueText,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Headline
        Text(
          'Reaching Those\nin Need, Together',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -1.0,
            color: C.textDark,
          ),
        ),
        const SizedBox(height: 10),

        // Gradient underline accent
        Container(
          width: 180,
          height: 4,
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [C.primaryLight, Color(0xFFE84545)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Subtitle
        Text(
          'Abot Kamay is a comprehensive platform that expands and '
          'supports the DSWD Pag-Abot Program, connecting citizens '
          'with vulnerable families and individuals in street situations '
          'while providing essential support and program information.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.75,
            color: C.textMid,
          ),
        ),
        const SizedBox(height: 36),

        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _PrimaryButton(label: 'Download App', onTap: () {}),
            _OutlineButton(label: 'Learn More', onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _HeroImageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative blobs
        Positioned(
          right: -20,
          bottom: -20,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.primary.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          left: -10,
          top: -10,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE84545).withOpacity(0.06),
            ),
          ),
        ),

        // Image card
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: C.primary.withOpacity(0.16),
                blurRadius: 48,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/IMG-main-oplan_landing page.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      C.primary.withOpacity(0.12),
                      C.primaryLight.withOpacity(0.22),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 80,
                        color: C.primary.withOpacity(0.35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'OPLAN Pag-Abot',
                        style: GoogleFonts.plusJakartaSans(
                          color: C.primary.withOpacity(0.45),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stats Bar ──────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: C.primary,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 40,
        runSpacing: 20,
        children: const [
          _StatItem(
            targetValue: 10000,
            suffix: '+',
            label: 'Reports Submitted',
          ),
          _StatItem(targetValue: 4, suffix: ' Regions', label: 'Coverage Area'),
          _StatItem(targetValue: 95, suffix: '%', label: 'Response Rate'),
        ],
      ),
    );
  }
}

class _StatItem extends StatefulWidget {
  final int targetValue;
  final String suffix;
  final String label;

  const _StatItem({
    required this.targetValue,
    required this.suffix,
    required this.label,
  });

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = IntTween(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Apply commas to large numbers
            String formattedValue = _animation.value
                .toString()
                .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                );

            return Text(
              '$formattedValue${widget.suffix}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Features Section ───────────────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isDesktop;
  const _FeaturesSection({required this.sectionKey, required this.isDesktop});

  static const _features = [
    _FeatureData(
      icon: Icons.assignment_rounded,
      iconBg: Color(0xFFEAEEFF),
      iconColor: Color(0xFF1D3A8A),
      title: 'Reporting',
      description:
          'Easily report sightings of families or individuals in street situations '
          'using your mobile phone. Share the location and details—your report goes '
          'directly to the proper DSWD office in Region IV-A for faster action.',
    ),
    _FeatureData(
      icon: Icons.track_changes_rounded,
      iconBg: Color(0xFFE8F7EF),
      iconColor: Color(0xFF1A7A48),
      title: 'Report Tracking',
      description:
          'Stay updated after you submit a report. Track its status and receive '
          'real-time notifications so you always know your report is being reviewed '
          'and acted upon.',
    ),
    _FeatureData(
      icon: Icons.smart_toy_rounded,
      iconBg: Color(0xFFFFF0E8),
      iconColor: Color(0xFFBF5000),
      title: 'Chat Bot',
      description:
          'Have questions about DSWD programs or services? Our chatbot is here to '
          'help 24/7. Get quick, clear answers anytime—no waiting, no searching.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 88,
        horizontal: isDesktop ? 80 : 24,
      ),
      child: Column(
        children: [
          _SectionTag(label: 'Platform Features'),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Core Features'),
          const SizedBox(height: 12),
          _SectionSubtitle(
            subtitle:
                'Integrated modules designed to help identify, support, and assist\n'
                'families and individuals in street situations.',
          ),
          const SizedBox(height: 56),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: _features.map((f) => _FeatureCard(data: f)).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, description;
  const _FeatureData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 320,
        height: 380,
        padding: const EdgeInsets.all(32),
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: C.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hover ? C.primary.withOpacity(0.22) : C.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hover
                  ? C.primary.withOpacity(0.10)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _hover ? 32 : 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: d.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(d.icon, color: d.iconColor, size: 28),
            ),
            const SizedBox(height: 20),

            Text(
              d.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: C.textDark,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              d.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: C.textMid,
                height: 1.65,
              ),
            ),

            const SizedBox(height: 22),
            Row(
              children: [
                Text(
                  'Learn more',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: d.iconColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 15, color: d.iconColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── About Section ──────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isDesktop;
  const _AboutSection({required this.sectionKey, required this.isDesktop});

  static const _cards = [
    _AboutData(
      icon: Icons.warning_amber_rounded,
      iconColor: Color(0xFFBF5000),
      accentColor: Color(0xFFBF5000),
      title: 'Street Situations Need Faster Action',
      body:
          'Many reports of families and individuals in street situations are '
          'scattered across different channels, causing delays in response '
          'and assistance.',
    ),
    _AboutData(
      icon: Icons.people_alt_rounded,
      iconColor: Color(0xFF1D3A8A),
      accentColor: Color(0xFF1D3A8A),
      title: 'Citizens Can Help Easily',
      body:
          'Abot Kamay gives citizens a simple way to report street situations, '
          'check report updates, and ask questions about DSWD programs.',
    ),
    _AboutData(
      icon: Icons.hub_rounded,
      iconColor: Color(0xFF1A7A48),
      accentColor: Color(0xFF1A7A48),
      title: 'Information Made Accessible',
      body:
          'With clearer reports and better information access, coordination '
          'improves and assistance can reach people in need more quickly.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFFD1D1), Colors.white],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 88,
        horizontal: isDesktop ? 80 : 24,
      ),
      child: Column(
        children: [
          _SectionTag(label: 'Our Mission'),
          const SizedBox(height: 16),
          _SectionTitle(title: 'About Abot Kamay'),
          const SizedBox(height: 12),
          _SectionSubtitle(
            subtitle:
                'Abot Kamay is a digital platform that helps citizens report street '
                'situations\nand supports DSWD Pag-Abot in responding faster and more '
                'effectively in Region IV-A.',
          ),
          const SizedBox(height: 56),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: _cards.map((c) => _AboutCard(data: c)).toList(),
          ),
        ],
      ),
    );
  }
}

class _AboutData {
  final IconData icon;
  final Color iconColor, accentColor;
  final String title, body;
  const _AboutData({
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.title,
    required this.body,
  });
}

class _AboutCard extends StatefulWidget {
  final _AboutData data;
  const _AboutCard({required this.data});

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 320,
        height: 280,
        padding: const EdgeInsets.all(32),
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hover ? d.accentColor.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hover
                  ? d.accentColor.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _hover ? 32 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored accent bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: d.accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(d.icon, color: d.iconColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    d.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: C.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              d.body,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: C.textMid,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CTA Section ────────────────────────────────────────────────────────────────
class _CtaSection extends StatelessWidget {
  final GlobalKey sectionKey;
  const _CtaSection({required this.sectionKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF142970), Color(0xFF1D3A8A), Color(0xFF2F55C8)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Ready to make an impact?',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Join the movement to support vulnerable families and individuals '
              'in street situations. Start reporting, get information, or find services today.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: Colors.white70,
                height: 1.65,
              ),
            ),
          ),
          const SizedBox(height: 40),

          Wrap(
            spacing: 16,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Download App',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: C.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Learn More',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final bool isDesktop;
  const _Footer({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 52,
        horizontal: isDesktop ? 80 : 28,
      ),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/main-logo.png',
                      height: 44,
                      errorBuilder: (_, _, _) => Text(
                        'DSWD',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: C.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Supporting DSWD Pag-Abot Program\nfor vulnerable communities.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: C.textMid,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _SocialIcon(icon: Icons.facebook_rounded),
                        const SizedBox(width: 10),
                        _SocialIcon(icon: Icons.link_rounded),
                        const SizedBox(width: 10),
                        _SocialIcon(icon: Icons.mail_outline_rounded),
                      ],
                    ),
                  ],
                ),

                // Link columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FooterLinkColumn(
                      heading: 'DSWD',
                      links: [
                        'Official Website',
                        'Pag-Abot Program',
                        'Region IV-A',
                      ],
                    ),
                    const SizedBox(width: 64),
                    _FooterLinkColumn(
                      heading: 'Quick Links',
                      links: ['Home', 'Features', 'About Us', 'Contact'],
                    ),
                    const SizedBox(width: 64),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Us',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: C.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FooterContactRow(
                          icon: Icons.phone_rounded,
                          text: 'DITO: 0991 234 512',
                        ),
                        const SizedBox(height: 10),
                        _FooterContactRow(
                          icon: Icons.email_rounded,
                          text: 'contact.devoted@gmail.com',
                        ),
                        const SizedBox(height: 10),
                        _FooterContactRow(
                          icon: Icons.location_on_rounded,
                          text: 'Dasmariñas, Cavite, Philippines',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                Image.asset(
                  'assets/images/main-logo.png',
                  height: 44,
                  errorBuilder: (_, _, _) => Text(
                    'DSWD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: C.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Supporting DSWD Pag-Abot Program',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: C.textMid,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 40),
          Divider(color: C.borderLight, thickness: 1),
          const SizedBox(height: 24),

          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2024 Abot Kamay. Supporting DSWD Pag-Abot Program. SDG 1: No Poverty.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: C.textSoft,
                      ),
                    ),
                    Row(
                      children: [
                        _HoverTextLink(
                          text: 'Privacy Policy',
                          fontSize: 11,
                          onTap: () {},
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '|',
                            style: TextStyle(
                              color: C.borderLight,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        _HoverTextLink(
                          text: 'Terms of Service',
                          fontSize: 11,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  '© 2024 Abot Kamay. SDG 1: No Poverty.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: C.textSoft,
                  ),
                ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hover ? C.primary : C.bgPage,
            shape: BoxShape.circle,
            border: Border.all(
              color: _hover ? C.primary : C.borderLight,
              width: 1,
            ),
          ),
          child: Icon(
            widget.icon,
            color: _hover ? Colors.white : C.textMid,
            size: 17,
          ),
        ),
      ),
    );
  }
}

class _FooterLinkColumn extends StatelessWidget {
  final String heading;
  final List<String> links;
  const _FooterLinkColumn({required this.heading, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: C.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HoverTextLink(text: l, onTap: () {}),
          ),
        ),
      ],
    );
  }
}

class _FooterContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FooterContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: C.textSoft, size: 14),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: C.textMid),
        ),
      ],
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────

class _SectionTag extends StatelessWidget {
  final String label;
  const _SectionTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: C.tagBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: C.tagBlueText,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        color: C.textDark,
        letterSpacing: -0.5,
        height: 1.15,
      ),
    );
  }
}

class _SectionSubtitle extends StatelessWidget {
  final String subtitle;
  const _SectionSubtitle({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        color: C.textSoft,
        height: 1.65,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: C.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      child: Text(label),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: C.primary,
        side: const BorderSide(color: C.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      child: Text(label),
    );
  }
}

class _HoverTextLink extends StatefulWidget {
  final String text;
  final double fontSize;
  final VoidCallback onTap;

  const _HoverTextLink({
    required this.text,
    required this.onTap,
    this.fontSize = 13,
  });

  @override
  State<_HoverTextLink> createState() => _HoverTextLinkState();
}

class _HoverTextLinkState extends State<_HoverTextLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.plusJakartaSans(
            fontSize: widget.fontSize,
            color: _hover ? C.primary : C.textMid,
            fontWeight: _hover ? FontWeight.w600 : FontWeight.w400,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
