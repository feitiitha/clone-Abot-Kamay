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

const _statusColors = {
  'Published': [Color(0xFFDCFCE7), Color(0xFF15803D)],
  'Draft': [
    Color(0xFF6B7280),
    Colors.white,
  ], // The screenshot uses a dark gray pill with white text for Draft
};

const _typeColors = {
  'Article': [Color(0xFFDBEAFE), Color(0xFF2563EB)],
  'Notice': [Color(0xFFFEF3C7), Color(0xFFD97706)],
  'Carousel': [Color(0xFFE0E7FF), Color(0xFF4338CA)],
};

const double _badgeH = 28;
const double _badgeMinW = 80;

class ContentRecord {
  final String id;
  String author, title, type, timestamp, status, content;
  final String dateCreated;
  String lastUpdated;

  ContentRecord({
    required this.id,
    required this.author,
    required this.title,
    required this.type,
    required this.timestamp,
    required this.status,
    required this.content,
    required this.dateCreated,
    required this.lastUpdated,
  });
}

final List<ContentRecord> _masterContent = [
  ContentRecord(
    id: 'ARTT-001',
    author: 'Stella Santuyo',
    title: 'Guidelines for 4Ps Beneficiaries 2026',
    type: 'Article',
    timestamp: '02/16/26, 03:21:24 PM',
    status: 'Published',
    content:
        'The Pantawid Pamilyang Pilipino Program (4Ps) continues to evolve in 2026 to better support the poorest Filipino households. This year\'s updates focus on expanding digital inclusion, removing administrative barriers to graduation, and providing automatic utility relief...\n\nKey updates include the shift from a mandatory 7-year exit to a readiness-based \'Social Welfare and Development Indicator\' (SWDI) assessment. It also details the automatic 100% electricity discount for households consuming under 50kWh and the \'First 1,000 Days\' (F1KD) health grants for pregnant members.',
    dateCreated: '02/16/26, 03:21:24 PM',
    lastUpdated: '02/19/2026, 12:55:00 PM',
  ),
  ContentRecord(
    id: 'ARTT-002',
    author: 'Yina Lee',
    title: 'URGENT: Schedule of Mobile App Scheduled Maintenance',
    type: 'Notice',
    timestamp: '02/14/26, 09:27:30 AM',
    status: 'Draft',
    content:
        'Please be advised that the Oplan Pagabot Mobile App will undergo scheduled maintenance on February 28, 2026, from 12:00 AM to 4:00 AM.',
    dateCreated: '02/14/26, 09:27:30 AM',
    lastUpdated: '02/14/26, 09:27:30 AM',
  ),
  ContentRecord(
    id: 'ARTT-003',
    author: 'Faith Cabant',
    title: 'Para sa Bayan: Serving the People Together',
    type: 'Carousel',
    timestamp: '02/17/26, 12:20:15 PM',
    status: 'Draft',
    content:
        'Carousel slide content showcasing various government programs and public services directed towards community development and support.',
    dateCreated: '02/17/26, 12:20:15 PM',
    lastUpdated: '02/17/26, 12:20:15 PM',
  ),
  ContentRecord(
    id: 'ARTT-004',
    author: 'Carl Santos',
    title: 'Anunsyo: Listahan ng mga Bagong Benepisyaryo',
    type: 'Notice',
    timestamp: '02/13/26, 05:20:15 PM',
    status: 'Published',
    content:
        'Narito ang inisyal na listahan ng mga bagong aprubadong benepisyaryo para sa unag quarter ng taon.  Maaari ninyong suriin ang inyong pangalan sa ibaba...',
    dateCreated: '02/13/26, 05:20:15 PM',
    lastUpdated: '02/14/26, 10:00:00 AM',
  ),
];

class ContentManagementBody extends StatefulWidget {
  const ContentManagementBody({super.key});
  @override
  State<ContentManagementBody> createState() => _ContentManagementBodyState();
}

