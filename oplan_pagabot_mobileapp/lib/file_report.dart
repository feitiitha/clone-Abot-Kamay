import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'global/top_bar.dart';

class FileReportPage extends StatefulWidget {
  const FileReportPage({super.key});

  @override
  State<FileReportPage> createState() => _FileReportPageState();
}

class _FileReportPageState extends State<FileReportPage> {
  int? _selectedSeverity;
  final TextEditingController _numberOfPeopleController =
      TextEditingController(text: '1');

  final TextEditingController _confirmationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  int _descriptionCharCount = 0;
  static const int _maxDescriptionChars = 150;

  // Location loading state
  bool _isGettingLocation = false;

  // Image upload state
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _selectedImageBytes = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _descriptionCharCount = _descriptionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  // --- PICK IMAGES ---
  Future<void> _pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked == null || picked.isEmpty) return;

    final availableSlots = (5 - _selectedImages.length).clamp(0, 5);
    if (availableSlots <= 0) {
      _showErrorSnackBar('You can upload up to 5 images only.');
      return;
    }

    final pickForAdd = picked.take(availableSlots).toList();
    final bytesList = await Future.wait(pickForAdd.map((image) => image.readAsBytes()));

    setState(() {
      _selectedImages.addAll(pickForAdd);
      _selectedImageBytes.addAll(bytesList);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _selectedImageBytes.removeAt(index);
    });
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return; // Prevent multiple simultaneous requests

    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Use Geolocator permission API for unified behavior across platforms
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permission is required to auto-fill address');
        return;
      }

      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showErrorSnackBar('Please enable location services in your device settings');
          return;
        }
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String address = await _lookupAddressFromPosition(position);

      if (address.isNotEmpty) {
        setState(() {
          _locationController.text = address;
        });
        _showSuccessSnackBar('Location detected successfully');
      } else {
        _showErrorSnackBar('Could not determine address from your location');
      }
    } catch (e) {
      String errorMessage = 'Failed to get location: ${e.toString()}';
      if (e.toString().toLowerCase().contains('timeout')) {
        errorMessage = 'Location request timed out. Please try again';
      } else if (e.toString().toLowerCase().contains('permission')) {
        errorMessage = 'Location permission denied';
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<String> _lookupAddressFromPosition(Position position) async {
    if (kIsWeb) {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}');

      final response = await http.get(url, headers: {
        'User-Agent': 'OplanPagabot/1.0',
        'Accept-Language': 'en'
      });

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body);
        if (map != null && map['display_name'] != null) {
          return map['display_name'].toString();
        }
      }
      return '';
    }

    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final parts = <String>[];

      if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
      if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) parts.add(place.administrativeArea!);
      if (place.country != null && place.country!.isNotEmpty) parts.add(place.country!);

      return parts.join(', ');
    }

    return '';
  }

  // --- VALIDATION ---
  bool _validateInputs() {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar("Please provide a title.");
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar("Please provide a description.");
      return false;
    }
    if (_selectedSeverity == null) {
      _showErrorSnackBar("Please select a vulnerability level.");
      return false;
    }
    if (_locationController.text.trim().isEmpty) {
      _showErrorSnackBar("Please provide a location.");
      return false;
    }
    final peopleText = _numberOfPeopleController.text.trim();
    if (peopleText.isEmpty ||
        int.tryParse(peopleText) == null ||
        int.parse(peopleText) < 1) {
      _showErrorSnackBar("Please enter a valid number of people.");
      return false;
    }
    return true;
  }

  // --- SUBMIT TO SUPABASE ---
  Future<void> _submitReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) throw "User not logged in.";

      // Upload images to Supabase Storage
      final List<String> imageUrls = [];
      for (final image in _selectedImages) {
        final bytes = await image.readAsBytes();
        final fileName =
            'reports/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        await Supabase.instance.client.storage
            .from('report-images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                  contentType: 'image/jpeg', upsert: true),
            );
        final url = Supabase.instance.client.storage
            .from('report-images')
            .getPublicUrl(fileName);
        imageUrls.add(url);
      }

      await Supabase.instance.client.from('reports').insert({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'severity_level': 'Level $_selectedSeverity',
        'number_of_people': int.parse(_numberOfPeopleController.text.trim()),
        'location_text': _locationController.text.trim(),
        'image_urls': imageUrls,
        'status': 'Pending',
        'email_address': user.email,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar("Error submitting report: $e");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // --- SUCCESS DIALOG ---
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
                      vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5)),
                    ],
                  ),
                  child: const Text(
                    "The report has been successfully submitted.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
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
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    });
  }

  // --- CONFIRMATION DIALOG ---
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Final Confirmation",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "You are about to submit the report. Please ensure all details are correct.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  const Text('Type "yes" in the box below to proceed.',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmationController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
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
                          Navigator.pop(context);
                          _confirmationController.clear();
                          _submitReport();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Confirm",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "Report A Homeless Individual",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Title:"),
                  _buildTextField(
                    "Insert Description",
                    Icons.folder_open_outlined,
                    controller: _titleController,
                  ),

                  const SizedBox(height: 16),

                  _buildLabel("Description:"),
                  _buildTextAreaWithCounter(
                    "Provide detailed information about the situation, needs, and any relevant observations...",
                    _descriptionController,
                  ),

                  const SizedBox(height: 16),

                  _buildLabel("Vulnerability Level"),
                  _buildSeverityOption(1,
                      "Level 1: This level represents households struggling to meet basic needs."),
                  _buildSeverityOption(2,
                      "Level 2: This level represents households that can meet basic food needs but have no savings or security for emergencies."),
                  _buildSeverityOption(3,
                      "Level 3: This level represents households that can sustain their daily needs and cope with most challenges."),

                  const SizedBox(height: 16),

                  _buildLabel("Number of People"),
                  _buildNumberOfPeopleField(),

                  const SizedBox(height: 16),

                  _buildLabel("Location"),
                  _buildTextField(
                    "Start typing address or landmark...",
                    null,
                    trailing: GestureDetector(
                      onTap: _getCurrentLocation,
                      child: _isGettingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            )
                          : const Icon(Icons.location_on_outlined,
                              color: Colors.red),
                    ),
                    controller: _locationController,
                  ),

                  const SizedBox(height: 16),

                  _buildLabel("Photos / Videos"),
                  _buildUploadSection(),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_validateInputs()) _showConfirmationDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3192),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── WIDGET BUILDERS ─────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData? icon, {
    Widget? trailing,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: _inputBoxDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.grey) : null,
          suffixIcon: trailing,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTextAreaWithCounter(
      String hint, TextEditingController controller) {
    return Container(
      height: 150,
      decoration: _inputBoxDecoration(),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            maxLength: _maxDescriptionChars,
            buildCounter: (_,
                    {required currentLength,
                    required isFocused,
                    maxLength}) =>
                null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Icon(Icons.folder_open_outlined,
                    color: Colors.grey),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.fromLTRB(16, 14, 16, 30),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 12,
            child: Text(
              "$_descriptionCharCount/$_maxDescriptionChars",
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityOption(int value, String text) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSeverity = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: _inputBoxDecoration(),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedSeverity,
              onChanged: (v) =>
                  setState(() => _selectedSeverity = v),
              activeColor: Colors.blue,
            ),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  /// Number input field with numeric keyboard and validation
  Widget _buildNumberOfPeopleField() {
    return Container(
      decoration: _inputBoxDecoration(),
      child: TextField(
        controller: _numberOfPeopleController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          hintText: "Enter number of people",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.people_outline, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// Functional image upload with thumbnail previews
  Widget _buildUploadSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_outlined, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  _selectedImages.isEmpty
                      ? "Upload photos or videos"
                      : "Add more (${_selectedImages.length}/5 selected)",
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          ),
        ),

        // Thumbnail grid with tap-to-expand
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImageBytes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImageDialog(index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _selectedImageBytes[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  void _showImageDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black,
                child: Image.memory(
                  _selectedImageBytes[index],
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}