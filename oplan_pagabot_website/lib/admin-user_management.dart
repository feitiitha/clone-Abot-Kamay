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

const _statusColors = {
  'Verified': [Color(0xFFDCFCE7), Color(0xFF15803D)],
  'Pending': [Color(0xFFDBEAFE), Color(0xFF2563EB)],
  'Denied': [Color(0xFFFFECEC), Color(0xFFDC2626)],
};

const double _badgeH = 28;
const double _badgeMinW = 90;

class UserRecord {
  final String id, firstName, middleName, lastName, suffix, sex, dob, email;
  final String region, province, city, barangay, address, postalCode;
  final String idNumber, nationality, idType;
  final String dateCreated;
  String status;

  UserRecord({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.sex,
    required this.dob,
    required this.email,
    required this.region,
    required this.province,
    required this.city,
    required this.barangay,
    required this.address,
    required this.postalCode,
    required this.idNumber,
    required this.nationality,
    required this.idType,
    required this.dateCreated,
    required this.status,
  });

  String get fullName => '$firstName $lastName';
}

final List<UserRecord> _masterUsers = [
  UserRecord(
    id: 'USR-001',
    firstName: 'Juan',
    middleName: 'N/A',
    lastName: 'Carlos',
    suffix: 'N/A',
    sex: 'Male',
    dob: 'January 20, 2005',
    email: 'sampleuser1@gmail.com',
    region: 'Region IV-A',
    province: 'Cavite',
    city: 'Imus',
    barangay: 'Buhay na Tubig',
    address: 'B10 L2 Elcano St.',
    postalCode: '4103',
    idNumber: '1234-1232-4321-1212',
    nationality: 'Filipino',
    idType: 'Driver\'s License',
    dateCreated: '02/10/26, 07:21:24 AM',
    status: 'Pending',
  ),
  UserRecord(
    id: 'USR-002',
    firstName: 'Merna',
    middleName: 'N/A',
    lastName: 'Sy',
    suffix: 'N/A',
    sex: 'Female',
    dob: 'October 15, 1998',
    email: 'sampleuser2@gmail.com',
    region: 'Region IV-A',
    province: 'Cavite',
    city: 'Trece',
    barangay: 'San Agustin',
    address: 'Blk 5 Lot 12',
    postalCode: '4109',
    idNumber: '9876-5432-1098-7654',
    nationality: 'Filipino',
    idType: 'UMID',
    dateCreated: '02/11/26, 09:30:10 AM',
    status: 'Verified',
  ),
  UserRecord(
    id: 'USR-003',
    firstName: 'John',
    middleName: 'N/A',
    lastName: 'Tiu',
    suffix: 'N/A',
    sex: 'Male',
    dob: 'March 5, 1990',
    email: 'sampleuser3@gmail.com',
    region: 'Region IV-A',
    province: 'Cavite',
    city: 'Dasmarinas',
    barangay: 'Salitran',
    address: 'Street 4',
    postalCode: '4114',
    idNumber: '1111-2222-3333-4444',
    nationality: 'Filipino',
    idType: 'Passport',
    dateCreated: '02/12/26, 02:15:00 PM',
    status: 'Denied',
  ),
  UserRecord(
    id: 'USR-004',
    firstName: 'Hailey',
    middleName: 'N/A',
    lastName: 'Cruz',
    suffix: 'N/A',
    sex: 'Female',
    dob: 'December 12, 2001',
    email: 'sampleuser4@gmail.com',
    region: 'Region IV-A',
    province: 'Rizal',
    city: 'Antipolo',
    barangay: 'Dela Paz',
    address: 'Avenue 1',
    postalCode: '1870',
    idNumber: '5555-6666-7777-8888',
    nationality: 'Filipino',
    idType: 'National ID',
    dateCreated: '02/13/26, 11:45:30 AM',
    status: 'Pending',
  ),
];

class UserManagementBody extends StatefulWidget {
  const UserManagementBody({super.key});
  @override
  State<UserManagementBody> createState() => _UserManagementBodyState();
}

