import 'package:flutter/material.dart';
import 'global/top_bar.dart';

class ReportDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String severity;
  final String location;
  final String subLocation;
  final String date;
  final String status;
  final Color statusColor;
  final int numberOfPeople;
  final List<String> imageUrls;
  final String adminNote;

  const ReportDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.severity,
    required this.location,
    this.subLocation = '',
    required this.date,
    required this.status,
    required this.statusColor,
    this.numberOfPeople = 1,
    this.imageUrls = const [],
    this.adminNote = '',
  });

  // Timeline step model
  List<_TimelineStep> get _timelineSteps => [
        _TimelineStep(
          time: date,
          label: "Report Submitted",
          description: "Your report was submitted",
          isCompleted: true,
        ),
        _TimelineStep(
          time: '',
          label: "Pending",
          description: "We received your report. Our team is now reviewing the details.",
          isCompleted: status != 'Pending',
        ),
        _TimelineStep(
          time: '',
          label: "Validated",
          description: "Report confirmed. We are now working on a fix for this issue.",
          isCompleted: status == 'Validated' || status == 'Completed',
        ),
        _TimelineStep(
          time: '',
          label: "Completed",
          description: "The issue is fixed. This report is now officially closed.",
          isCompleted: status == 'Completed',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(),
      backgroundColor: const Color(0xFFF0F2F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Report Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),

            const SizedBox(height: 24),

            // --- TITLE + STATUS BADGE ROW ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- TIMELINE ---
            _buildTimeline(),

            const SizedBox(height: 28),

            // --- SITUATION DETAILS ---
            _buildSectionLabel("Situation Details"),
            const SizedBox(height: 10),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardLabel("Description"),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _buildCardLabel("Number of People"),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 20, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        "$numberOfPeople",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- LOCATION ---
            _buildSectionLabel("Location"),
            const SizedBox(height: 10),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.black87, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (subLocation.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subLocation,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: open map
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3192),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "View on map",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- MEDIA ---
            if (imageUrls.isNotEmpty) ...[
              _buildSectionLabel("Media"),
              const SizedBox(height: 10),
              _buildCard(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: imageUrls.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        width: 140,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 140,
                          height: 110,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- ADMIN NOTE ---
            _buildSectionLabel("Admin Note"),
            const SizedBox(height: 10),
            _buildCard(
              child: Text(
                adminNote.isNotEmpty
                    ? adminNote
                    : "No admin note yet.",
                style: TextStyle(
                  fontSize: 14,
                  color: adminNote.isNotEmpty
                      ? Colors.black54
                      : Colors.grey,
                  height: 1.5,
                  fontStyle: adminNote.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── TIMELINE ────────────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    final steps = _timelineSteps;
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time column
              SizedBox(
                width: 60,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    step.time,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Circle + line
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: step.isCompleted
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: step.isCompleted
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey.shade300,
                        margin:
                            const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              // Label + description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCardLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── TIMELINE STEP MODEL ─────────────────────────────────────────────────────

class _TimelineStep {
  final String time;
  final String label;
  final String description;
  final bool isCompleted;

  const _TimelineStep({
    required this.time,
    required this.label,
    required this.description,
    required this.isCompleted,
  });
}