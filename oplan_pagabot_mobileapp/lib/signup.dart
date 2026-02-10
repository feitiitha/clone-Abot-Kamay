import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

// hello ako si carl santos

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fNameCtrl = TextEditingController();
  final TextEditingController _mNameCtrl = TextEditingController();
  final TextEditingController _lNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _idNumCtrl = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController(); 
  final List<TextEditingController> _otpControllers = List.generate(6, (i) => TextEditingController());
final List<FocusNode> _otpFocusNodes = List.generate(6, (i) => FocusNode());
  
  // MPIN Controllers for Validation
  final List<TextEditingController> _mpinControllers = List.generate(4, (i) => TextEditingController());
  final List<TextEditingController> _confirmMpinControllers = List.generate(4, (i) => TextEditingController());
  
  DateTime? _selectedDate;

  int _currentStep = 1;
  bool _noMiddleName = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  File? _selectedIDFile; 
  final ImagePicker _picker = ImagePicker();
  String _selectedSuffix = "N/A";
  String _selectedSex = "Select";
  String _selectedNationality = "Filipino";
  String _selectedIDType = "UMID";
  final Color primaryBlue = const Color(0xFF2E3192);
  final Color strokeColor = Colors.grey.shade300;

  bool get _hasMaxLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _passwordsMatch => _passwordController.text == _confirmPasswordController.text && _passwordController.text.isNotEmpty;
  bool _isLoading = false;
  XFile? _webSelfieFile;
  int _secondsRemaining = 120;
  Timer? _timer;

  
void _startTimer() {
  setState(() {
    _secondsRemaining = 120; // I-reset sa 2 mins
  });
  _timer?.cancel(); // Patayin ang lumang timer para hindi mag-overlap
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_secondsRemaining > 0) {
      setState(() {
        _secondsRemaining--;
      });
    } else {
      _timer?.cancel();
    }
  });
}



  Future<void> _pickIDImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedIDFile = File(image.path);
        
      });
    }
  }

  Future<void> _takeSelfie() async {
  try {
    // Ito ang magti-trigger ng browser popup para sa Camera Permission
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (image != null) {
      setState(() {
        _webSelfieFile = image; // I-save ang XFile
      });
    }
  } catch (e) {
    print("Camera Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Camera permission denied or not found.")),
    );
  }
}

void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating, 
    ),
  );
}

