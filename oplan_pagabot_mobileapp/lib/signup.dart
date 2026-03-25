import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'address_data.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fNameCtrl = TextEditingController();
  final TextEditingController _mNameCtrl = TextEditingController();
  final TextEditingController _lNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _houseCtrl = TextEditingController();
  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _zipCtrl = TextEditingController();
  final TextEditingController _idNumCtrl = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();

  final List<TextEditingController> _mpinControllers =
      List.generate(4, (i) => TextEditingController());
  final List<TextEditingController> _confirmMpinControllers =
      List.generate(4, (i) => TextEditingController());

  final List<TextEditingController> _otpControllers =
      List.generate(6, (i) => TextEditingController());
  int _otpTimer = 120;
  Timer? _otpTimerObj;

  DateTime? _selectedDate;
  int _currentStep = 1;
  bool _noMiddleName = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  File? _selectedIDFile;
  File? _selectedSelfieFile;
  final ImagePicker _picker = ImagePicker();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;

  void _setStep(int step) {
    if (_currentStep == 4 && step != 4) {
      _cameraController?.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
      _isInitializingCamera = false;
    }
    setState(() {
      _currentStep = step;
    });
  }

  void _startOtpTimer() {
    setState(() => _otpTimer = 120);
    _otpTimerObj?.cancel();
    _otpTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimer > 0) {
        setState(() => _otpTimer--);
      } else {
        _otpTimerObj?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeCamera() async {
    setState(() => _isInitializingCamera = true);
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Camera config failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isInitializingCamera = false);
      }
    }
  }

  String _selectedSuffix = "Select";
  String _selectedSex = "Select";
  String _selectedCitizenship = "Select your citizenship";
  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedCity;
  String _selectedBarangay = "Select your barangay";
  String _selectedIDType = "Choose valid ID to upload";

  final Color primaryBlue = const Color(0xFF2E3192);
  final Color strokeColor = Colors.grey.shade300;

  final List<String> _citizenships = ["Select your citizenship", "Filipino", "Dual Citizen", "Foreign National"];
  List<String> _barangays = ["Select your barangay"]; 
  final List<String> _idTypes = ["Choose valid ID to upload", "UMID", "Passport", "Driver's License", "PhilSys (National ID)", "PRC ID", "Postal ID", "Voter's ID", "SSS ID", "Pag-IBIG ID", "PhilHealth ID", "TIN ID", "Senior Citizen ID", "PWD ID"];

  bool get _hasMaxLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _passwordsMatch => _passwordController.text == _confirmPasswordController.text && _passwordController.text.isNotEmpty;

  Future<void> _registerUser() async {
    setState(() => _isLoading = true);

    try {
      final UserResponse res = await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      final user = res.user;

      if (user == null) {
        throw Exception("Signup failed or session expired.");
      }

      String finalMpin = _mpinControllers.map((e) => e.text).join();

      String formattedDate = _selectedDate != null 
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : _dobCtrl.text;

      String region = (_selectedRegion == null || _selectedRegion!.contains("Select")) ? "" : _selectedRegion!;
      String province = (_selectedProvince == null || _selectedProvince!.contains("Select")) ? "" : _selectedProvince!;
      String city = (_selectedCity == null || _selectedCity!.contains("Select")) ? "" : _selectedCity!;
      String suffix = (_selectedSuffix == "Select") ? "" : _selectedSuffix;

      await supabase.from('users').insert({
        'first_name': _fNameCtrl.text.trim(),
        'middle_name': _noMiddleName ? "" : _mNameCtrl.text.trim(),
        'last_name': _lNameCtrl.text.trim(),
        'suffix': suffix,
        'sex': _selectedSex,
        'birthday': formattedDate,
        'email_address': _emailCtrl.text.trim(),
        'house_no': _houseCtrl.text.trim(),
        'street_name': _streetCtrl.text.trim(),
        'city': city,
        'province': province,
        'region': region,
        'postal_code': _zipCtrl.text.trim(),
        'id_number': _idNumCtrl.text.trim(),
        'citizenship': _selectedCitizenship,
        'government_id': _selectedIDType,
        'password': _passwordController.text.trim(),
        'mpin': finalMpin,
      });

      setState(() {
        _currentStep = 8;
        _isLoading = false;
      });

    } on AuthException catch (e) {
      setState(() => _isLoading = false);

      String errorMsg = e.message;

      if (errorMsg.contains("Password")) {
        errorMsg = "The password is too weak.";
      }

      if (errorMsg.contains("already")) {
        errorMsg = "The email is already registered.";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMsg)));

    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _takeSelfie() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile file = await _cameraController!.takePicture();
        setState(() {
          _selectedSelfieFile = File(file.path);
        });
      } catch (e) {
        debugPrint("Error taking selfie: $e");
      }
    }
  }

  Future<void> _pickIDImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedIDFile = File(image.path);
      });
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
    _otpTimerObj?.cancel();
    _cameraController?.dispose();
    _fNameCtrl.dispose();
    _mNameCtrl.dispose();
    _lNameCtrl.dispose();
    _emailCtrl.dispose();
    _houseCtrl.dispose();
    _streetCtrl.dispose();
    _zipCtrl.dispose();
    _idNumCtrl.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobCtrl.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var controller in _mpinControllers) {
      controller.dispose();
    }
    for (var controller in _confirmMpinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentStep == 8 ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () {
              if (_currentStep > 1) {
                _setStep(_currentStep - 1);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 50.0, 
                vertical: _currentStep == 8 ? 0 : 10.0
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if ((_currentStep <= 4 || _currentStep == 6) && _currentStep != 2) ...[
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

                    if (_currentStep == 6 || _currentStep == 7 || _currentStep == 2) const SizedBox(height: 80),

                    if (_currentStep <= 7) ...[
                      _buildStepIndicator(),
                      const SizedBox(height: 30),
                    ],

                    _buildCurrentStepContent(),

                    if (_currentStep < 8) ...[
                       const SizedBox(height: 40),
                       ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_currentStep == 1) {
                              if (_selectedSex == "Select") {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select gender")));
                                return;
                              }
                              setState(() => _isLoading = true);
                              try {
                                await supabase.auth.signInWithOtp(email: _emailCtrl.text.trim());
                                _startOtpTimer();
                                setState(() {
                                  _isLoading = false;
                                  _setStep(2);
                                });
                              } catch (e) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send OTP: $e")));
                              }
                              return;
                            }
                            if (_currentStep == 2) {
                              String otpToken = _otpControllers.map((e) => e.text).join();
                              if (otpToken.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete the OTP")));
                                return;
                              }
                              setState(() => _isLoading = true);
                              try {
                                final AuthResponse res = await supabase.auth.verifyOTP(
                                  type: OtpType.magiclink,
                                  token: otpToken,
                                  email: _emailCtrl.text.trim(),
                                );
                                if (res.session != null) {
                                  setState(() {
                                    _isLoading = false;
                                    _setStep(3);
                                  });
                                } else {
                                  throw Exception("Invalid OTP.");
                                }
                              } catch (e) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                              }
                              return;
                            }
                            if (_currentStep == 3) {
                              if (_selectedCitizenship == "Select your citizenship") {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select your citizenship")));
                                return;
                              }
                              if (_selectedIDType == "Choose valid ID to upload") {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a valid ID type")));
                                return;
                              }
                              if (_selectedIDFile == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload your Government ID")));
                                return;
                              }
                            }
                            if (_currentStep == 4 && _selectedSelfieFile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please take a selfie")));
                              return;
                            }
                            
                            if (_currentStep == 6) {
                              if (_passwordController.text.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Supabase requires at least 6 characters for a password.")));
                                return;
                              }
                              if (!_passwordsMatch) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                                return;
                              }
                              if (!_agreedToTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please agree to the terms")));
                                return;
                              }
                            }
                            
                            if (_currentStep == 7) {
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
                              
                              // TRIGGER SUPABASE SAVE
                              _registerUser();
                              return;
                            }

                            _setStep(_currentStep + 1);
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              (_currentStep == 2 || _currentStep == 7) ? "Continue" : "Next",
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
          ],
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
      case 8: return _buildStep8();
      default: return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Personal Details", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
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
                      null,
                      [
                        "Select", "N/A", "Jr.", "Sr.", "I", "II", "III", "IV", "V", "VI",
                        "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV",
                        "XV", "XVI", "XVII", "XVIII", "XIX", "XX"
                      ],
                      _selectedSuffix,
                      (v) => setState(() => _selectedSuffix = v ?? "Select")),
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
                      null,
                      ["Select", "Male", "Female"],
                      _selectedSex,
                      (v) => setState(() => _selectedSex = v ?? "Select")),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel("Date of birth"),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day), 
              firstDate: DateTime(1900),  
              lastDate: DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),    
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
                _dobCtrl.text = "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
              });
            }
          },
          child: AbsorbPointer(
            child: _buildTextField(
              _dobCtrl,
              "Birthdate",
              Icons.calendar_month_outlined,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel("Email Address"),
        _buildTextField(_emailCtrl, "Enter email", Icons.email_outlined,
            validator: (v) => !v!.contains("@")
                ? "Please enter a valid email"
                : null),
      ],
    );
  }

  Widget _buildStep2() {
    String maskedEmail = _emailCtrl.text.isNotEmpty && _emailCtrl.text.contains('@')
      ? "${_emailCtrl.text.substring(0, _emailCtrl.text.indexOf('@') > 5 ? 5 : 1)}*****${_emailCtrl.text.substring(_emailCtrl.text.indexOf('@'))}"
      : '*****@gmail.com';
    String minutes = (_otpTimer ~/ 60).toString().padLeft(2, '0');
    String seconds = (_otpTimer % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        const Text("OTP Verification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("We've sent you the verification code\non $maskedEmail", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 40),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(6, (i) => _buildOtpBox(_otpControllers[i], i))),
        const SizedBox(height: 30),
        _otpTimer > 0 
          ? Text("Re-send code in $minutes:$seconds", style: const TextStyle(color: Colors.black))
          : TextButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  await supabase.auth.signInWithOtp(email: _emailCtrl.text.trim());
                  _startOtpTimer();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP Resent!")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to resend: $e")));
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              child: const Text("Resend Code", style: TextStyle(color: Colors.blue)),
            ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Current Address", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        _buildLabel("Region"),
        _buildDropdown(null, AddressData.regionProvinces.keys.toList()..insert(0, "Select your region"), _selectedRegion ?? "Select your region", (v) {
          setState(() {
            _selectedRegion = v;
            _selectedProvince = null;
            _selectedCity = null;
            _selectedBarangay = "Select your barangay";
            _barangays = ["Select your barangay"];
          });
        }),
        const SizedBox(height: 16),
        _buildLabel("Province"),
        _buildDropdown(null, (_selectedRegion != null && _selectedRegion != "Select your region" && AddressData.regionProvinces.containsKey(_selectedRegion)) ? (AddressData.regionProvinces[_selectedRegion]!.toList()..insert(0, "Select your province")) : ["Select your province"], _selectedProvince ?? "Select your province", (v) {
          setState(() {
            _selectedProvince = v;
            _selectedCity = null;
            _selectedBarangay = "Select your barangay";
            _barangays = ["Select your barangay"];
          });
        }),
        const SizedBox(height: 16),
        _buildLabel("City/ Municipality"),
        _buildDropdown(null, (_selectedProvince != null && _selectedProvince != "Select your province" && AddressData.provinceCities.containsKey(_selectedProvince)) ? (AddressData.provinceCities[_selectedProvince]!.toList()..insert(0, "Select your city / municipality")) : ["Select your city / municipality"], _selectedCity ?? "Select your city / municipality", (v) {
          setState(() {
            _selectedCity = v;
            _selectedBarangay = "Select your barangay";
            if (v != null && AddressData.cityBarangays.containsKey(v)) {
              _barangays = AddressData.cityBarangays[v]!.toList()..insert(0, "Select your barangay");
            } else {
              _barangays = ["Select your barangay"];
            }
          });
        }),
        const SizedBox(height: 16),
        _buildLabel("Barangay"),
        _buildDropdown(null, _barangays.isNotEmpty ? _barangays : ["Select your barangay"], _selectedBarangay, (v) => setState(() => _selectedBarangay = v!)),
        const SizedBox(height: 16),
        _buildLabel("House / Unit / Bldg No."),
        _buildTextField(_houseCtrl, "Enter your House / Unit / Bldg No.", Icons.home_outlined, validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        _buildLabel("Street / Area Name"),
        _buildTextField(_streetCtrl, "Enter your Street / Area Name", Icons.map_outlined, validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        _buildLabel("ZIP / Postal Code"),
        _buildTextField(_zipCtrl, "Enter your zip / postal code", Icons.location_city_outlined, validator: (v) => v!.isEmpty ? "Required" : null),
        
        const SizedBox(height: 30),
        const Text("Identification", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildLabel("ID Number"),
        _buildTextField(_idNumCtrl, "Enter ID number", Icons.badge_outlined, validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 16),
        _buildLabel("Citizenship"),
        _buildDropdown(null, _citizenships, _selectedCitizenship, (v) => setState(() => _selectedCitizenship = v!)),
        const SizedBox(height: 16),
        _buildLabel("Type of Government ID"),
        _buildDropdown(null, _idTypes, _selectedIDType, (v) => setState(() => _selectedIDType = v!)),
        const SizedBox(height: 25),
        GestureDetector(
          onTap: _pickIDImage,
          child: _selectedIDFile == null
              ? _buildUploadBox("Upload a photo/s")
              : Container(
                  height: 150, width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: strokeColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb ? Image.network(_selectedIDFile!.path, fit: BoxFit.cover) : Image.file(_selectedIDFile!, fit: BoxFit.cover),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 280, width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor, width: 1.5, style: _selectedSelfieFile == null ? BorderStyle.solid : BorderStyle.none),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                if (_isCameraInitialized && _cameraController != null)
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio > 0 ? _cameraController!.value.aspectRatio : 1,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                if (!_isCameraInitialized)
                  Positioned.fill(
                    child: Center(child: Text(_isInitializingCamera ? "Initializing Camera..." : "Take a Selfie", style: const TextStyle(color: Colors.grey, fontSize: 16))),
                  ),
                if (_selectedSelfieFile != null)
                  Positioned.fill(
                    child: kIsWeb 
                      ? Image.network(_selectedSelfieFile!.path, fit: BoxFit.cover) 
                      : Image.file(_selectedSelfieFile!, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedSelfieFile != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSelfieFile = null;
                  });
                  if (_cameraController == null || !_isCameraInitialized) {
                    _initializeCamera();
                  } else {
                    try {
                      _cameraController?.resumePreview();
                    } catch (e) {
                      debugPrint("resumePreview error: $e");
                    }
                  }
                },
                icon: const Icon(Icons.refresh, color: Colors.grey),
                label: const Text("Retake Selfie", style: TextStyle(color: Colors.grey)),
              ),
            if (_selectedSelfieFile == null)
              GestureDetector(
                onTap: () {
                  if (!_isCameraInitialized && !_isInitializingCamera) {
                    _initializeCamera();
                  } else if (_isCameraInitialized) {
                    _takeSelfie();
                  }
                },
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1)),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 30),
                ),
              ),
          ],
        )
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Confirm Information", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(child: Text("Please make sure the details are correct.", style: TextStyle(color: Colors.blue))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildConfirmSection("Personal Details", 1, {
          "First Name": _fNameCtrl.text,
          "Middle Name": _mNameCtrl.text,
          "Last Name": _lNameCtrl.text,
          "Suffix": _selectedSuffix,
          "Sex": _selectedSex,
          "Date of Birth": _dobCtrl.text,
          "Email Address": _emailCtrl.text,
        }),
        _buildConfirmSection("Current Address", 3, {
          "House / Unit / Bldg No.": _houseCtrl.text,
          "Street / Area Name": _streetCtrl.text,
          "Barangay": _selectedBarangay,
          "City/ Municipality": _selectedCity ?? "",
          "Province": _selectedProvince ?? "",
          "Region": _selectedRegion ?? "",
          "ZIP / Postal Code": _zipCtrl.text,
        }),
        _buildConfirmSection("Identification", 3, {
          "ID Number": _idNumCtrl.text,
          "Citizenship": _selectedCitizenship,
          "Type of Government ID": _selectedIDType,
        }),
      ],
    );
  }

  Widget _buildConfirmSection(String title, int targetStep, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            InkWell(
              onTap: () => _setStep(targetStep),
              child: Row(
                children: [
                  Text("Edit Details", style: TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_outlined, color: primaryBlue, size: 14),
                ],
              ),
            ),
          ],
        ),
        const Divider(),
        ...data.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 140, child: Text(e.key, style: const TextStyle(color: Colors.grey, fontSize: 12))),
              Expanded(child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
        )).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
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

  Widget _buildStep7() {
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

  Widget _buildStep8() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
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
          const SizedBox(height: 50),
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

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData? icon, {bool enabled = true, String? Function(String?)? validator, IconData? suffixIcon}) {
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
          hintText: hint, 
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
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

  Widget _buildDropdown(IconData? icon, List<String> items, String current, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey, size: 22),
            const SizedBox(width: 8),
          ],
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

  Widget _buildOtpBox(TextEditingController ctrl, int index) {
    return Container(
      width: 45, height: 50,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: strokeColor)),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    Color color = _passwordController.text.isEmpty ? Colors.black54 : (isMet ? Colors.green : Colors.red);
    return Row(children: [Icon(isMet ? Icons.check_circle : Icons.circle, size: 14, color: color), const SizedBox(width: 8), Text(text, style: TextStyle(color: color, fontSize: 12))]);
  }

  Widget _buildStepIndicator() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("$_currentStep of 7", style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: List.generate(7, (index) => Expanded(child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: index < _currentStep ? Colors.red : Colors.grey.shade300, borderRadius: BorderRadius.circular(5)))))),
    ]);
  }
}