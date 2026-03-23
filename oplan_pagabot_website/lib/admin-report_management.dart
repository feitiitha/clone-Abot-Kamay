import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
class DC {
  static const primary = Color(0xFF1D3A8A);
  static const primaryDark = Color(0xFF0D1B3E);
  static const textMid = Color(0xFF3D4F6E);
  static const textSoft = Color(0xFF7A8BAA);
  static const border = Color(0xFFE3E8F7);
  static const bgPage = Color(0xFFF4F5FB);
}

const _vulnColors = {
  'High': [Color(0xFFFF6B00), Color(0xFFFFFFFF)],
  'Medium': [Color(0xFFF59E0B), Color(0xFFFFFFFF)],
  'Low': [Color(0xFF22C55E), Color(0xFFFFFFFF)],
};
const _statusColors = {
  'Validated': [Color(0xFFDCFCE7), Color(0xFF15803D)],
  'Pending': [Color(0xFFDBEAFE), Color(0xFF2563EB)],
  'Rejected': [Color(0xFFF3F4F6), Color(0xFF6B7280)],
  'Completed': [Color(0xFFDCFCE7), Color(0xFF15803D)],
};
const double _badgeH = 28;
const double _badgeMinW = 90;

class ReportRecord {
  final String id, city, province, titleShort, titleFull;
  String vulnerability, status, adminNotes;
  final String timestamp, description, location, reportedBy, dateSubmitted;
  final int numIndividuals;

  ReportRecord({
    required this.id,
    required this.city,
    required this.province,
    required this.titleShort,
    required this.titleFull,
    required this.vulnerability,
    required this.status,
    required this.timestamp,
    required this.description,
    required this.location,
    required this.reportedBy,
    required this.dateSubmitted,
    required this.numIndividuals,
    this.adminNotes = 'None',
  });
}

