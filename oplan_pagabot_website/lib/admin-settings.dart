import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homepage-admin_dashboard.dart'; // To access globalNavIndex and globalTheme
import 'admin-login.dart';

class DC {
  static const primary = Color(0xFF1D3A8A);
  static const primaryDark = Color(0xFF0D1B3E);
  static const textMid = Color(0xFF3D4F6E);
  static const textSoft = Color(0xFF7A8BAA);
  static const border = Color(0xFFE3E8F7);
  static const bgPage = Color(0xFFF4F5FB);
}

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});
  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  int _settingsTabIndex = 0; // 0: My Profile, 1: Security, 2: Appearance

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar (Shared with other screens) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: DC.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage system settings and configurations.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: DC.textMid,
                    ),
                  ),
                ],
              ),
              const TopProfileMenu(),
            ],
          ),
          const SizedBox(height: 24),

          // ── Settings Layout ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Menu
              Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _MenuBtn(
                        icon: Icons.person_outline_rounded,
                        title: 'My Profile',
                        subtitle: 'Edit personal information',
                        selected: _settingsTabIndex == 0,
                        onTap: () =>
                            setState(() => _settingsTabIndex = 0),
                      ),
                      const SizedBox(height: 8),
                      _MenuBtn(
                        icon: Icons.shield_outlined,
                        title: 'Security',
                        subtitle: 'Password & Security Settings',
                        selected: _settingsTabIndex == 1,
                        onTap: () =>
                            setState(() => _settingsTabIndex = 1),
                      ),
                      const SizedBox(height: 8),
                      _MenuBtn(
                        icon: Icons.color_lens_outlined,
                        title: 'Appearance',
                        subtitle: 'Customize theme & display',
                        selected: _settingsTabIndex == 2,
                        onTap: () =>
                            setState(() => _settingsTabIndex = 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _settingsTabIndex == 0
                        ? const _MyProfileContent()
                        : _settingsTabIndex == 1
                        ? const _SecurityContent()
                        : const _AppearanceContent(),
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

class _MenuBtn extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MenuBtn({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? DC.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? DC.primaryDark : DC.textMid),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? DC.primaryDark : DC.textMid,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: DC.textSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MY PROFILE TAB ──
class _MyProfileContent extends StatefulWidget {
  const _MyProfileContent();

  @override
  State<_MyProfileContent> createState() => _MyProfileContentState();
}

class _MyProfileContentState extends State<_MyProfileContent> {
  bool _editPersonal = false;
  bool _editAddress = false;

  void _uploadProfilePrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Profile Picture', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Would you like to upload a new profile picture or remove the current one?',
            style: GoogleFonts.plusJakartaSans(color: DC.textMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: DC.textSoft, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              globalProfileImage.value = null;
              Navigator.pop(context);
            },
            child: Text('Remove', style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              // Mocking an image upload by setting a placeholder or a new path
              globalProfileImage.value = 'assets/profile/admin-avatar.png';
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DC.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Upload', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        // Avatar ring with edit icon
        ValueListenableBuilder<String?>(
          valueListenable: globalProfileImage,
          builder: (context, imgPath, _) {
            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1656A),
                      shape: BoxShape.circle,
                      image: imgPath != null
                          ? DecorationImage(image: AssetImage(imgPath), fit: BoxFit.cover)
                          : null,
                    ),
                    child: imgPath == null
                        ? const Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _uploadProfilePrompt,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: DC.primaryDark, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Stella Mariz Santuyo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: DC.primaryDark,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 12,
                    color: Color(0xFF15803D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Superadmin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: DC.textMid,
            ),
            const SizedBox(width: 6),
            Text(
              'Start Date:   21 December 2024',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Personal Details Card
        _DetailsCard(
          title: 'Personal Details',
          actionLabel: 'Edit Profile',
          isEditing: _editPersonal,
          onActionTap: () => setState(() => _editPersonal = !_editPersonal),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _Field('First Name', 'Stella Mariz', isEditing: _editPersonal)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('Middle Name', 'Prambita', isEditing: _editPersonal)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('Last Name', 'Santuyo', isEditing: _editPersonal)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('Suffix', 'Jr.', isEditing: _editPersonal)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('Sex', 'Female', isEditing: _editPersonal)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _Field('Date of Birth', '12/21/2004', isEditing: _editPersonal),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _Field('Contact Number', '0956 049 0700', isEditing: _editPersonal),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: _Field(
                      'Email Address',
                      'santuyosp@students.nu-dasma.edu.ph',
                      isEditing: _editPersonal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Address Card
        _DetailsCard(
          title: 'Current Address',
          actionLabel: 'Edit Address',
          isEditing: _editAddress,
          onActionTap: () => setState(() => _editAddress = !_editAddress),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Field('House / Unit / Bldg No.', 'Stella Mariz', isEditing: _editAddress),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('Street / Area Name', 'Prambita', isEditing: _editAddress)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('Barangay', 'Santuyo', isEditing: _editAddress)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('City / Municipality', 'Jr.', isEditing: _editAddress)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _Field('Province', '12/21/2004', isEditing: _editAddress)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('Region', '0956 049 0700', isEditing: _editAddress)),
                  const SizedBox(width: 16),
                  Expanded(child: _Field('ZIP / Postal Code', '4115', isEditing: _editAddress)),
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── SECURITY TAB ──
class _SecurityContent extends StatefulWidget {
  const _SecurityContent();

  @override
  State<_SecurityContent> createState() => _SecurityContentState();
}

class _SecurityContentState extends State<_SecurityContent> {
  bool _editPassword = false;
  final _oldPassController = TextEditingController(text: 'password123');
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _reqLen = false;
  bool _reqUpper = false;
  bool _reqLower = false;
  bool _reqNum = false;
  bool _reqSpecial = false;

  @override
  void initState() {
    super.initState();
    _newPassController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final v = _newPassController.text;
    setState(() {
      _reqLen = v.length >= 8;
      _reqUpper = v.contains(RegExp(r'[A-Z]'));
      _reqLower = v.contains(RegExp(r'[a-z]'));
      _reqNum = v.contains(RegExp(r'[0-9]'));
      _reqSpecial = v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _savePassword() {
    if (!_editPassword) {
      setState(() => _editPassword = true);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 72),
              const SizedBox(height: 20),
              Text(
                'Password Updated',
                style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: DC.primaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Your password has been changed successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: DC.textMid),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DC.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('OK', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                )
              )
            ],
          )
        )
      )
    );
    setState(() => _editPassword = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF43F5E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Change your password',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: DC.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: DC.textMid,
            ),
            const SizedBox(width: 6),
            Text(
              'Last Update:   21 December 2024',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        _DetailsCard(
          title: '', // Layout handled manually
          actionLabel: 'Edit Password',
          isEditing: _editPassword,
          onActionTap: _savePassword,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _Field(
                      'Current Password',
                      'password123',
                      isPassword: true,
                      isEditing: _editPassword,
                      controller: _oldPassController,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      'New Password',
                      '',
                      isPassword: true,
                      isEditing: _editPassword,
                      controller: _newPassController,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      'Confirm New Password',
                      '',
                      isPassword: true,
                      isEditing: _editPassword,
                      controller: _confirmPassController,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DC.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ReqBullet('At least 8 characters', _reqLen),
                      const SizedBox(height: 6),
                      _ReqBullet('At least one uppercase letter', _reqUpper),
                      const SizedBox(height: 6),
                      _ReqBullet('At least one lowercase letter', _reqLower),
                      const SizedBox(height: 6),
                      _ReqBullet('At least one number', _reqNum),
                      const SizedBox(height: 6),
                      _ReqBullet('At least one special characters', _reqSpecial),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReqBullet extends StatelessWidget {
  final String text;
  final bool checked;
  const _ReqBullet(this.text, this.checked);

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(left: checked ? 12 : 0),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              checked ? Icons.check_circle_outline : Icons.close_rounded,
              key: ValueKey(checked),
              size: 14,
              color: checked ? const Color(0xFF15803D) : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: checked ? const Color(0xFF15803D) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

// ── APPEARANCE TAB ──
class _AppearanceContent extends StatelessWidget {
  const _AppearanceContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF43F5E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.palette_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Change the appearance',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: DC.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: DC.textMid,
            ),
            const SizedBox(width: 6),
            Text(
              'Last Update:   21 December 2024',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: DC.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color Theme',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: DC.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize the look and feel of your application.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: DC.textSoft,
                ),
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<String>(
                valueListenable: globalTheme,
                builder: (context, theme, _) {
                  return Row(
                    children: [
                      _ThemeOption(
                        title: 'Default',
                        desc: 'red, blue, white',
                        colors: const [
                          Color(0xFFE57373),
                          Colors.white,
                          Color(0xFF64B5F6),
                        ],
                        selected: theme == 'default',
                        onTap: () => globalTheme.value = 'default',
                      ),
                      const SizedBox(width: 16),
                      _ThemeOption(
                        title: 'Sunset',
                        desc: 'red, orange, yellow',
                        colors: const [
                          Color(0xFFE57373),
                          Color(0xFFFFB74D),
                          Color(0xFFFFF176),
                        ],
                        selected: theme == 'sunset',
                        onTap: () => globalTheme.value = 'sunset',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title, desc;
  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.desc,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF10B981) : DC.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DC.primaryDark,
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: selected ? const Color(0xFF10B981) : DC.border,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: DC.textSoft,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: colors
                  .map(
                    (c) => Container(
                      width: 36,
                      height: 24,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── REUSABLE SETTINGS WIDGETS ──
class _DetailsCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final bool isEditing;

  const _DetailsCard({
    required this.title,
    required this.child,
    this.actionLabel = '',
    this.onActionTap,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DC.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: DC.primaryDark,
                  ),
                )
              else 
                const SizedBox(),
                
              if (actionLabel.isNotEmpty && onActionTap != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isEditing ? const Color(0xFF10B981) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : actionLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isEditing ? Colors.white : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (title.isNotEmpty) const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatefulWidget {
  final String label, value;
  final bool isPassword;
  final bool isEditing;
  final TextEditingController? controller;

  const _Field(this.label, this.value, {
    this.isPassword = false, 
    this.isEditing = false,
    this.controller,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_Field oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.value != widget.value) {
      _internalController.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DC.primaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isEditing ? Colors.white : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DC.border.withOpacity(widget.isEditing ? 1.0 : 0.5)),
          ),
          child: TextField(
            controller: _internalController,
            obscureText: widget.isPassword,
            readOnly: !widget.isEditing,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: widget.isEditing ? DC.primaryDark : DC.textMid,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── TOP PROFILE MENU ──
class TopProfileMenu extends StatelessWidget {
  const TopProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val == 'profile') {
          globalNavIndex.value = 6;
        } else if (val == 'logout') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminLoginPage()),
          );
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stella Santuyo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: DC.primaryDark,
                ),
              ),
              Text(
                'stellaAdmin@gmail.com',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: DC.textSoft,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: DC.primaryDark),
              const SizedBox(width: 8),
              Text(
                'My Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: DC.primaryDark,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 18, color: DC.primaryDark),
              const SizedBox(width: 8),
              Text(
                'Sign out',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: DC.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
      child: ValueListenableBuilder<String?>(
        valueListenable: globalProfileImage,
        builder: (context, imgPath, _) {
          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF1656A),
                backgroundImage: imgPath != null ? AssetImage(imgPath) : null,
                child: imgPath == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stella Santuyo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DC.primaryDark,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 11,
                        color: DC.textSoft,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Superadmin',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: DC.textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
