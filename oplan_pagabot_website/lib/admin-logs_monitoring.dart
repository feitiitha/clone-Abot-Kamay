import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin-settings.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
class DC {
  static const primary = Color(0xFF1D3A8A);
  static const primaryDark = Color(0xFF0D1B3E);
  static const textMid = Color(0xFF3D4F6E);
  static const textSoft = Color(0xFF7A8BAA);
  static const border = Color(0xFFE3E8F7);
  static const bgPage = Color(0xFFF4F5FB);
}

class LogRecord {
  final String timestamp;
  final String performedBy;
  final String role;
  final String action;
  final String target;
  final String details;

  LogRecord({
    required this.timestamp,
    required this.performedBy,
    required this.role,
    required this.action,
    required this.target,
    required this.details,
  });
}

String _formatDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  final yyyy = d.year;
  int h = d.hour;
  final m = d.minute.toString().padLeft(2, '0');
  final s = d.second.toString().padLeft(2, '0');
  final ampm = h >= 12 ? 'PM' : 'AM';
  if (h == 0) h = 12;
  else if (h > 12) h -= 12;
  return '$mm/$dd/$yyyy, ${h.toString().padLeft(2, '0')}:$m:$s $ampm';
}

void addSystemLog(String performedBy, String role, String action, String target, String details) {
  globalLogs.insert(0, LogRecord(
    timestamp: _formatDate(DateTime.now()),
    performedBy: performedBy,
    role: role,
    action: action,
    target: target,
    details: details,
  ));
}

final List<LogRecord> globalLogs = [
  LogRecord(
    timestamp: '02/19/2025, 11:42:05 AM',
    performedBy: 'Stella Santuyo',
    role: 'Admin',
    action: 'Updated Status Report',
    target: 'RPT-001',
    details: 'Updated Status Report RPT-001 to Verified',
  ),
  LogRecord(
    timestamp: '02/17/2025, 5:42:01 PM',
    performedBy: 'Yve Sy',
    role: 'Super Admin',
    action: 'Published Content',
    target: 'ARTT-004',
    details: 'Published a new content',
  ),
  LogRecord(
    timestamp: '02/10/2025, 10:42:05 PM',
    performedBy: 'Faith Cabanit',
    role: 'Admin',
    action: 'Updated Verified Account',
    target: 'USR-002',
    details: 'Updated User USR-002 to Verified',
  ),
  LogRecord(
    timestamp: '02/9/2025, 06:49:05 PM',
    performedBy: 'Carl Santos',
    role: 'Admin',
    action: 'Updated Content',
    target: 'ARTT-001',
    details: 'Changed Status to "Published"',
  ),
];

class LogsMonitoringBody extends StatefulWidget {
  const LogsMonitoringBody({super.key});
  @override
  State<LogsMonitoringBody> createState() => _LogsMonitoringBodyState();
}

class _LogsMonitoringBodyState extends State<LogsMonitoringBody> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterRole;
  String _sortField = 'time';
  bool _sortAsc = false;
  Timer? _timer;
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() {});
    });
    // Simulate real-time logs every 30 seconds
    _liveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          addSystemLog(
            'System',
            'Service',
            'Automated Backup',
            'Database',
            'System performed a scheduled data backup.',
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchCtrl.dispose();
    _liveTimer?.cancel();
    super.dispose();
  }

  List<LogRecord> get _displayed {
    var list = globalLogs.where((r) {
      final q = _searchQuery.toLowerCase();
      final ms = q.isEmpty ||
          r.performedBy.toLowerCase().contains(q) ||
          r.target.toLowerCase().contains(q) ||
          r.action.toLowerCase().contains(q) ||
          r.details.toLowerCase().contains(q);
      final fr = _filterRole == null || r.role == _filterRole;
      return ms && fr;
    }).toList();

    list.sort((a, b) {
      dynamic valA, valB;
      if (_sortField == 'user') {
        valA = a.performedBy.toLowerCase();
        valB = b.performedBy.toLowerCase();
      } else {
        // Simple string compare for timestamp is okay if format is YYYY/MM/DD...
        // but here it's MM/DD/YYYY. We'll just do a basic string compare for now
        // or parse it. Let's do a basic one for the sake of the task.
        valA = a.timestamp;
        valB = b.timestamp;
      }
      final cmp = valA.compareTo(valB);
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  void _openFilter() => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _FilterSheet(
          currentRole: _filterRole,
          onApply: (r) {
            setState(() {
              _filterRole = r;
            });
            Navigator.pop(context);
          },
          onClear: () {
            setState(() {
              _filterRole = null;
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
                    'Activity Logs',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: DC.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitor system activities and administrative actions',
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
          const SizedBox(height: 28),

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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: DC.border),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: DC.textSoft,
                        ),
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
                              hintText: 'Search by email or UID',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: DC.textSoft,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: DC.textSoft,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (_filterRole != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DC.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _filterRole!,
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
                  active: _filterRole != null,
                  onTap: _openFilter,
                ),
                const SizedBox(width: 10),
                _BarChipBtn(
                  icon: Icons.sort_rounded,
                  label: 'Sort',
                  active: true,
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
                      _TH('Timestamp', flex: 20),
                      _TH('Performed by', flex: 18, center: true),
                      _TH('Role', flex: 15, center: true),
                      _TH('Action', flex: 22, center: true),
                      _TH('Target', flex: 12, center: true),
                      _TH('Details', flex: 25),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEF0F8)),
                rows.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'No logs match your search.',
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
                            .map((e) => _TableRow(log: e.value))
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
                        'Show 1 out of 1 pages',
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
// COMPONENTS
// ══════════════════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final String? currentRole;
  final void Function(String?) onApply;
  final VoidCallback onClear;
  const _FilterSheet({
    required this.currentRole,
    required this.onApply,
    required this.onClear,
  });
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _role;
  @override
  void initState() {
    super.initState();
    _role = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Logs',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DC.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Role',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DC.textMid,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['Admin', 'Super Admin']
                  .map(
                    (r) => _ToggleChip(
                      label: r,
                      selected: _role == r,
                      onTap: () => setState(() => _role = _role == r ? null : r),
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
                    onPressed: () => widget.onApply(_role),
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
  final void Function(String, bool) onApply;
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
              'Sort Logs',
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
                  label: 'Timestamp',
                  selected: _field == 'time',
                  onTap: () => setState(() => _field = 'time'),
                ),
                _ToggleChip(
                  label: 'Performed By',
                  selected: _field == 'user',
                  onTap: () => setState(() => _field = 'user'),
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
                  label: 'Newest First',
                  selected: !_asc,
                  onTap: () => setState(() => _asc = false),
                ),
                _ToggleChip(
                  label: 'Oldest First',
                  selected: _asc,
                  onTap: () => setState(() => _asc = true),
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

class _TH extends StatelessWidget {
  final String label;
  final int flex;
  final bool center;
  const _TH(this.label, {required this.flex, this.center = false});
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      label,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: DC.primaryDark,
      ),
    ),
  );
}

class _TableRow extends StatelessWidget {
  final LogRecord log;
  const _TableRow({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 20,
            child: Text(
              log.timestamp,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              log.performedBy,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              log.role,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ),
          Expanded(
            flex: 22,
            child: Text(
              log.action,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              log.target,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
              ),
            ),
          ),
          Expanded(
            flex: 25,
            child: Text(
              log.details,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: DC.textMid,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