class _ContentManagementBodyState extends State<ContentManagementBody> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterStatus;
  String? _filterType;
  String _sortField = 'id';
  bool _sortAsc = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ContentRecord> get _displayed {
    var list = _masterContent.where((r) {
      final q = _searchQuery.toLowerCase();
      final ms = q.isEmpty ||
          r.id.toLowerCase().contains(q) ||
          r.title.toLowerCase().contains(q) ||
          r.author.toLowerCase().contains(q) ||
          r.type.toLowerCase().contains(q);
      final fs = _filterStatus == null || r.status == _filterStatus;
      final ft = _filterType == null || r.type == _filterType;
      return ms && fs && ft;
    }).toList();

    list.sort((a, b) {
      dynamic valA, valB;
      if (_sortField == 'author') {
        valA = a.author.toLowerCase();
        valB = b.author.toLowerCase();
      } else if (_sortField == 'title') {
        valA = a.title.toLowerCase();
        valB = b.title.toLowerCase();
      } else {
        valA = a.id.toLowerCase();
        valB = b.id.toLowerCase();
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
          currentStatus: _filterStatus,
          currentType: _filterType,
          onApply: (s, t) {
            setState(() {
              _filterStatus = s;
              _filterType = t;
            });
            Navigator.pop(context);
          },
          onClear: () {
            setState(() {
              _filterStatus = null;
              _filterType = null;
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

  void _openView(ContentRecord r) => showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (_) => _ContentDetailsDialog(content: r),
  );

  void _openCreate() => showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (_) => _CreateContentDialog(
      onCreate: (type, status, title, author, content) {
        setState(() {
          _masterContent.insert(
            0,
            ContentRecord(
              id: 'ARTT-${(_masterContent.length + 1).toString().padLeft(3, '0')}',
              author: author,
              title: title,
              type: type,
              timestamp: 'Just now',
              status: status,
              content: content,
              dateCreated: 'Just now',
              lastUpdated: 'Just now',
            ),
          );
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'New content created successfully',
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

  void _openUpdate(ContentRecord r) => showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (_) => _EditContentDialog(
      contentRec: r,
      onUpdate: (title, author, type, status, contentDesc) {
        Navigator.pop(context);
        _openVerify(r, title, author, type, status, contentDesc);
      },
    ),
  );

  void _openVerify(
    ContentRecord r,
    String title,
    String author,
    String type,
    String status,
    String contentDesc,
  ) => showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (_) => _VerifyIdentityDialog(
      onConfirm: () {
        setState(() {
          r.title = title;
          r.author = author;
          r.type = type;
          r.status = status;
          r.content = contentDesc;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${r.id} details updated to "$status"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: status == 'Published'
                ? const Color(0xFF15803D)
                : const Color(0xFF2563EB),
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
                    'Content Management',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: DC.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage news, articles, programs, and services information',
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
                              hintText: 'Search by record ID, title, author...',
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
                if (_filterStatus != null || _filterType != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DC.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      [
                        if (_filterStatus != null) _filterStatus!,
                        if (_filterType != null) _filterType!,
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
                  active: _filterStatus != null || _filterType != null,
                  onTap: _openFilter,
                ),
                const SizedBox(width: 10),
                _BarChipBtn(
                  icon: Icons.sort_rounded,
                  label: 'Sort',
                  active: _sortField != 'id' || !_sortAsc,
                  onTap: _openSort,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openCreate,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Add New',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF263A84),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                      _TH('Article ID', flex: 15),
                      _TH('Author', flex: 18),
                      _TH('Title', flex: 25),
                      _TH('Type', flex: 15),
                      _TH('Timestamp', flex: 22),
                      _TH('Status', flex: 12),
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
                                contentRec: e.value,
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
// DIALOG 1: CONTENT DETAILS
// ══════════════════════════════════════════════════════════════════════════════
class _ContentDetailsDialog extends StatelessWidget {
  final ContentRecord content;
  const _ContentDetailsDialog({required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 400, vertical: 80),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Content Details',
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
            Text(
              content.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DC.primaryDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _TypeBadge(type: content.type),
                const SizedBox(width: 8),
                _StatusBadge(status: content.status),
              ],
            ),
            const SizedBox(height: 20),
            Text('Content', style: _labelStyle()),
            const SizedBox(height: 8),
            Container(
              height: 140,
              width: double.infinity,
              padding: const EdgeInsets.only(right: 8),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Text(
                    content.content,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: DC.primaryDark,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: DC.border),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: DC.textSoft,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(
                    text: 'Author: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '${content.author}\n'),
                  const TextSpan(
                    text: 'Published: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '${content.timestamp}\n'),
                  const TextSpan(
                    text: 'Last Updated: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: content.lastUpdated),
                ],
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
}

// ══════════════════════════════════════════════════════════════════════════════
// DIALOG 2: EDIT CONTENT
// ══════════════════════════════════════════════════════════════════════════════
class _EditContentDialog extends StatefulWidget {
  final ContentRecord contentRec;
  final void Function(
    String title,
    String author,
    String type,
    String status,
    String contentDesc,
  )
  onUpdate;
  const _EditContentDialog({required this.contentRec, required this.onUpdate});
  @override
  State<_EditContentDialog> createState() => _EditContentDialogState();
}

class _EditContentDialogState extends State<_EditContentDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _authorCtrl;
  late TextEditingController _contentCtrl;
  String? _type;
  String? _status;

  static const _typeOpts = ['Article', 'Notice', 'Carousel'];
  static const _statusOpts = ['Draft', 'Published'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.contentRec.title);
    _authorCtrl = TextEditingController(text: widget.contentRec.author);
    _contentCtrl = TextEditingController(text: widget.contentRec.content);
    _type = widget.contentRec.type;
    _status = widget.contentRec.status;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 420, vertical: 60),
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
                      'Edit Content',
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
            Text('Title', style: _fieldLabel()),
            const SizedBox(height: 6),
            _InputField(controller: _titleCtrl, hint: 'Enter content title'),
            const SizedBox(height: 16),
            Text('Author', style: _fieldLabel()),
            const SizedBox(height: 6),
            _InputField(controller: _authorCtrl, hint: 'Enter author name'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type', style: _fieldLabel()),
                      const SizedBox(height: 6),
                      _BlankDropdown(
                        value: _type,
                        items: _typeOpts,
                        onChanged: (v) => setState(() => _type = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: _fieldLabel()),
                      const SizedBox(height: 6),
                      _BlankDropdown(
                        value: _status,
                        items: _statusOpts,
                        onChanged: (v) => setState(() => _status = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Description', style: _fieldLabel()),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DC.border),
              ),
              child: TextField(
                controller: _contentCtrl,
                maxLines: 8,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: DC.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Full content text',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
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
                      backgroundColor: const Color(0xFFF0F1F3),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_type == null || _status == null) return;
                      widget.onUpdate(
                        _titleCtrl.text,
                        _authorCtrl.text,
                        _type!,
                        _status!,
                        _contentCtrl.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF263A84),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
// DIALOG 3: CREATE NEW CONTENT
// ══════════════════════════════════════════════════════════════════════════════
class _CreateContentDialog extends StatefulWidget {
  final void Function(
    String type,
    String status,
    String title,
    String author,
    String content,
  )
  onCreate;
  const _CreateContentDialog({required this.onCreate});
  @override
  State<_CreateContentDialog> createState() => _CreateContentDialogState();
}

class _CreateContentDialogState extends State<_CreateContentDialog> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String? _type = 'Article';
  String? _status = 'Published';

  static const _typeOpts = ['Article', 'Notice', 'Carousel'];
  static const _statusOpts = ['Draft', 'Published'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 420, vertical: 60),
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
                  child: Column(
                    children: [
                      Text(
                        'Create New Content',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DC.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add new content for the mobile app users to view.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: DC.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                _XBtn(onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type', style: _fieldLabel()),
                      const SizedBox(height: 6),
                      _BlankDropdown(
                        value: _type,
                        items: _typeOpts,
                        onChanged: (v) => setState(() => _type = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: _fieldLabel()),
                      const SizedBox(height: 6),
                      _BlankDropdown(
                        value: _status,
                        items: _statusOpts,
                        onChanged: (v) => setState(() => _status = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Title', style: _fieldLabel()),
            const SizedBox(height: 6),
            _InputField(controller: _titleCtrl, hint: 'Enter content title'),
            const SizedBox(height: 16),
            Text('Author', style: _fieldLabel()),
            const SizedBox(height: 6),
            _InputField(controller: _authorCtrl, hint: 'Enter author name'),
            const SizedBox(height: 16),
            Text('Content', style: _fieldLabel()),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DC.border),
              ),
              child: TextField(
                controller: _contentCtrl,
                maxLines: 8,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: DC.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Full content text',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
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
                      backgroundColor: const Color(0xFFF0F1F3),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_type == null || _status == null) return;
                      widget.onCreate(
                        _type!,
                        _status!,
                        _titleCtrl.text,
                        _authorCtrl.text,
                        _contentCtrl.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF263A84),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Create',
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
// DIALOG 4: VERIFY IDENTITY TO UPDATE CONTENT
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
                      'Verify Identity to Update Content',
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
                'You are about to update this content. Please\n'
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

// ══════════════════════════════════════════════════════════════════════════════
// COMPONENTS
// ══════════════════════════════════════════════════════════════════════════════
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

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});
  @override
  Widget build(BuildContext context) {
    final c =
        _typeColors[type] ?? [const Color(0xFFE0E7FF), const Color(0xFF4338CA)];
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
            type,
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _InputField({required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FF),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: DC.border),
    ),
    child: TextField(
      controller: controller,
      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: DC.primaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: DC.textSoft,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
  final ContentRecord contentRec;
  final bool shade;
  final VoidCallback onView, onEdit;
  const _TableRow({
    required this.contentRec,
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
    final r = widget.contentRec;
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
                r.id,
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
                r.author,
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
                r.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                r.type,
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
                r.timestamp,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: DC.textMid,
                ),
              ),
            ),
            Expanded(flex: 12, child: _StatusBadge(status: r.status)),
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
                    tooltip: 'Edit Content',
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
class _FilterSheet extends StatefulWidget {
  final String? currentStatus;
  final String? currentType;
  final void Function(String?, String?) onApply;
  final VoidCallback onClear;
  const _FilterSheet({
    required this.currentStatus,
    required this.currentType,
    required this.onApply,
    required this.onClear,
  });
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _status;
  String? _type;
  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    _type = widget.currentType;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Content',
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
              children: ['Published', 'Draft']
                  .map(
                    (s) => _ToggleChip(
                      label: s,
                      selected: _status == s,
                      onTap: () => setState(() => _status = _status == s ? null : s),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Text(
              'Type',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DC.textMid,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['Article', 'Notice', 'Carousel']
                  .map(
                    (t) => _ToggleChip(
                      label: t,
                      selected: _type == t,
                      onTap: () => setState(() => _type = _type == t ? null : t),
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
                    onPressed: () => widget.onApply(_status, _type),
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
                  label: 'Content ID',
                  selected: _field == 'id',
                  onTap: () => setState(() => _field = 'id'),
                ),
                _ToggleChip(
                  label: 'Author',
                  selected: _field == 'author',
                  onTap: () => setState(() => _field = 'author'),
                ),
                _ToggleChip(
                  label: 'Title',
                  selected: _field == 'title',
                  onTap: () => setState(() => _field = 'title'),
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
                    color: Colors.white,
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
