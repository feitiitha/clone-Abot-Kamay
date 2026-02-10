import 'package:flutter/material.dart';
import 'global/top_bar.dart'; // Siguraduhing naka-import ito para gumana ang Top Bar

class FileReportPage extends StatefulWidget {
  const FileReportPage({super.key});

  @override
  State<FileReportPage> createState() => _FileReportPageState();
}

class _FileReportPageState extends State<FileReportPage> {
  int? _selectedSeverity;
  final TextEditingController _confirmationController = TextEditingController();

  // --- LOGIC PARA SA SUCCESS DIALOG ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent, // Para makita pa rin ang background
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 100, // Sakto sa ibaba ng GlobalAppBar
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                    ],
                  ),
                  child: const Text(
                    "The report has been successfully submitted.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    // Kusa itong mawawala pagkalipas ng 3 segundo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  // --- LOGIC PARA SA FINAL CONFIRMATION POP-UP ---
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Final Confirmation",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "You are about to submit the report. Please ensure all details are correct.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Type \"yes\" in the box below to proceed.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmationController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_confirmationController.text.toLowerCase() == "yes") {
                        Navigator.pop(context); // Isara ang confirmation
                        _confirmationController.clear();
                        _showSuccessDialog(); // Ipakita ang success message
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28A745), // Green color base sa pic
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: const GlobalAppBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                ),
                const SizedBox(width: 20),
                const Flexible(
                  child: Text(
                    "Report A Homeless Individual",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            _buildLabel("Name/s:"),
            _buildTextField("First Person", Icons.folder_open_outlined,
                trailing: _buildAddPersonBtn()),

            const SizedBox(height: 20),

            _buildLabel("Description:"),
            _buildTextArea("Provide detailed information about the situation, needs, and any relevant observations..."),

            const SizedBox(height: 20),

            _buildLabel("Severity Level"),
            _buildSeverityOption(1, "Level 1: This level represents households struggling to meet basic needs."),
            _buildSeverityOption(2, "Level 2: This level represents households that can meet basic food needs but have no savings or security for emergencies."),
            _buildSeverityOption(3, "Level 3: This level represents households that can sustain their daily needs and cope with most challenges."),

            const SizedBox(height: 20),

            _buildLabel("Location"),
            _buildTextField("", null,
                trailing: const Icon(Icons.location_on_outlined, color: Colors.red)),

            const SizedBox(height: 20),

            _buildUploadButton(),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _showConfirmationDialog, // Dito tatawagin ang pop-up
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3192),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Submit",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Retained original) ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(String hint, IconData? icon, {Widget? trailing}) {
    return Container(
      decoration: _inputBoxDecoration(),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          suffixIcon: trailing,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildTextArea(String hint) {
    return Container(
      height: 150,
      decoration: _inputBoxDecoration(),
      child: TextField(
        maxLines: 5,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 80),
            child: Icon(Icons.folder_open_outlined, color: Colors.grey),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSeverityOption(int value, String text) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSeverity = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: _inputBoxDecoration(),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedSeverity,
              onChanged: (v) => setState(() => _selectedSeverity = v),
              activeColor: Colors.blue,
            ),
            Expanded(
                child: Text(text,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black87))),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_outlined, color: Colors.grey),
          SizedBox(width: 10),
          Text("Upload a photos or videos",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAddPersonBtn() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.grey[600], borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add_alt_1, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text("Add Person",
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}