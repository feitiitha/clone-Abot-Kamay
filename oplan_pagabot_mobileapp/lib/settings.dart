import 'package:flutter/material.dart';
import 'global/top_bar.dart'; 
import 'main.dart'; 

// --- 1. SETTINGS PAGE CLASS ---
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Confirm Logout", 
            textAlign: TextAlign.center, 
            style: TextStyle(fontWeight: FontWeight.bold)
          ),
          content: const Text("Are you sure you want to log out of your account?", textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.spaceEvenly, 
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFFFD1D1)], 
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                      ),
                      const Expanded(child: Text("Settings", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 40), 
                    ],
                  ),
                  const SizedBox(height: 60),
                  
                  // --- TERMS & CONDITION BUTTON ---
                  GestureDetector(
                    onTap: () {
                      // Lilipat sa class na nasa ibaba lang din
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsAndConditionsPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: const Center(
                        child: Text("Terms & Condition", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- LOGOUT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutConfirmation(context), 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

// --- 2. TERMS AND CONDITIONS PAGE CLASS (Nasa iisang file na sila) ---
class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                ),
                const Expanded(child: Text("Terms & Conditions", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("1. Use of Services", "You agree to use our Services only for lawful purposes and in accordance with these Terms. You may not use the Services in any way that violates applicable laws or regulations."),
                  _buildSection("2. Accounts", "If you create an account, you are responsible for maintaining the confidentiality of your login credentials and for all activities under your account."),
                  _buildSection("3. Intellectual Property", "All content, trademarks, logos, and materials provided through our Services are owned by DSWD or our licensors."),
                  _buildSection("4. Third-Party Links", "Our Services may include links to third-party websites. We are not responsible for the content or practices of those sites."),
                  _buildSection("5. Disclaimer", "Our Services are provided \"as is\" without warranties of any kind, express or implied. We do not guarantee error-free services."),
                  _buildSection("6. Limitation of Liability", "To the fullest extent permitted by law, DSWD shall not be liable for any indirect, incidental, or consequential damages."),
                  _buildSection("7. Changes to Terms", "We may update these Terms from time to time. Continued use of our Services means you accept the updated Terms."),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black.withOpacity(0.8)), textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}