final List<ReportRecord> _masterReports = [
  ReportRecord(
    id: 'RPT-001',
    city: 'Bacoor',
    province: 'Cavite',
    titleShort: 'Homeless Fam...',
    titleFull: 'Homeless Family',
    vulnerability: 'High',
    status: 'Validated',
    timestamp: '02/10/26, 10:21:24 PM',
    description:
        'Family of 4 living under the bridge near SM Bacoor. Includes 2 children (ages 5 and 7).',
    location:
        'Aguinaldo Highway, near SM Bacoor Brgy. Habay II, Bacoor, Cavite',
    reportedBy: 'Faith Cabanit',
    dateSubmitted: '02/10/26, 10:21:24 PM',
    numIndividuals: 4,
  ),
  ReportRecord(
    id: 'RPT-002',
    city: 'Calamba',
    province: 'Laguna',
    titleShort: 'Elderly...',
    titleFull: 'Elderly Street Dweller',
    vulnerability: 'Medium',
    status: 'Pending',
    timestamp: '02/10/26, 10:27:30 PM',
    description:
        'Elderly man living near the market, appears malnourished and without shelter.',
    location: 'Public Market, Calamba City, Laguna',
    reportedBy: 'Juan dela Cruz',
    dateSubmitted: '02/10/26, 10:27:30 PM',
    numIndividuals: 1,
  ),
  ReportRecord(
    id: 'RPT-003',
    city: 'Antipolo',
    province: 'Rizal',
    titleShort: 'Individual...',
    titleFull: 'Individual in Distress',
    vulnerability: 'Low',
    status: 'Rejected',
    timestamp: '02/11/26, 08:20:15 PM',
    description:
        'Individual spotted begging near the cathedral. Appears to be in good health.',
    location: 'Antipolo Cathedral, Antipolo City, Rizal',
    reportedBy: 'Maria Santos',
    dateSubmitted: '02/11/26, 08:20:15 PM',
    numIndividuals: 1,
  ),
  ReportRecord(
    id: 'RPT-004',
    city: 'Navotas',
    province: 'Cavite',
    titleShort: 'Street Children',
    titleFull: 'Street Children Group',
    vulnerability: 'Low',
    status: 'Completed',
    timestamp: '02/11/26, 08:20:15 PM',
    description:
        'Group of 6 children living near the fish port. Ages range from 8 to 14.',
    location: 'Navotas Fish Port, Navotas City',
    reportedBy: 'Pedro Reyes',
    dateSubmitted: '02/11/26, 08:20:15 PM',
    numIndividuals: 6,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
class ReportManagementBody extends StatefulWidget {
  const ReportManagementBody({super.key});
  @override
  State<ReportManagementBody> createState() => _ReportManagementBodyState();
}

class _ReportManagementBodyState extends State<ReportManagementBody> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterStatus;
  String? _filterVuln;
  String _sortField = 'id';
  bool _sortAsc = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ReportRecord> get _displayed {
    var list = _masterReports.where((r) {
      final q = _searchQuery.toLowerCase();
      final ms =
          q.isEmpty ||
          r.id.toLowerCase().contains(q) ||
          r.city.toLowerCase().contains(q) ||
          r.titleFull.toLowerCase().contains(q) ||
          r.reportedBy.toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q) ||
          r.vulnerability.toLowerCase().contains(q);
      return ms &&
          (_filterStatus == null || r.status == _filterStatus) &&
          (_filterVuln == null || r.vulnerability == _filterVuln);
    }).toList();
    list.sort((a, b) {
      final cmp = _sortField == 'timestamp'
          ? a.timestamp.compareTo(b.timestamp)
          : a.id.compareTo(b.id);
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  void _openView(ReportRecord r) => showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (_) => _ReportDetailsDialog(report: r),
  );

  void _openUpdate(ReportRecord r) => showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (_) => _UpdateReportDialog(
      report: r,
      onProceedToVerify: (s, v, n) {
        Navigator.pop(context);
        _openVerify(r, s, v, n);
      },
    ),
  );

  void _openVerify(ReportRecord r, String s, String v, String n) => showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (_) => _VerifyIdentityDialog(
      onConfirm: () {
        setState(() {
          r.status = s;
          r.vulnerability = v;
          r.adminNotes = n.isEmpty ? 'None' : n;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${r.id} updated to "$s"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    ),
  );

  void _openFilter() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FilterSheet(
      currentStatus: _filterStatus,
      currentVuln: _filterVuln,
      onApply: (s, v) {
        setState(() {
          _filterStatus = s;
          _filterVuln = v;
        });
        Navigator.pop(context);
      },
      onClear: () {
        setState(() {
          _filterStatus = null;
          _filterVuln = null;
        });
        Navigator.pop(context);
      },
    ),
  );

  void _openSort() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SortSheet(
      currentField: _sortField,
      ascending: _sortAsc,
      onApply: (f, a) {
        setState(() {
          _sortField = f;
          _sortAsc = a;
        });
        Navigator.pop(context);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final rows = _displayed;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Records',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: DC.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review and manage street situation reports.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: DC.textMid,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _CircleIconBtn(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 14),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF1656A),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
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
                            Icons.radio_button_unchecked,
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
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  value: '1,003',
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/user-icon.png',
                  fallback: Icons.people_outline_rounded,
                  iconBg: const Color(0xFFE6EDFF),
                  iconColor: const Color(0xFF3B5998),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Total Reports',
                  value: '701',
                  growth: '+10% this month',
                  iconAsset: 'assets/icon/report/file-icon.png',
                  fallback: Icons.description_outlined,
                  iconBg: const Color(0xFFE6EDFF),
                  iconColor: const Color(0xFF3B5998),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Pending Reports',
                  value: '100',
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/pending-report-icon.png',
                  fallback: Icons.pending_actions_outlined,
                  iconBg: const Color(0xFFFFECEC),
                  iconColor: const Color(0xFFBF4040),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Verified Reports',
                  value: '1,003',
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/verified-report-icon.png',
                  fallback: Icons.domain_verification_outlined,
                  iconBg: const Color(0xFFE6F7EE),
                  iconColor: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20, color: DC.textSoft),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: DC.primaryDark,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search by ID, location, reporter, status…',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: DC.textSoft,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: DC.textSoft,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (_filterStatus != null || _filterVuln != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: DC.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      [
                        ?_filterStatus,
                        ?_filterVuln,
                      ].join(' · '),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: DC.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                _BarChipBtn(
                  icon: Icons.filter_list_rounded,
                  label: 'Filter',
                  active: _filterStatus != null || _filterVuln != null,
                  onTap: _openFilter,
                ),
                const SizedBox(width: 10),
                _BarChipBtn(
                  icon: Icons.swap_vert_rounded,
                  label: 'Sort',
                  active: _sortField != 'id' || !_sortAsc,
                  onTap: _openSort,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _TH('Report ID', flex: 18),
                      _TH('Location', flex: 18),
                      _TH('Title', flex: 22),
                      _TH('Vulnerability', flex: 18),
                      _TH('Status', flex: 18),
                      _TH('Timestamp', flex: 22),
                      _TH('Actions', flex: 12, right: true),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEF0F8)),
                rows.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'No records match your search.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: DC.textSoft,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: rows
                            .asMap()
                            .entries
                            .map(
                              (e) => _TableRow(
                                report: e.value,
                                shade: e.key.isOdd,
                                onView: () => _openView(e.value),
                                onEdit: () => _openUpdate(e.value),
                              ),
                            )
                            .toList(),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Showing ${rows.length} of ${_masterReports.length} records',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: DC.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DIALOG 1: REPORT DETAILS
// ══════════════════════════════════════════════════════════════════════════════
class _ReportDetailsDialog extends StatelessWidget {
  final ReportRecord report;
  const _ReportDetailsDialog({required this.report});

  @override
  Widget build(BuildContext context) {
    final r = report;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 320, vertical: 32),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report Details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DC.primaryDark,
                  ),
                ),
                _XBtn(onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report ID', style: _labelStyle()),
                    const SizedBox(height: 4),
                    Text(r.id, style: _valueStyle()),
                  ],
                ),
                const SizedBox(width: 48),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: _labelStyle()),
                    const SizedBox(height: 6),
                    _StatusBadge(status: r.status),
                  ],
                ),
                const SizedBox(width: 48),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vulnerability Type', style: _labelStyle()),
                    const SizedBox(height: 6),
                    _VulnBadge(level: r.vulnerability),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Title', style: _labelStyle()),
                      const SizedBox(height: 4),
                      Text(r.titleFull, style: _valueStyle()),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Number of Individuals', style: _labelStyle()),
                    const SizedBox(height: 4),
                    Text(r.numIndividuals.toString(), style: _valueStyle()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Description', style: _sectionLabel()),
            const SizedBox(height: 6),
            Text(
              r.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: DC.textMid,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 22),
            Text('Location', style: _sectionLabel()),
            const SizedBox(height: 6),
            Text(
              r.location,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: DC.textMid,
              ),
            ),
            const SizedBox(height: 22),
            Text('Uploaded Media', style: _sectionLabel()),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DC.border, width: 1.2),
              ),
              child: Row(
                children: [
                  _MediaThumb(),
                  const SizedBox(width: 14),
                  _MediaThumb(),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reported by', style: _sectionLabel()),
                      const SizedBox(height: 4),
                      Text(
                        r.reportedBy,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: DC.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date Submitted', style: _sectionLabel()),
                      const SizedBox(height: 4),
                      Text(
                        r.dateSubmitted,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: DC.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Admin Notes', style: _sectionLabel()),
            const SizedBox(height: 6),
            Text(
              r.adminNotes,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: DC.textMid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle _labelStyle() => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    color: DC.textSoft,
    fontWeight: FontWeight.w500,
  );
  static TextStyle _valueStyle() => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    color: DC.primaryDark,
    fontWeight: FontWeight.w500,
  );
  static TextStyle _sectionLabel() => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    color: DC.primaryDark,
    fontWeight: FontWeight.w700,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// DIALOG 2: UPDATE REPORT
// ══════════════════════════════════════════════════════════════════════════════
class _UpdateReportDialog extends StatefulWidget {
  final ReportRecord report;
  final void Function(String s, String v, String n) onProceedToVerify;
  const _UpdateReportDialog({
    required this.report,
    required this.onProceedToVerify,
  });
  @override
  State<_UpdateReportDialog> createState() => _UpdateReportDialogState();
}

class _UpdateReportDialogState extends State<_UpdateReportDialog> {
  String? _newStatus;
  String? _newVuln;
  final _notesCtrl = TextEditingController();
  static const _statusOpts = ['Validated', 'Pending', 'Completed', 'Rejected'];
  static const _vulnOpts = ['Low', 'Medium', 'High'];
  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final canUpdate = _newStatus != null && _newVuln != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 420, vertical: 100),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update Report',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DC.primaryDark,
                  ),
                ),
                _XBtn(onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5FB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DC.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Report ID:  ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: DC.primaryDark,
                        ),
                      ),
                      Text(
                        r.id,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: DC.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Current Status:  ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: DC.primaryDark,
                        ),
                      ),
                      _StatusBadge(status: r.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('New Status', style: _fieldLabel()),
            const SizedBox(height: 8),
            _BlankDropdown(
              value: _newStatus,
              items: _statusOpts,
              onChanged: (v) => setState(() => _newStatus = v),
            ),
            const SizedBox(height: 16),
            Text('Vulnerability Type', style: _fieldLabel()),
            const SizedBox(height: 8),
            _BlankDropdown(
              value: _newVuln,
              items: _vulnOpts,
              onChanged: (v) => setState(() => _newVuln = v),
            ),
            const SizedBox(height: 16),
            Text('Notes', style: _fieldLabel()),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DC.border),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 4,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: DC.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe the action taken or update details...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: DC.textSoft,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DC.textMid,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: DC.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canUpdate
                        ? () => widget.onProceedToVerify(
                            _newStatus!,
                            _newVuln!,
                            _notesCtrl.text,
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3A8A),
                      disabledBackgroundColor: DC.border,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Update',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle _fieldLabel() => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: DC.primaryDark,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// DIALOG 3: VERIFY IDENTITY — exact match to uploaded reference image
