import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'admin-report_management.dart';
import 'admin-user_management.dart';
import 'admin-content_management.dart';
import 'admin-logs_monitoring.dart';
import 'admin_management.dart';
import 'admin-settings.dart';

final ValueNotifier<int> globalNavIndex = ValueNotifier(0);
final ValueNotifier<String> globalTheme = ValueNotifier('default');
final ValueNotifier<String?> globalProfileImage = ValueNotifier(null);

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminDashboardHomepage(),
    ),
  );
}

// ── Design tokens ──────────────────────────────────────────────────────────────
class DC {
  static const primary = Color(0xFF1D3A8A);
  static const primaryDark = Color(0xFF0D1B3E);
  static const textMid = Color(0xFF3D4F6E);
  static const textSoft = Color(0xFF7A8BAA);
  static const border = Color(0xFFE3E8F7);
  static const bgPage = Color(0xFFF4F5FB);
}

// ══════════════════════════════════════════════════════════════════════════════
class AdminDashboardHomepage extends StatefulWidget {
  const AdminDashboardHomepage({super.key});
  @override
  State<AdminDashboardHomepage> createState() => _AdminDashboardHomepageState();
}

class _AdminDashboardHomepageState extends State<AdminDashboardHomepage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalTheme,
      builder: (context, themeStr, _) {
        return ValueListenableBuilder<int>(
          valueListenable: globalNavIndex,
          builder: (context, navIndex, _) {
            Decoration bgDeco;
            if (themeStr == 'sunset') {
              bgDeco = const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF1F1),
                    Color(0xFFFFF7ED),
                    Color(0xFFFEFEF2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              );
            } else if (themeStr == 'default') {
              bgDeco = const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg/bg-admin-login-gradient.png'),
                  fit: BoxFit.cover,
                ),
              );
            } else {
              // Custom theme colors from image colors if any
              bgDeco = const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              );
            }

            return Scaffold(
              backgroundColor: DC.bgPage,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Sidebar ──
                  _Sidebar(
                    selectedIndex: navIndex,
                    onSelect: (i) => globalNavIndex.value = i,
                  ),
                  // ── Main content with gradient bg ──
                  Expanded(
                    child: Container(
                      decoration: bgDeco,
                      child: navIndex == 1
                          ? const ReportManagementBody()
                          : navIndex == 2
                          ? const UserManagementBody()
                          : navIndex == 3
                          ? const ContentManagementBody()
                          : navIndex == 4
                          ? const LogsMonitoringBody()
                          : navIndex == 5
                          ? const AdminManagementBody()
                          : navIndex == 6
                          ? const SettingsBody()
                          : const _DashboardBody(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SIDEBAR  — fixed: logo flush top-left, section headers correct indent,
//            icons use Image.asset with errorBuilder fallback, selected item
//            has correct blue tint, items vertically compact like reference.
// ══════════════════════════════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _Sidebar({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo — matches reference: top of sidebar, generous padding ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Image.asset(
              'assets/images/main-logo.png',
              height: 48,
              errorBuilder: (_, __, ___) => Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DC.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'DSWD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: DC.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Nav items ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SidebarSection('GENERAL'),
                  _SidebarItem(
                    index: 0,
                    selected: selectedIndex,
                    iconPath: 'assets/side-tab-icon/dashboard icon.png',
                    fallback: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    onTap: onSelect,
                  ),
                  _SidebarItem(
                    index: 1,
                    selected: selectedIndex,
                    iconPath: 'assets/side-tab-icon/report icon.png',
                    fallback: Icons.note_alt_outlined,
                    label: 'Report Management',
                    onTap: onSelect,
                  ),

                  const SizedBox(height: 18),
                  _SidebarSection('USERS'),
                  _SidebarItem(
                    index: 2,
                    selected: selectedIndex,
                    iconPath: 'assets/side-tab-icon/Frame.png',
                    fallback: Icons.people_outline_rounded,
                    label: 'User Management',
                    onTap: onSelect,
                  ),

                  const SizedBox(height: 18),
                  _SidebarSection('SYSTEM'),
                  _SidebarItem(
                    index: 3,
                    selected: selectedIndex,
                    iconPath: 'assets/side-tab-icon/content icon.png',
                    fallback: Icons.web_outlined,
                    label: 'Content Management',
                    onTap: onSelect,
                  ),
                  _SidebarItem(
                    index: 4,
                    selected: selectedIndex,
                    iconPath: 'assets/side-tab-icon/logs button.png',
                    fallback: Icons.monitor_heart_outlined,
                    label: 'Logs & Monitoring',
                    onTap: onSelect,
                  ),

                  const SizedBox(height: 18),
                  _SidebarSection('ADMIN'),
                  _SidebarItem(
                    index: 5,
                    selected: selectedIndex,
                    iconPath: 'assets/side-tab-icon/admin icon.png',
                    fallback: Icons.manage_accounts_outlined,
                    label: 'Admin Management',
                    onTap: onSelect,
                  ),
                  _SidebarItem(
                    index: 6,
                    selected: selectedIndex,
                    iconPath: 'assets/side-tab-icon/settings button.png',
                    fallback: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: onSelect,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section header — plain, small, all-caps, muted
class _SidebarSection extends StatelessWidget {
  final String title;
  const _SidebarSection(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: DC.textSoft,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// Nav item — image icon with fallback, selected tint, hover tint
class _SidebarItem extends StatefulWidget {
  final int index, selected;
  final String iconPath, label;
  final IconData fallback;
  final ValueChanged<int> onTap;

  const _SidebarItem({
    required this.index,
    required this.selected,
    required this.iconPath,
    required this.fallback,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.index == widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFE8EEFF)
                : _hover
                ? const Color(0xFFF5F7FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            // Left accent bar on active item (like reference)
            border: isActive
                ? Border(left: BorderSide(color: DC.primary, width: 3))
                : const Border(),
          ),
          child: Row(
            children: [
              // Icon — image with fallback
              SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  widget.iconPath,
                  color: isActive ? DC.primary : DC.textMid,
                  errorBuilder: (_, __, ___) => Icon(
                    widget.fallback,
                    size: 20,
                    color: isActive ? DC.primary : DC.textMid,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? DC.primaryDark : DC.textMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD BODY
// ══════════════════════════════════════════════════════════════════════════════
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final int totalReports = globalMasterReports.length;
    final int pendingReports = globalMasterReports
        .where((r) => r.status == 'Pending')
        .length;
    final int verifiedReports = globalMasterReports
        .where((r) => r.status == 'Validated')
        .length;
    final int totalUsers = globalMasterUsers.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: DC.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Welcome back, Admin Stella! Here's what's happening today.",
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
          const SizedBox(height: 20),

          // ── Insight Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFFF).withOpacity(0.88),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Decision Support Insight',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D3A8A),
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF2F55C8),
                      height: 1.55,
                    ),
                    children: const [
                      TextSpan(
                        text: 'High concentration of cases detected in ',
                      ),
                      TextSpan(
                        text: 'Bacoor, Cavite.',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text:
                            ' Consider deploying additional field staff to this area.'
                            ' Average response time can be improved by 23%.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Stat Cards ──
          Row(
            children: [
              Expanded(
                child: _AnimatedStatCard(
                  title: 'Total Users',
                  value: totalUsers.toString(),
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/user-icon.png',
                  fallback: Icons.people_outline_rounded,
                  iconBg: const Color(0xFFE6EDFF),
                  iconColor: const Color(0xFF3B5998),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AnimatedStatCard(
                  title: 'Total Reports',
                  value: totalReports.toString(),
                  growth: '+10% this month',
                  iconAsset: 'assets/icon/report/file-icon.png',
                  fallback: Icons.description_outlined,
                  iconBg: const Color(0xFFE6EDFF),
                  iconColor: const Color(0xFF3B5998),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AnimatedStatCard(
                  title: 'Pending Reports',
                  value: pendingReports.toString(),
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/pending-report-icon.png',
                  fallback: Icons.pending_actions_outlined,
                  iconBg: const Color(0xFFFFECEC),
                  iconColor: const Color(0xFFBF4040),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _AnimatedStatCard(
                  title: 'Verified Reports',
                  value: verifiedReports.toString(),
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/verified-report-icon.png',
                  fallback: Icons.domain_verification_outlined,
                  iconBg: const Color(0xFFE6F7EE),
                  iconColor: const Color(0xFF1A7A48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Row 1: Density Map  +  Report Trends ──
          SizedBox(
            height: 420,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 7, child: _DensityMapCard()),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: _ReportTrendsCard()),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Row 2: Bar Graph  +  Recent Activities ──
          SizedBox(
            height: 420,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 7, child: _BarGraphCard()),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: _RecentActivitiesCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ANIMATED STAT CARD (copied from _StatCard in admin-report_management.dart)
// ══════════════════════════════════════════════════════════════════════════════
class _AnimatedStatCard extends StatefulWidget {
  final String title, value, growth, iconAsset;
  final IconData fallback;
  final Color iconBg, iconColor;

  const _AnimatedStatCard({
    required this.title,
    required this.value,
    required this.growth,
    required this.iconAsset,
    required this.fallback,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _hover = false;
  late int _targetValue;

  @override
  void initState() {
    super.initState();
    _targetValue = int.tryParse(widget.value.replaceAll(',', '')) ?? 0;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    if (_targetValue == 0)
      return widget.value; // Fallback to raw string if not a number
    final n = v.round();
    if (n >= 1000) {
      final s = n.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hover ? DC.primary.withOpacity(0.20) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hover
                  ? DC.primary.withOpacity(0.10)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _hover ? 28 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DC.textMid,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    widget.iconAsset,
                    color: widget.iconColor,
                    errorBuilder: (_, __, ___) => Icon(
                      widget.fallback,
                      size: 17,
                      color: widget.iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Text(
                _fmt(_anim.value * _targetValue),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DC.primaryDark,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward_rounded,
                  size: 11,
                  color: Color(0xFF15803D),
                ),
                const SizedBox(width: 3),
                Text(
                  widget.growth,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DENSITY MAP CARD
// ══════════════════════════════════════════════════════════════════════════════
class _DensityMapCard extends StatefulWidget {
  @override
  State<_DensityMapCard> createState() => _DensityMapCardState();
}

class _DensityMapCardState extends State<_DensityMapCard> {
  final MapController _mapCtrl = MapController();

  void _zoomIn() {
    final z = _mapCtrl.camera.zoom;
    _mapCtrl.move(_mapCtrl.camera.center, z + 1);
  }

  void _zoomOut() {
    final z = _mapCtrl.camera.zoom;
    _mapCtrl.move(_mapCtrl.camera.center, z - 1);
  }

  void _resetZoom() {
    _mapCtrl.move(const LatLng(14.5995, 120.9842), 13.0);
  }

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Dot Density Map',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DC.primaryDark,
                ),
              ),
              Row(
                children: [
                  _DropdownChip(
                    icon: Icons.calendar_today_outlined,
                    label: 'Oct 18 - Nov 18',
                    items: [
                      'Oct 18 - Nov 18',
                      'Sep 18 - Oct 18',
                      'Aug 18 - Sep 18',
                    ],
                  ),
                  const SizedBox(width: 8),
                  _DropdownChip(
                    label: 'Monthly',
                    items: ['Monthly', 'Weekly', 'Daily', 'Yearly'],
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Map — Expanded so it fills the remaining card height
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: _mapCtrl,
                      options: const MapOptions(
                        initialCenter: LatLng(
                          14.5995,
                          120.9842,
                        ), // Manila, Philippines roughly
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.example.oplan_pagabot_website',
                        ),
                      ],
                    ),
                  ),
                  // Zoom controls
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Column(
                      children: [
                        _MapBtn(Icons.my_location_rounded, onTap: _resetZoom),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _MapBtnInline(Icons.add, onTap: _zoomIn),
                              Container(
                                height: 1,
                                width: 32,
                                color: Colors.grey[200],
                              ),
                              _MapBtnInline(Icons.remove, onTap: _zoomOut),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: _MapBtn(Icons.fullscreen_rounded, onTap: () {}),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REPORT TRENDS CARD
// FIX: Uses Expanded for the chart area so it fills the card height,
//      matching the Density Map card height via IntrinsicHeight in parent.
// ══════════════════════════════════════════════════════════════════════════════
class _ReportTrendsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Trends',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DC.primaryDark,
                ),
              ),
              Row(
                children: [
                  _DropdownChip(
                    icon: Icons.calendar_today_outlined,
                    label: 'Oct 18 - Nov 18',
                    items: ['Oct 18 - Nov 18', 'Sep 18 - Oct 18'],
                  ),
                  const SizedBox(width: 8),
                  _DropdownChip(
                    label: 'Monthly',
                    items: ['Monthly', 'Weekly', 'Daily'],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Expanded fills the remaining height — matches map card
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BAR GRAPH CARD
// ══════════════════════════════════════════════════════════════════════════════
class _BarGraphCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Bar Graph',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DC.primaryDark,
                ),
              ),
              Row(
                children: [
                  _DropdownChip(
                    icon: Icons.calendar_today_outlined,
                    label: 'Oct 18 - Nov 18',
                    items: ['Oct 18 - Nov 18', 'Sep 18 - Oct 18'],
                  ),
                  const SizedBox(width: 8),
                  _DropdownChip(
                    label: 'Monthly',
                    items: ['Monthly', 'Weekly', 'Daily'],
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: CustomPaint(
              painter: _BarChartPainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECENT ACTIVITIES CARD
// ══════════════════════════════════════════════════════════════════════════════
class _RecentActivitiesCard extends StatefulWidget {
  @override
  State<_RecentActivitiesCard> createState() => _RecentActivitiesCardState();
}

class _RecentActivitiesCardState extends State<_RecentActivitiesCard> {
  bool _toast = false;

  void _viewAll() {
    globalNavIndex.value =
        4; // Assuming 4 is LogsMonitoringBody based on main navigation
  }

  @override
  Widget build(BuildContext context) {
    // Only display up to the 4 most recent logs
    final recentLogs = globalLogs.take(4).toList();

    return Stack(
      children: [
        _CardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recent Activities',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: DC.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A7A48),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  _ActionChip(label: 'View All', onTap: _viewAll),
                ],
              ),
              const SizedBox(height: 14),
              if (recentLogs.isEmpty)
                Text(
                  'No recent activities.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: DC.textSoft,
                  ),
                ),
              ...List.generate(recentLogs.length, (i) {
                final a = recentLogs[i];
                return Column(
                  children: [
                    _ActivityRow(
                      name: a.performedBy,
                      desc: a.details,
                      time: a.timestamp,
                      badge: a.role,
                      hasDot:
                          a.action.toLowerCase().contains('update') ||
                          a.action.toLowerCase().contains('alert'),
                    ),
                    if (i < recentLogs.length - 1)
                      const Divider(height: 22, color: Color(0xFFF0F2F8)),
                  ],
                );
              }),
            ],
          ),
        ),
        if (_toast)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: DC.primaryDark.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Full activity log coming soon',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String name, desc, time, badge;
  final bool hasDot;
  const _ActivityRow({
    required this.name,
    required this.desc,
    required this.time,
    required this.badge,
    required this.hasDot,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFF0D1B3E),
          child: const Icon(Icons.person, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: DC.primaryDark,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  if (hasDot)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6, top: 1),
                      decoration: const BoxDecoration(
                        color: Color(0xFFBF4040),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      desc,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: DC.textMid,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: DC.textSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: DC.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                badge == 'Superadmin'
                    ? Icons.security_rounded
                    : Icons.person_outline_rounded,
                size: 12,
                color: DC.textMid,
              ),
              const SizedBox(width: 5),
              Text(
                badge,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: DC.textMid,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED CONTROLS
// ══════════════════════════════════════════════════════════════════════════════

class _DropdownChip extends StatefulWidget {
  final String label;
  final List<String> items;
  final IconData? icon;
  const _DropdownChip({required this.label, required this.items, this.icon});

  @override
  State<_DropdownChip> createState() => _DropdownChipState();
}

class _DropdownChipState extends State<_DropdownChip> {
  late String _sel;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _sel = widget.label;
  }

  void _open(BuildContext ctx) async {
    final box = ctx.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final result = await showMenu<String>(
      context: ctx,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height + 4,
        offset.dx + box.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      items: widget.items
          .map(
            (item) => PopupMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: item == _sel ? FontWeight.w700 : FontWeight.w500,
                  color: item == _sel ? DC.primary : DC.textMid,
                ),
              ),
            ),
          )
          .toList(),
    );
    if (result != null) setState(() => _sel = result);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => _open(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFF0F3FF) : Colors.white,
            border: Border.all(
              color: _hover ? DC.primary.withOpacity(0.4) : DC.border,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 13, color: DC.textSoft),
                const SizedBox(width: 6),
              ],
              Text(
                _sel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: DC.textMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: DC.textSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Advanced filter panel coming soon',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: DC.primaryDark,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFF0F3FF) : Colors.white,
            border: Border.all(
              color: _hover ? DC.primary.withOpacity(0.4) : DC.border,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 13,
                color: _hover ? DC.primary : DC.textSoft,
              ),
              const SizedBox(width: 6),
              Text(
                'Filter',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _hover ? DC.primary : DC.textMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.onTap});
  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFF0F3FF) : Colors.white,
            border: Border.all(
              color: _hover ? DC.primary.withOpacity(0.4) : DC.border,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: _hover ? DC.primary : DC.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatefulWidget {
  final IconData icon;
  const _IconCircleButton({required this.icon});
  @override
  State<_IconCircleButton> createState() => _IconCircleButtonState();
}

class _IconCircleButtonState extends State<_IconCircleButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFF0F3FF) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: _hover ? DC.primary.withOpacity(0.3) : DC.border,
              width: 1.5,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: _hover ? DC.primary : DC.primaryDark,
          ),
        ),
      ),
    );
  }
}

// ── Map buttons ────────────────────────────────────────────────────────────────
class _MapBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _MapBtn(this.icon, {this.onTap});
  @override
  State<_MapBtn> createState() => _MapBtnState();
}

class _MapBtnState extends State<_MapBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFF0F3FF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: _hover ? DC.primary : DC.textMid,
          ),
        ),
      ),
    );
  }
}

class _MapBtnInline extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _MapBtnInline(this.icon, {this.onTap});
  @override
  State<_MapBtnInline> createState() => _MapBtnInlineState();
}

class _MapBtnInlineState extends State<_MapBtnInline> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 34,
          height: 34,
          color: _hover ? const Color(0xFFF0F3FF) : Colors.white,
          child: Icon(
            widget.icon,
            size: 18,
            color: _hover ? DC.primary : DC.textMid,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARD WRAPPER
// ══════════════════════════════════════════════════════════════════════════════
class _CardWrapper extends StatelessWidget {
  final Widget child;
  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CHART PAINTERS
// ══════════════════════════════════════════════════════════════════════════════
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF4A8BFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final dashPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final dotFill = Paint()..color = Colors.white;
    final dotStroke = Paint()
      ..color = const Color(0xFF4A8BFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    const xStart = 40.0;
    final bottom = size.height - 30;

    final ts = GoogleFonts.plusJakartaSans(
      color: const Color(0xFF7A8BAA),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y grid mapping for Line Chart
    final mapLine = <String, int>{};
    for (var r in globalMasterReports) {
      // Dummy date clustering logic for trends
      mapLine[r.dateSubmitted.split(',')[0]] =
          (mapLine[r.dateSubmitted.split(',')[0]] ?? 0) + 1;
    }
    var sortedLine = mapLine.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (sortedLine.isEmpty) sortedLine = [const MapEntry('None', 0)];
    final xLabels = sortedLine.map((e) => e.key).toList();
    final rawLineData = sortedLine.map((e) => e.value.toDouble()).toList();
    final maxLine = rawLineData.isEmpty
        ? 2.0
        : (rawLineData.reduce((a, b) => a > b ? a : b) + 1);

    final yLabels = [
      0,
      1,
      2,
      3,
      4,
    ].map((i) => ((maxLine / 4) * i).toStringAsFixed(1)).toList();
    for (int i = 0; i < yLabels.length; i++) {
      final y = bottom - (i * (bottom / (yLabels.length - 1)));
      if (i > 0) {
        double dx = xStart;
        while (dx < size.width) {
          canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
          dx += 10;
        }
      } else {
        canvas.drawLine(Offset(xStart, y), Offset(size.width, y), dashPaint);
      }
      tp.text = TextSpan(text: yLabels[i], style: ts);
      tp.layout();
      tp.paint(canvas, Offset(xStart - 28, y - 6));
    }

    // X grid + labels
    final stepX = (size.width - xStart) / (xLabels.length - 1);
    for (int i = 0; i < xLabels.length; i++) {
      final x = xStart + i * stepX;
      double dy = 0;
      while (dy < bottom) {
        canvas.drawLine(Offset(x, dy), Offset(x, dy + 5), dashPaint);
        dy += 10;
      }
      tp.text = TextSpan(text: xLabels[i], style: ts);
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, bottom + 12));
    }

    // Data points + smooth curve
    final points = List.generate(
      rawLineData.length,
      (i) => Offset(
        xStart + i * stepX,
        bottom - ((rawLineData[i] / maxLine) * bottom),
      ),
    );

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cx = (points[i].dx + points[i + 1].dx) / 2;
      path.cubicTo(
        cx,
        points[i].dy,
        cx,
        points[i + 1].dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }

    // Gradient fill under curve
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A8BFF).withOpacity(0.15),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromLTRB(xStart, 0, size.width, bottom));
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, bottom)
      ..lineTo(points.first.dx, bottom)
      ..close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, linePaint);
    for (final p in points) {
      canvas.drawCircle(p, 4, dotFill);
      canvas.drawCircle(p, 4, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = const Color(0xFF4A8BFF);
    final dashPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final bottom = size.height - 30;
    const xStart = 40.0;

    final ts = GoogleFonts.plusJakartaSans(
      color: const Color(0xFF7A8BAA),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Y grid and data for Bar Chart
    final mapBar = <String, int>{};
    for (var r in globalMasterReports) {
      mapBar[r.city] = (mapBar[r.city] ?? 0) + 1;
    }
    var sortedBar = mapBar.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sortedBar.isEmpty) sortedBar = [const MapEntry('None', 0)];
    final xLabels = sortedBar.take(3).map((e) => e.key).toList();
    final data = sortedBar.take(3).map((e) => e.value.toDouble()).toList();
    final maxBar = data.isEmpty
        ? 2.0
        : (data.reduce((a, b) => a > b ? a : b) + 1);

    final yLabels = [
      0,
      1,
      2,
      3,
      4,
    ].map((i) => ((maxBar / 4) * i).toStringAsFixed(1)).toList();
    for (int i = 0; i < yLabels.length; i++) {
      final y = bottom - (i * (bottom / (yLabels.length - 1)));
      if (i > 0) {
        double dx = xStart;
        while (dx < size.width) {
          canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
          dx += 10;
        }
      }
      tp.text = TextSpan(text: yLabels[i], style: ts);
      tp.layout();
      tp.paint(canvas, Offset(xStart - 28, y - 6));
    }

    canvas.drawLine(
      Offset(xStart, bottom),
      Offset(size.width, bottom),
      dashPaint,
    );

    // Bars
    final stepX = (size.width - xStart) / xLabels.length;
    const barW = 100.0;

    for (int i = 0; i < xLabels.length; i++) {
      final cx = xStart + i * stepX + stepX / 2;
      final bh = (data[i] / maxBar) * bottom;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(cx - barW / 2, bottom - bh, cx + barW / 2, bottom),
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(5),
        ),
        barPaint,
      );
      tp.text = TextSpan(text: xLabels[i], style: ts);
      tp.layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, bottom + 12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