class _UserManagementBodyState extends State<UserManagementBody> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _sortField = 'id';
  bool _sortAsc = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<UserRecord> get _displayed {
    var list = _masterUsers.where((r) {
      final q = _searchQuery.toLowerCase();
      return q.isEmpty ||
          r.id.toLowerCase().contains(q) ||
          r.email.toLowerCase().contains(q) ||
          r.fullName.toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) {
      final cmp = _sortField == 'id'
          ? a.id.compareTo(b.id)
          : a.id.compareTo(b.id);
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  void _openView(UserRecord r) => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.40),
        builder: (_) => _UserDetailsDialog(user: r),
      );

  void _openUpdate(UserRecord r) => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.40),
        builder: (_) => _UpdateUserDialog(
          user: r,
          onUpdate: (s, notes) {
            Navigator.pop(context);
            _openVerify(r, s, notes);
          },
        ),
      );

  void _openVerify(UserRecord r, String s, String n) => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.40),
        builder: (_) => _VerifyIdentityDialog(
          onConfirm: () {
            setState(() {
              r.status = s;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${r.id} status updated to "$s"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: s == 'Verified' ? const Color(0xFF15803D) : const Color(0xFF2563EB),
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
                    'User Management',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: DC.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage mobile user accounts and monitor citizen engagement',
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
                  iconAsset: 'assets/side-tab-icon/Frame.png',
                  fallback: Icons.people_outline_rounded,
                  iconBg: const Color(0xFFE8EEFF),
                  iconColor: const Color(0xFF6B8CEF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Pending',
                  value: '701',
                  growth: '+10% this month',
                  iconAsset: 'assets/icon/report/file-icon.png',
                  fallback: Icons.description_outlined,
                  iconBg: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF818CF8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Verified',
                  value: '100',
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/verified-report-icon.png',
                  fallback: Icons.domain_verification_outlined,
                  iconBg: const Color(0xFFF0FDF4),
                  iconColor: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Denied',
                  value: '1,003',
                  growth: '+12% this month',
                  iconAsset: 'assets/icon/report/verified-report-icon.png',
                  fallback: Icons.check_circle_outline,
                  iconBg: const Color(0xFFF3F4F6),
                  iconColor: const Color(0xFF4B5563),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: DC.border),
                      borderRadius: BorderRadius.circular(50)
                    ),
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
                              hintText: 'Search by email or UID',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: DC.textSoft,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12)
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
                ),
                const SizedBox(width: 12),
                _BarChipBtn(
                  icon: Icons.filter_list_rounded,
                  label: 'Filter',
                  active: false,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                _BarChipBtn(
                  icon: Icons.swap_vert_rounded,
                  label: 'Sort',
                  active: false,
                  onTap: () {},
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
                      _TH('User ID', flex: 15),
                      _TH('Name', flex: 20),
                      _TH('Email', flex: 25),
                      _TH('Municipality', flex: 20),
                      _TH('Status', flex: 15),
                      _TH('Actions', flex: 10, right: true),
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
                                user: e.value,
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
// DIALOG 1: ACCOUNT DETAILS
// ══════════════════════════════════════════════════════════════════════════════
class _UserDetailsDialog extends StatelessWidget {
  final UserRecord user;
  const _UserDetailsDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    final u = user;
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
                Expanded(
                  child: Center(
                    child: Text(
                      'Account Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: DC.primaryDark,
                      ),
                    ),
                  ),
                ),
                _XBtn(onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (Photo, Status)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status', style: _labelStyle()),
                          const SizedBox(height: 6),
                          _StatusBadge(status: u.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time Created', style: _labelStyle()),
                          const SizedBox(height: 6),
                          Text(
                            u.dateCreated,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: DC.textMid,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right Column (Details)
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('User ID', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.id, style: _valStyle(bold: true)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('First Name', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.firstName, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Middle Name', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.middleName, style: _valStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Last Name', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.lastName, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Suffix', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.suffix, style: _valStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sex', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.sex, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date of Birth', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.dob, style: _valStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email Address', style: _labelStyle()),
                          const SizedBox(height: 4),
                          Text(u.email, style: _valStyle()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Current Address', style: _sectionLabel()),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Region', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.region, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('State/Province', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.province, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('City/Municipality', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.city, style: _valStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Barangay', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.barangay, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('House no./Blg/St. name', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.address, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Postal Code', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.postalCode, style: _valStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID number', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.idNumber, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nationality', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.nationality, style: _valStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type of government ID', style: _labelStyle()),
                                const SizedBox(height: 4),
                                Text(u.idType, style: _valStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Photo of valid ID', style: _labelStyle()),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle _labelStyle() => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    color: DC.textSoft,
    fontWeight: FontWeight.w500,
  );
  static TextStyle _valStyle({bool bold = false}) => GoogleFonts.plusJakartaSans(
    fontSize: 13.5,
    color: DC.primaryDark,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
  );
  static TextStyle _sectionLabel() => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    color: DC.primaryDark,
    fontWeight: FontWeight.w700,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// DIALOG 2: UPDATE STATUS
// ══════════════════════════════════════════════════════════════════════════════
class _UpdateUserDialog extends StatefulWidget {
  final UserRecord user;
  final void Function(String s, String n) onUpdate;
  const _UpdateUserDialog({
    required this.user,
    required this.onUpdate,
  });
  @override
  State<_UpdateUserDialog> createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<_UpdateUserDialog> {
  String? _newStatus;
  final _notesCtrl = TextEditingController();
  static const _statusOpts = ['Verified', 'Pending', 'Denied'];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final canUpdate = _newStatus != null;
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
                Expanded(
                  child: Center(
                    child: Text(
                      'Update User Status',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: DC.primaryDark,
                      ),
                    ),
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
                        'User ID:  ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: DC.primaryDark,
                        ),
                      ),
                      Text(
                        u.id,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: DC.textSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Name:  ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: DC.primaryDark,
                        ),
                      ),
                      Text(
                        u.fullName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: DC.textSoft,
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
                      _StatusBadge(status: u.status),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFFF3F4F6)
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
                        ? () => widget.onUpdate(
                            _newStatus!,
                            _notesCtrl.text,
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF263A84),
                      disabledBackgroundColor: DC.border,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
// COMPONENTS (Badges, Buttons, etc)
// ══════════════════════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final c = _statusColors[status] ?? [const Color(0xFFF3F4F6), const Color(0xFF6B7280)];
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
      border: Border.all(color: DC.border),
      borderRadius: BorderRadius.circular(10),
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

class _XBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _XBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Icon(Icons.close_rounded, size: 20, color: DC.primaryDark),
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
                errorBuilder: (_, __, ___) =>
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
              Icons.check_circle_outline,
              size: 11,
              color: Color(0xFF15803D), // just a mock
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
  final UserRecord user;
  final bool shade;
  final VoidCallback onView, onEdit;
  const _TableRow({
    required this.user,
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
    final u = widget.user;
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
              flex: 15,
              child: Text(
                u.id,
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
                u.fullName,
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
                u.email,
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
                '${u.city}, ${u.province}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: DC.textMid,
                ),
              ),
            ),
            Expanded(flex: 15, child: _StatusBadge(status: u.status)),
            Expanded(
              flex: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _IconBtn(
                    fallback: Icons.visibility_outlined,
                    tooltip: 'View Details',
                    onTap: widget.onView,
                  ),
                  const SizedBox(width: 4),
                  _IconBtn(
                    fallback: Icons.edit_outlined,
                    tooltip: 'Update Status',
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
// DIALOG 3: VERIFY IDENTITY TO UPDATE RECORD
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 370, vertical: 100),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              'Password',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DC.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
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
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F1F3),
                        side: const BorderSide(
                          color: Color(0xFFD1D5DB),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
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
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
