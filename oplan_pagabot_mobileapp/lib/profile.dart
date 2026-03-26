import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'global/top_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('email', user.email!)
          .single();

      setState(() {
        _userData = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const GlobalAppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black, size: 20),
                  ),
                ),
                Expanded(
                  child: const Text(
                    "Personal Information",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),

            const SizedBox(height: 30),

            // --- PROFILE PICTURE ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: const Color(0xFFFFB3B3),
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.person,
                              size: 65, color: Colors.white)
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4, bottom: 4),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.black, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- NAME & EMAIL ---
            Center(
              child: Text(
                _userData?['first_name'] != null && _userData?['last_name'] != null
                    ? '${_userData!['first_name']} ${_userData!['last_name']}'
                    : 'User Name',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                _userData?['email'] ?? 'user@example.com',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 28),

            // --- ACCOUNT INFORMATION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Account Information",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: navigate to edit page
                  },
                  child: Row(
                    children: [
                      Text(
                        "Edit Details",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit_outlined,
                          size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 4),

            _buildInfoRow("Full Name",
                "${_userData?['first_name'] ?? ''} ${_userData?['middle_name'] ?? ''} ${_userData?['last_name'] ?? ''}".trim()),
            _buildInfoRow("Suffix", _userData?['suffix'] ?? 'N/A'),
            _buildInfoRow("Sex", _userData?['sex'] ?? 'Not specified'),
            _buildInfoRow("Date of Birth", _userData?['date_of_birth'] ?? 'Not specified'),
            _buildInfoRow("Email Address", _userData?['email'] ?? 'Not specified'),
            _buildInfoRow("Current Address",
                "${_userData?['house_number'] ?? ''} ${_userData?['street'] ?? ''} ${_userData?['barangay'] ?? ''}\n${_userData?['city'] ?? ''} ${_userData?['province'] ?? ''} ${_userData?['zip_code'] ?? ''}".trim()),

            const SizedBox(height: 28),

            // --- ACCOUNT SETTINGS ---
            const Text(
              "Account Settings",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: navigate to change password
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3192),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Change Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}