Future<void> _registerUser() async {
  // 1. VALIDATION CHECKS (Haharang kung blanko)
  if (_emailCtrl.text.trim().isEmpty || 
      _passwordController.text.trim().isEmpty ||
      _fNameCtrl.text.trim().isEmpty || 
      _lNameCtrl.text.trim().isEmpty ||
      _addressCtrl.text.trim().isEmpty ||
      _idNumCtrl.text.trim().isEmpty) {
    _showErrorSnackBar("Please fill in all required information.");
    return; // Dito hihinto ang code, hindi mag-o-OTP
  }

  final String mpin = _mpinControllers.map((e) => e.text).join();
  if (mpin.length < 4) {
    _showErrorSnackBar("MPIN must be 4 digits.");
    return;
  }

  if (!_agreedToTerms) {
    _showErrorSnackBar("You must agree to the Terms and Conditions.");
    return;
  }

  setState(() => _isLoading = true);
  
  try {
    // 2. SUPABASE SIGNUP
    final AuthResponse res = await Supabase.instance.client.auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passwordController.text.trim(),
      data: {
        'first_name': _fNameCtrl.text.trim(),
        'middle_name': _noMiddleName ? "N/A" : _mNameCtrl.text.trim(),
        'last_name': _lNameCtrl.text.trim(),
        'suffix': _selectedSuffix,
        'sex': _selectedSex,
        'nationality': _selectedNationality,
        'birthday': _dobCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'id_type': _selectedIDType,
        'id_number': _idNumCtrl.text.trim(),
        'mpin': mpin,
        'agreed_to_terms': _agreedToTerms,
        'registration_date': DateTime.now().toIso8601String(),
      },
    );

    // 3. SUCCESS TRANSITION
    if (res.user != null) {
      _startTimer(); // Dito lang aandar ang countdown
      setState(() => _currentStep = 5); // Dito lang lilipat ang screen
    }
  } catch (e) {
    _showErrorSnackBar("Error: ${e.toString()}");
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

 Future<void> _verifyOTP() async {
  // Pagsamahin ang input mula sa 6 na controllers
  String otpCode = _otpControllers.map((e) => e.text).join();

  // Guard clause: Siguraduhing 6 digits bago mag-proceed
  if (otpCode.length < 6) return;

  setState(() => _isLoading = true);
  try {
    // Tawagin ang Supabase para i-verify ang token
    final AuthResponse res = await Supabase.instance.client.auth.verifyOTP(
      email: _emailCtrl.text.trim(),
      token: otpCode,
      type: OtpType.signup, // Mahalaga ito para sa registration flow
    );

    if (res.session != null) {
      // TAMA ANG CODE: Stop ang timer at lipat sa Success Screen
      _timer?.cancel(); 
      setState(() => _currentStep = 6); // Lipat sa tagumpay!
    }
  } catch (e) {
    // MALI ANG CODE: Huwag mag-continue. Magpakita ng error.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Invalid Code: check your email."),
        backgroundColor: Colors.red,
      ),
    );
    

    // Opsyonal: Linisin ang boxes para makapag-type ulit
    for (var controller in _otpControllers) { controller.clear(); }
    _otpFocusNodes[0].requestFocus(); 
    
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _showTermsDialog() {
    final ScrollController scrollController = ScrollController();
    bool hasReachedBottom = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            scrollController.addListener(() {
              if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 10) {
                if (!hasReachedBottom) {
                  setDialogState(() => hasReachedBottom = true);
                }
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Center(child: Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.bold))),
              content: SizedBox(
                height: 400,
                width: double.maxFinite,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _termsSection("1. Use of Services", "You agree to use our Services only for lawful purposes and in accordance with these Terms. You may not: Use the Services in any way that violates applicable laws or regulations. Attempt to interfere with or disrupt our systems or networks. Use the Services to transmit harmful, fraudulent, or illegal content."),
                        _termsSection("2. Accounts", "If you create an account, you are responsible for maintaining the confidentiality of your login credentials and for all activities under your account. Notify us immediately if you believe your account has been compromised."),
                        _termsSection("3. Intellectual Property", "All content, trademarks, logos, and materials provided through our Services are owned by DSWD or our licensors. You may not copy, reproduce, or distribute our content without prior written permission."),
                        _termsSection("4. Third-Party Links", "Our Services may include links to third-party websites. We are not responsible for the content or practices of those sites. Access them at your own risk."),
                        _termsSection("5. Disclaimer", "Our Services are provided “as is” without warranties of any kind, express or implied. We do not guarantee that the Services will be error-free or uninterrupted."),
                        _termsSection("6. Limitation of Liability", "DSWD shall not be liable for any indirect, incidental, or consequential damages arising out of your use of our Services."),
                        _termsSection("7. Changes to Terms", "We may update these Terms from time to time. Continued use of our Services after changes means you accept the updated Terms."),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasReachedBottom ? Colors.green : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: hasReachedBottom 
                          ? () {
                              setState(() => _agreedToTerms = true);
                              Navigator.pop(context);
                            } 
                          : null,
                        child: const Text("Agree", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() => _agreedToTerms = false);
                          Navigator.pop(context);
                        },
                        child: const Text("Disagree", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _termsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fNameCtrl.dispose();
    _mNameCtrl.dispose();
    _lNameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _idNumCtrl.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobCtrl.dispose();
    _timer?.cancel();
    for (var controller in _mpinControllers) {
      controller.dispose();
    }
    for (var controller in _confirmMpinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Inalis ang back button kapag step 7 (Success Screen) na
      appBar: _currentStep == 7 ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: _isLoading ? null : () { // Disabled habang naglo-load
              if (_currentStep > 1) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 50.0, 
            vertical: _currentStep == 7 ? 0 : 10.0 
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (DSWD Logo at Title) - Step 1 to 4 lang
                if (_currentStep <= 4) ...[
                  Center(
                    child: Image.asset(
                      'assets/DSWD.png',
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Sign Up to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                ],

                // Extra space para sa PIN screens
                if (_currentStep == 5 || _currentStep == 6) const SizedBox(height: 80),

                // Step Indicator - Step 1 to 6 lang
                if (_currentStep <= 6) ...[
                  _buildStepIndicator(),
                  const SizedBox(height: 30),
                ],

                // Dito lalabas yung mga TextFields base sa current step
                _buildCurrentStepContent(),

                // Main Button (Next / Continue)
                if (_currentStep < 7) ...[
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () { // I-disable kung nagse-save na
                      if (_formKey.currentState!.validate()) {
                        
                        // Validation para sa Step 1 (Gender)
                        if (_currentStep == 1 && _selectedSex == "Select") {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select gender")));
                          return;
                        }

                        // Validation para sa Step 2 (ID Upload)
                        if (_currentStep == 2 && _selectedIDFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload your Government ID")));
                          return;
                        }

                        if (_currentStep == 3 && _webSelfieFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please take a selfie first")),);
                          return;
}

                        // Validation para sa Step 4 (Password & Terms)
                        if (_currentStep == 4) {
                          if (!_passwordsMatch) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                            return;
                          }
                          if (!_agreedToTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please agree to the terms")));
                            return;
                          }
                        }

                        if (_currentStep == 5) {
                        // Pinagsasama ang 6 na digits ng OTP
                            String otpCode = _otpControllers.map((e) => e.text).join();

                        if (otpCode.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter the complete 6-digit verification code"))
                          );
                          return; // Hindi magpapatuloy sa Step 6
                        }
        // Dito mo tatawagin ang verification function mo
        // Kapag verified na, tsaka lang mag setState(() => _currentStep = 6);
        _verifyOTP(); 
        return; 
      }
                        
                        // Validation para sa Step 6 (MPIN) at Supabase Submission
                        if (_currentStep == 6) {
                          String mpin = _mpinControllers.map((e) => e.text).join();
                          String confirmMpin = _confirmMpinControllers.map((e) => e.text).join();
                          
                          if (mpin.length < 4 || confirmMpin.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete the MPIN fields")));
                            return;
                          }
                          if (mpin != confirmMpin) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("MPINs do not match")));
                            return;
                          }

                          // TAWAG SA SUPABASE: Imbis na _currentStep++, ito ang gagamitin
                          _registerUser(); 
                          return; 
                        }

                        // Paglipat sa susunod na step (para sa step 1-5)
                        setState(() => _currentStep++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _currentStep >= 5 ? "Continue" : "Next",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      case 4: return _buildStep4();
      case 5: return _buildStep5();
      case 6: return _buildStep6();
      case 7: return _buildStep7();
      default: return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("First Name"),
        _buildTextField(_fNameCtrl, "Enter first name", Icons.person_outline,
            validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        _buildLabel("Middle Name"),
        _buildTextField(_mNameCtrl, "Enter middle name", Icons.person_outline,
            enabled: !_noMiddleName, validator: (v) {
          if (!_noMiddleName && v!.isEmpty) return "Required";
          return null;
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Checkbox(
              value: _noMiddleName,
              activeColor: primaryBlue,
              onChanged: (v) => setState(() => _noMiddleName = v!),
            ),
            const Text("I have no middle name",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        _buildLabel("Last Name"),
        _buildTextField(_lNameCtrl, "Enter last name", Icons.person_outline,
            validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Suffix"),
                  _buildDropdown(
                      Icons.badge_outlined,
                      [
                        "N/A", "Jr.", "Sr.", "I", "II", "III", "IV", "V", "VI",
                        "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV",
                        "XV", "XVI", "XVII", "XVIII", "XIX", "XX"
                      ],
                      _selectedSuffix,
                      (v) => setState(() => _selectedSuffix = v!)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Sex"),
                  _buildDropdown(
                      Icons.wc,
                      ["Select", "Male", "Female"],
                      _selectedSex,
                      (v) => setState(() => _selectedSex = v!)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
   _buildLabel("Birthday"),
GestureDetector(
  onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000), 
      firstDate: DateTime(1900),  
      lastDate: DateTime.now(), // Hahayaan silang makita hanggang 2026
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        // Format: MM/DD/YYYY
        _dobCtrl.text = "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
      });
      
      // I-trigger ang validation agad para makita nila kung "Must be 18" sila
      _formKey.currentState!.validate();
    }
  },
  child: AbsorbPointer(
    child: _buildTextField(
      _dobCtrl,
      "Select your birthdate",
      Icons.calendar_month_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) return "Required";

        // Logic para i-compute ang edad
        final birthDate = _selectedDate!;
        final today = DateTime.now();
        int age = today.year - birthDate.year;

        // I-adjust ang age kung hindi pa sumasapit ang birthday ngayong taon
        if (today.month < birthDate.month || 
           (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }

        if (age < 18) {
          return "Must be at least 18 years old";
        }
        return null;
      },
    ),
  ),
),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Email Address"),
        _buildTextField(_emailCtrl, "Enter email", Icons.email_outlined,
            validator: (v) => !v!.contains("@gmail.com")
                ? "Email must be @gmail.com"
                : null),
        const SizedBox(height: 16),
        _buildLabel("Home Address"),
        _buildTextField(_addressCtrl, "Enter home address", Icons.home_outlined, validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        _buildLabel("ID Number"),
        _buildTextField(_idNumCtrl, "Enter ID number", Icons.badge_outlined, validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        _buildLabel("Nationality"),
        _buildDropdown(Icons.flag_outlined, ["Filipino", "Foreign National"], _selectedNationality, (v) => setState(() => _selectedNationality = v!)),
        const SizedBox(height: 16),
        _buildLabel("Type of Government ID"),
        _buildDropdown(Icons.assignment_ind_outlined, ["UMID", "Passport", "Driver's License", "PhilSys (National ID)", "PRC ID", "Postal ID", "Voter's ID", "SSS ID", "Pag-IBIG ID", "PhilHealth ID", "TIN ID", "Senior Citizen ID", "PWD ID"], _selectedIDType, (v) => setState(() => _selectedIDType = v!)),
        const SizedBox(height: 25),
        GestureDetector(
          onTap: _pickIDImage,
          child: _buildUploadBox(_selectedIDFile == null ? "Upload a photo/s" : "ID Uploaded: ${_selectedIDFile!.path.split('/').last}"),
        ),
      ],
    );
  }

 Widget _buildStep3() {
  return Column(
    children: [
      const SizedBox(height: 20),
      Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: _webSelfieFile == null
            ? const Center(
                child: Text(
                  "Take a Selfie",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _webSelfieFile!.path, // Sa web, ang path ay blob URL
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
      const SizedBox(height: 30),
      Center(
        child: GestureDetector(
          onTap: _takeSelfie, // Pag-click dito, lalabas ang browser permission popup
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 1.5),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 35,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Password"),
        _buildPasswordField(_passwordController, "Enter Password", _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
        const SizedBox(height: 16),
        _buildLabel("Confirm Password"),
        _buildPasswordField(_confirmPasswordController, "Confirm Password", _obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Password Requirements:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              _buildRequirement("Maximum 8 characters", _hasMaxLength),
              _buildRequirement("At least one uppercase letter", _hasUppercase),
              _buildRequirement("At least one lowercase letter", _hasLowercase),
              _buildRequirement("At least one number", _hasNumber),
              _buildRequirement("At least one special characters", _hasSpecialChar),
              _buildRequirement("Passwords must match", _passwordsMatch),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: _agreedToTerms, 
              activeColor: primaryBlue, 
              onChanged: (v) {
                _showTermsDialog();
              }
            ),
            const Text("I agree to the terms and conditions", style: TextStyle(fontSize: 12)),
          ],
        )
      ],
    );
  }

Widget _buildStep5() {
  return Column(
    children: [
      const Text("OTP Verification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text("We've sent you the verification code on ${_emailCtrl.text}", 
          textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      const SizedBox(height: 40),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: List.generate(6, (i) => _buildOTPField(i))
      ),
      const SizedBox(height: 30),
      
      // DITO MO ILALAGAY YUNG DYNAMIC TIMER CODE:
      Text(
        _secondsRemaining > 0 
          ? "Re-send code in ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}"
          : "You can now resend the code",
        style: const TextStyle(color: Colors.grey),
      ),

      // Optional: Resend Button na lilitaw lang kapag 0 na ang timer
      if (_secondsRemaining == 0)
        TextButton(
          onPressed: () {
            _registerUser(); // Tatawagin ulit ang signup para mag-send ng bagong OTP
            _startTimer();   // I-re-reset ang countdown sa 2 mins
          },
          child: const Text("Resend Code", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
    ],
  );
}

Widget _buildOTPField(int index) {
  return SizedBox(
    width: 45,
    child: TextField(
      controller: _otpControllers[index],
      focusNode: _otpFocusNodes[index],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 1,
      // Para sa Web: Iwasan ang "Select File" issue sa pamamagitan ng pag-limit sa digits
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
      decoration: InputDecoration(
        counterText: "",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), 
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), 
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
      ),
      onChanged: (value) {
        // 1. Move focus forward
        if (value.isNotEmpty && index < 5) {
          _otpFocusNodes[index + 1].requestFocus();
        } 
        // 2. Move focus backward (backspace logic)
        else if (value.isEmpty && index > 0) {
          _otpFocusNodes[index - 1].requestFocus();
        }
        
        // 3. AUTO-ALIGN: Pag puno na, i-verify sa Supabase
        if (_otpControllers.every((e) => e.text.length == 1)) {
          _verifyOTP();
        }
      },
    ),
  );
}
  Widget _buildStep6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text("Create MPIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const Center(child: Text("Create a unique PIN to keep your account safe", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey))),
        const SizedBox(height: 30),
        _buildLabel("MPIN"),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (i) => _buildMpinBox(_mpinControllers[i], i, _mpinControllers))),
        const SizedBox(height: 30),
        _buildLabel("Confirm MPIN"),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (i) => _buildMpinBox(_confirmMpinControllers[i], i, _confirmMpinControllers))),
      ],
    );
  }

  // MODIFIED: I-center ang icons at i-fix ang layout gap
  Widget _buildStep7() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8, // Kumukuha ng sapat na height para sa centering
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // I-center ang lahat sa loob ng Column
        children: [
          Center(
            child: Image.asset(
              'assets/VerifiedCheck.png',
              height: 180, 
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your account has been created successfully.',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'You will receive a notification once account is verified',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 50), // FIXED GAP: Saktong layo lang ang button sa text
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMpinBox(TextEditingController ctrl, int index, List<TextEditingController> list) {
    return Container(
      width: 45, height: 50,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor)),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  Widget _buildPlainUploadBox(String text, {double height = 60}) {
    return Container(
      height: height, width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16))),
    );
  }

  Widget _buildUploadBox(String text, {double height = 60}) {
    return Container(
      height: height, width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Stack( 
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.centerLeft, child: Icon(Icons.file_upload_outlined, color: primaryBlue, size: 28)),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool enabled = true, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController ctrl, String hint, bool obs, VoidCallback toggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: ctrl, obscureText: obs, 
        onChanged: (_) => setState(() {}), 
        decoration: InputDecoration(
          hintText: hint, prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(icon: Icon(obs ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: toggle),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor)),
        ),
      ),
    );
  }

  Widget _buildDropdown(IconData icon, List<String> items, String current, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: current, isExpanded: true, 
                menuMaxHeight: 250, 
                items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: onChange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinField() {
    return Container(
      width: 45, height: 50,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor)),
      child: const TextField(textAlign: TextAlign.center, maxLength: 1, keyboardType: TextInputType.number, decoration: InputDecoration(counterText: "", border: InputBorder.none)),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    Color color = _passwordController.text.isEmpty ? Colors.black54 : (isMet ? Colors.green : Colors.red);
    return Row(children: [Icon(isMet ? Icons.check_circle : Icons.circle, size: 14, color: color), const SizedBox(width: 8), Text(text, style: TextStyle(color: color, fontSize: 12))]);
  }

  Widget _buildStepIndicator() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("$_currentStep of 6", style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: List.generate(6, (index) => Expanded(child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: index < _currentStep ? Colors.red : Colors.grey.shade300, borderRadius: BorderRadius.circular(5)))))),
    ]);
  }
}