// ══════════════════════════════════════════════════════════════════════════════
class _VerifyIdentityDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  const _VerifyIdentityDialog({required this.onConfirm});
  @override
  State<_VerifyIdentityDialog> createState() => _VerifyIdentityDialogState();
}

class _VerifyIdentityDialogState extends State<_VerifyIdentityDialog> {
  bool _obscure = true;
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.isEmpty) {
      setState(() => _error = 'Password is required.');
      return;
    }
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 12,
      // FIX: vertical reduced from 260 → 100 so dialog has room to render
      // horizontal 370 keeps it compact (~460px on a 1200px screen)
      insetPadding: const EdgeInsets.symmetric(horizontal: 370, vertical: 100),
      child: Padding(
        // Tightened inner padding so content fits without overflow
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // shrink-wraps — no fixed height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + × ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      'Verify Identity to Update Record',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DC.primaryDark,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: DC.textSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Subtitle ─────────────────────────────────────────────────────
            Center(
              child: Text(
                'You are about to update this record. Please\n'
                'enter your password to authorize this action.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: DC.textMid,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── "Password" label ──────────────────────────────────────────────
            Text(
              'Password',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DC.primaryDark,
              ),
            ),
            const SizedBox(height: 6),

            // ── Input field — h=46, compact ───────────────────────────────────
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _error != null
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFD1D5DB),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 17,
                      color: DC.textSoft,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      obscureText: _obscure,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: DC.primaryDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: DC.textSoft,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 17,
                        color: DC.textSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 5),
              Text(
                _error!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 18),

            // ── Buttons ───────────────────────────────────────────────────────
            // Both buttons aligned with equal height and spacing
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: DC.primaryDark,
                        side: const BorderSide(
                          color: Color(0xFFD1D5DB),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: DC.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
// FILTER / SORT SHEETS
// ══════════════════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final String? currentStatus, currentVuln;
  final void Function(String? s, String? v) onApply;
  final VoidCallback onClear;
  const _FilterSheet({
    required this.currentStatus,
    required this.currentVuln,
    required this.onApply,
    required this.onClear,
  });
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _status;
  String? _vuln;
  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    _vuln = widget.currentVuln;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Records',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: DC.primaryDark,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Status',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DC.textMid,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ['Validated', 'Pending', 'Rejected', 'Completed']
              .map(
                (s) => _ToggleChip(
                  label: s,
                  selected: _status == s,
                  onTap: () =>
                      setState(() => _status = _status == s ? null : s),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        Text(
          'Vulnerability',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DC.textMid,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ['Low', 'Medium', 'High']
              .map(
                (v) => _ToggleChip(
                  label: v,
                  selected: _vuln == v,
                  onTap: () => setState(() => _vuln = _vuln == v ? null : v),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onClear,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: DC.border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: DC.textMid,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => widget.onApply(_status, _vuln),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DC.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SortSheet extends StatefulWidget {
  final String currentField;
  final bool ascending;
  final void Function(String f, bool a) onApply;
  const _SortSheet({
    required this.currentField,
    required this.ascending,
    required this.onApply,
  });
  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late String _field;
  late bool _asc;
  @override
  void initState() {
    super.initState();
    _field = widget.currentField;
    _asc = widget.ascending;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort Records',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: DC.primaryDark,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sort by',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DC.textMid,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            _ToggleChip(
              label: 'Report ID',
              selected: _field == 'id',
              onTap: () => setState(() => _field = 'id'),
            ),
            _ToggleChip(
              label: 'Timestamp',
              selected: _field == 'timestamp',
              onTap: () => setState(() => _field = 'timestamp'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Order',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DC.textMid,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            _ToggleChip(
              label: 'Ascending',
              selected: _asc,
              onTap: () => setState(() => _asc = true),
            ),
            _ToggleChip(
              label: 'Descending',
              selected: !_asc,
              onTap: () => setState(() => _asc = false),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onApply(_field, _asc),
            style: ElevatedButton.styleFrom(
              backgroundColor: DC.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              'Apply Sort',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// TABLE COMPONENTS
// ══════════════════════════════════════════════════════════════════════════════
class _TH extends StatelessWidget {
  final String label;
  final int flex;
  final bool right;
  const _TH(this.label, {required this.flex, this.right = false});
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      label,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: DC.primaryDark,
      ),
    ),
  );
}

class _TableRow extends StatefulWidget {
  final ReportRecord report;
  final bool shade;
  final VoidCallback onView, onEdit;
  const _TableRow({
    required this.report,
    required this.shade,
    required this.onView,
    required this.onEdit,
  });
  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: _hover
            ? const Color(0xFFF0F3FF)
            : widget.shade
            ? const Color(0xFFFAFBFF)
            : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 18,
              child: Text(
                r.id,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: DC.primaryDark,
                ),
              ),
            ),
            Expanded(
              flex: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.city,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: DC.primaryDark,
                    ),
                  ),
                  Text(
                    r.province,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: DC.textSoft,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 22,
              child: Text(
                r.titleShort,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: DC.textMid,
                ),
              ),
            ),
            Expanded(flex: 18, child: _VulnBadge(level: r.vulnerability)),
            Expanded(flex: 18, child: _StatusBadge(status: r.status)),
            Expanded(
              flex: 22,
              child: Text(
                r.timestamp,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: DC.textMid,
                ),
              ),
            ),
            Expanded(
              flex: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _IconBtn(
                    assetPath: 'assets/icon/report/view-icon.png',
                    fallback: Icons.visibility_outlined,
                    tooltip: 'View Details',
                    onTap: widget.onView,
                  ),
                  const SizedBox(width: 6),
                  _IconBtn(
                    assetPath: 'assets/icon/report/edit-icon.png',
                    fallback: Icons.edit_outlined,
                    tooltip: 'Edit Report',
                    onTap: widget.onEdit,
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

// ══════════════════════════════════════════════════════════════════════════════
// BADGES
// ══════════════════════════════════════════════════════════════════════════════
class _VulnBadge extends StatelessWidget {
  final String level;
  const _VulnBadge({required this.level});
  @override
  Widget build(BuildContext context) {
    final c = _vulnColors[level] ?? [const Color(0xFF9CA3AF), Colors.white];
    return SizedBox(
      height: _badgeH,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(minWidth: _badgeMinW),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: c[0],
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            level,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: c[1],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final c =
        _statusColors[status] ??
        [const Color(0xFFF3F4F6), const Color(0xFF6B7280)];
    return SizedBox(
      height: _badgeH,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(minWidth: _badgeMinW),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: c[0],
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: c[1],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════
class _BlankDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _BlankDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FF),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: DC.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: DC.textSoft),
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: DC.primaryDark),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        hint: const SizedBox.shrink(),
        onChanged: onChanged,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: item == value
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: DC.primaryDark,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? DC.primary : Colors.white,
        border: Border.all(color: selected ? DC.primary : DC.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : DC.textMid,
        ),
      ),
    ),
  );
}

class _BarChipBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _BarChipBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  State<_BarChipBtn> createState() => _BarChipBtnState();
}

class _BarChipBtnState extends State<_BarChipBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final on = widget.active || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: on ? DC.primary.withOpacity(0.07) : Colors.white,
            border: Border.all(
              color: on ? DC.primary.withOpacity(0.4) : DC.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: on ? DC.primary : DC.textSoft),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: on ? DC.primary : DC.textMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatefulWidget {
  final String assetPath;
  final IconData fallback;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn({
    required this.assetPath,
    required this.fallback,
    required this.tooltip,
    required this.onTap,
  });
  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    child: MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFEEF1FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Image.asset(
              widget.assetPath,
              width: 18,
              height: 18,
              color: _hover ? DC.primary : DC.textMid,
              errorBuilder: (_, _, _) => Icon(
                widget.fallback,
                size: 18,
                color: _hover ? DC.primary : DC.textMid,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CircleIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});
  @override
  State<_CircleIconBtn> createState() => _CircleIconBtnState();
}

class _CircleIconBtnState extends State<_CircleIconBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
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

class _XBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _XBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.close_rounded, size: 16, color: DC.textMid),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String title, value, growth, iconAsset;
  final IconData fallback;
  final Color iconBg, iconColor;
  const _StatCard({
    required this.title,
    required this.value,
    required this.growth,
    required this.iconAsset,
    required this.fallback,
    required this.iconBg,
    required this.iconColor,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
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
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                iconAsset,
                color: iconColor,
                errorBuilder: (_, _, _) =>
                    Icon(fallback, size: 17, color: iconColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: DC.primaryDark,
            letterSpacing: -0.5,
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
              growth,
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
  );
}

class _MediaThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 160,
      height: 120,
      color: const Color(0xFFE0E4F0),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 38,
          color: DC.primary.withOpacity(0.25),
        ),
      ),
    ),
  );
}
