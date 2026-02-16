import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'global/top_bar.dart'; // Tiyaking tama ang path nito

class FileReportPage extends StatefulWidget {
  const FileReportPage({super.key});

  @override
  State<FileReportPage> createState() => _FileReportPageState();
}

class _FileReportPageState extends State<FileReportPage> {
  int? _selectedSeverity;
  final TextEditingController _confirmationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // List of name controllers for dynamic "Add Person" functionality
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    _confirmationController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPersonField() {
    setState(() {
      _nameControllers.add(TextEditingController());
    });
  }

  void _removePersonField(int index) {
    if (_nameControllers.length > 1) {
      setState(() {
        _nameControllers[index].dispose();
        _nameControllers.removeAt(index);
      });
    }
  }

  // --- VALIDATION LOGIC ---
  bool _validateInputs() {
    final names = _nameControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      _showErrorSnackBar("Please provide at least one name.");
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar("Please provide a description.");
      return false;
    }
    if (_selectedSeverity == null) {
      _showErrorSnackBar("Please select a severity level.");
      return false;
    }
    if (_locationController.text.trim().isEmpty) {
      _showErrorSnackBar("Please provide a location.");
      return false;
    }
    return true;
  }

  // --- LOGIC PARA SA SUBMIT SA SUPABASE ---
  Future<void> _submitReport() async {
    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final names = _nameControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // Insert to Supabase
      await Supabase.instance.client.from('reports').insert({
        'names': names,
        'description': _descriptionController.text.trim(),
        'severity_level': 'Level $_selectedSeverity',
        'location_text': _locationController.text.trim(),
        'status': 'Pending',
      });

      if (mounted) {
        Navigator.pop(context); // Close Loading Dialog
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close Loading Dialog
        _showErrorSnackBar("Error submitting report: $e");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- LOGIC PARA SA SUCCESS DIALOG ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close Success Dialog
        Navigator.of(context).pop(); // Go back to previous screen
      }
    });
  }

  // --- LOGIC PARA SA FINAL CONFIRMATION POP-UP ---
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
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
                        if (_confirmationController.text.toLowerCase() ==
                            "yes") {
                          Navigator.pop(
                            context,
                          ); // Close Confirmation immediately
                          _confirmationController.clear();
                          _submitReport(); // Proceed to submit
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
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

            // --- NAME SECTION WITH ADD PERSON BUTTON ON TOP ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel("Name/s:"),
                GestureDetector(
                  onTap: _addPersonField,
                  child: _buildAddPersonBtn(),
                ),
              ],
            ),

            // Dynamic Name Fields
            ..._nameControllers.asMap().entries.map((entry) {
              int index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Person ${index + 1}",
                        Icons.person_outline,
                        controller: entry.value,
                      ),
                    ),
                    if (_nameControllers.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removePersonField(index),
                      ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 10),

            _buildLabel("Description:"),
            _buildTextArea(
              "Provide detailed information about the situation, needs, and any relevant observations...",
              _descriptionController,
            ),

            const SizedBox(height: 20),

            _buildLabel("Vulnerability Level"),
            _buildSeverityOption(
              1,
              "Level 1: This level represents households struggling to meet basic needs.",
            ),
            _buildSeverityOption(
              2,
              "Level 2: This level represents households that can meet basic food needs but have no savings or security for emergencies.",
            ),
            _buildSeverityOption(
              3,
              "Level 3: This level represents households that can sustain their daily needs and cope with most challenges.",
            ),

            const SizedBox(height: 20),

            _buildLabel("Location"),
            _buildTextField(
              "Start typing address or landmark...",
              null,
              trailing: const Icon(
                Icons.location_on_outlined,
                color: Colors.red,
              ),
              controller: _locationController,
            ),

            const SizedBox(height: 20),

            _buildUploadButton(),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_validateInputs()) {
                    _showConfirmationDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3192),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData? icon, {
    Widget? trailing,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: _inputBoxDecoration(),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          suffixIcon: trailing,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea(String hint, TextEditingController controller) {
    return Container(
      height: 150,
      decoration: _inputBoxDecoration(),
      child: TextField(
        controller: controller,
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
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
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
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_outlined, color: Colors.grey),
          SizedBox(width: 10),
          Text(
            "Upload a photos or videos",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPersonBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add_alt_1, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            "Add Person",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}
