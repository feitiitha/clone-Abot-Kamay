import 'package:flutter/material.dart';
import 'global/top_bar.dart'; // Siguraduhing tama ang path ng TopBar mo

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(), // Gamit ang iyong custom top bar
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // --- HEADER SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // WHITE BACK BUTTON (Updated from Black to White)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white, // Ginawang White
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300), // Added border para kita sa white bg
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, 
                      color: Colors.black, size: 20),
                  ),
                ),
                const Expanded(
                  child: Text(
                    "Notification",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Balanse para sa back button
              ],
            ),
          ),

          // --- NOTIFICATION LIST ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle("Today"),
                _buildNotificationCard(
                  context: context, // Pasa ang context para sa navigation
                  title: "Account Verified Successfully",
                  subtitle: "Your identity has been confirmed...",
                  fullDetails: "Your identity has been confirmed. You now have full access to all features and increased account security.",
                ),
                const SizedBox(height: 25),
                _buildSectionTitle("27 Jan"),
                _buildNotificationCard(
                  context: context,
                  title: "Report Status Updated",
                  subtitle: "Your report has been verified and is now...",
                  fullDetails: "Your report regarding the street situation has been verified by the DSWD field office and is now being processed for immediate action.",
                ),
                _buildNotificationCard(
                  context: context,
                  title: "Report Status Updated",
                  subtitle: "Your report has been verified and is now...",
                  fullDetails: "Update: A social worker has been assigned to the case you reported. Thank you for your active participation in the community.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required String title, 
    required String subtitle,
    required String fullDetails,
  }) {
    return GestureDetector(
      onTap: () {
        // NAVIGATE TO DETAILS
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailsPage(
              title: title,
              details: fullDetails,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8), // Light grey background
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEW NOTIFICATION DETAILS PAGE ---
class NotificationDetailsPage extends StatelessWidget {
  final String title;
  final String details;

  const NotificationDetailsPage({
    super.key, 
    required this.title, 
    required this.details
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                  ),
                ),
                const Expanded(
                  child: Text(
                    "Notification Details",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    details,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
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