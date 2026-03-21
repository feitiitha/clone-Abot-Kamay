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

class AdminRecord {
  final String name;
  final String email;
  final String role;

  AdminRecord({required this.name, required this.email, required this.role});
}

final List<AdminRecord> _masterAdmins = [
  AdminRecord(
    name: 'Yve Sy',
    email: 'superadmin@gmail.com',
    role: 'Super Admin',
  ),
  AdminRecord(name: 'Stella Santuyo', email: 'admin1@gmail.com', role: 'Admin'),
  AdminRecord(name: 'Faith Cabanit', email: 'admin2@gmail.com', role: 'Admin'),
  AdminRecord(name: 'Carl Santos', email: 'admin3@gmail.com', role: 'Admin'),
];

class AdminManagementBody extends StatefulWidget {
  const AdminManagementBody({super.key});
  @override
  State<AdminManagementBody> createState() => _AdminManagementBodyState();
}

class _AdminManagementBodyState extends State<AdminManagementBody> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterRole;
  String _sortField = 'name';
  bool _sortAsc = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminRecord> get _displayed {
    var list = _masterAdmins.where((r) {
      final q = _searchQuery.toLowerCase();
      final ms =
          q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.email.toLowerCase().contains(q);
      return ms && (_filterRole == null || r.role == _filterRole);
    }).toList();
    list.sort((a, b) {
      final cmp = _sortField == 'name'
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : a.role.toLowerCase().compareTo(b.role.toLowerCase());
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
                    'Admin Management',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: DC.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage administrator accounts.',
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
          const SizedBox(height: 32),

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
                        const Icon(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                const SizedBox(width: 12),
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
                      _TH('Name', flex: 20),
                      _TH('Email Adress', flex: 30),
                      _TH('Role', flex: 20),
                      _TH('Actions', flex: 15, right: true),
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
                              (e) =>
                                  _TableRow(admin: e.value, shade: e.key.isOdd),
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
      textAlign: right ? TextAlign.center : TextAlign.center,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: DC.primaryDark,
      ),
    ),
  );
}

class _TableRow extends StatefulWidget {
  final AdminRecord admin;
  final bool shade;
  const _TableRow({required this.admin, required this.shade});
  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final a = widget.admin;
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
              flex: 20,
              child: Text(
                a.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: DC.textMid,
                ),
              ),
            ),
            Expanded(
              flex: 30,
              child: Text(
                a.email,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: DC.textMid,
                ),
              ),
            ),
            Expanded(
              flex: 20,
              child: Text(
                a.role,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconBtn(
                    fallback: Icons.visibility_outlined,
                    tooltip: 'View Details',
                    onTap: () {}, // Provide view functionality when needed
                  ),
                  const SizedBox(width: 4),
                  _IconBtn(
                    fallback: Icons.edit_outlined,
                    tooltip: 'Edit Account',
                    onTap: () {}, // Provide edit functionality when needed
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
  final IconData fallback;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn({
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
            child: Icon(
              widget.fallback,
              size: 20,
              color: _hover ? DC.primary : DC.textMid,
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
          'Filter Records',
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
          children: ['Super Admin', 'Admin']
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
              label: 'Full Name',
              selected: _field == 'name',
              onTap: () => setState(() => _field = 'name'),
            ),
            _ToggleChip(
              label: 'Role',
              selected: _field == 'role',
              onTap: () => setState(() => _field = 'role'),
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
