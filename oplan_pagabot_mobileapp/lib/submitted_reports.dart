import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'global/top_bar.dart';
import 'report_details.dart';

class SubmittedReportsPage extends StatelessWidget {
  const SubmittedReportsPage({super.key});

  // Function para sa About Popup
  void _showAboutPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "About",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  "This app enables citizens to report Families and Individuals in Street Situations (FISS) to the DSWD.",
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                    ),
                    child: const Text(
                      "I Understand",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tugma sa 'status' column sa iyong DB
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF27AE60);
      case 'declined':
        return const Color(0xFFC0392B);
      case 'pending':
      default:
        return const Color(0xFFF39C12);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- SUPABASE STREAM ALIGNED TO YOUR SCHEMA ---
    // Ginagamit ang 'id' bilang primary key base sa iyong SQL
    final Stream<List<Map<String, dynamic>>> _reportsStream = Supabase
        .instance
        .client
        .from('reports')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(onAboutTap: () => _showAboutPopup(context)),
      body: Column(
        children: [
          // --- HEADER SECTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Row(
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
                      "Submitted Reports",
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
          ),

          // --- REALTIME REPORTS LIST ---
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _reportsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports = snapshot.data!;

                if (reports.isEmpty) {
                  return const Center(
                    child: Text("No reports found. Check your database."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final item = reports[index];

                    bool showHeader = (index == 0);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) ...[
                          const SizedBox(height: 20),
                          _buildSectionTitle("Recent Reports"),
                        ],
                        _buildReportCard(
                          context: context,
                          // Tinitiyak na tama ang column names base sa image_6bfc58.png
                          title:
                              item['description'] ?? "No Description Provided",
                          location: item['location_text'] ?? "Unknown Location",
                          date: item['created_at'] != null
                              ? DateTime.parse(
                                  item['created_at'],
                                ).toLocal().toString().split(' ')[0]
                              : "No Date",
                          status: item['status'] ?? "Pending",
                          statusColor: _getStatusColor(
                            item['status'] ?? "Pending",
                          ),
                          rawData: item,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required String title,
    required String location,
    required String date,
    required String status,
    required Color statusColor,
    required Map<String, dynamic> rawData,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsPage(
              // Ipinapasa ang data sa ReportDetailsPage
              names:
                  (rawData['names'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              description: title,
              severity: rawData['severity_level'] ?? "Unknown",
              location: location,
              date: date,
              status: status,
              statusColor: statusColor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,flutte
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
