import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'global/top_bar.dart'; 
import 'report_details.dart';

class SubmittedReportsPage extends StatefulWidget {
  const SubmittedReportsPage({super.key});

  @override
  State<SubmittedReportsPage> createState() => _SubmittedReportsPageState();
}

class _SubmittedReportsPageState extends State<SubmittedReportsPage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _fetchReports();
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return [];

    final response = await Supabase.instance.client
        .from('reports')
        .select()
        .eq('email_address', user.email!)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        "January", "February", "March", "April", "May", "June", 
        "July", "August", "September", "October", "November", "December"
      ];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (_) {
      return isoDate;
    }
  }

  // Function para sa About Popup (Same logic sa Home)
  void _showAboutPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("About", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71)),
                    child: const Text("I Understand", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- CONNECTED TOP BAR ---
      appBar: GlobalAppBar(
        onAboutTap: () => _showAboutPopup(context),
      ),
      
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFFD1D1)], 
          ),
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text("Submitted Reports", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 40), 
                ],
              ),
            ),

            // --- LIST ---
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error fetching reports: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No reports submitted yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final reports = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      final status = report['status']?.toString() ?? 'Pending';
                      
                      Color statusColor = Colors.orange;
                      if (status.toLowerCase() == 'approved') {
                        statusColor = Colors.green.shade600;
                      } else if (status.toLowerCase() == 'declined') {
                        statusColor = Colors.red.shade700;
                      }

                      // We extract the first name for the list preview from the names list
                      String titleName = "Unknown Name";
                      if (report['names'] != null && report['names'] is List && (report['names'] as List).isNotEmpty) {
                        titleName = (report['names'] as List).first.toString();
                      } else if (report['names'] is String) {
                        titleName = report['names'].toString();
                      }

                      return _buildReportCard(
                        context: context,
                        report: report,
                        title: titleName,
                        location: report['location_text']?.toString() ?? 'Unknown Location',
                        date: _formatDate(report['created_at']),
                        status: status,
                        statusColor: statusColor,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required Map<String, dynamic> report,
    required String title,
    required String location,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsPage(
              title: report['title']?.toString() ?? 'Untitled Report',
              description: report['description']?.toString() ?? 'No description',
              severity: report['severity_level']?.toString() ?? 'Unknown Level',
              location: report['location_text']?.toString() ?? 'Unknown Location',
              date: date,
              status: status,
              statusColor: statusColor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(location, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}