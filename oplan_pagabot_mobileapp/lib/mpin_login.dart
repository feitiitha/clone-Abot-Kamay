import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Mahalaga para sa Database alignment
import 'homepage.dart';
import 'forgot_mpin.dart';

class MPINScreen extends StatefulWidget {
  const MPINScreen({super.key});

  @override
  State<MPINScreen> createState() => _MPINScreenState();
}

class _MPINScreenState extends State<MPINScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final Color strokeColor = const Color(0xFFA29696);

  // 1. Idinagdag ang loading state
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // 2. Updated: Aligned sa Supabase Database Table
  Future<void> _verifyPin() async {
    String enteredPin = _controllers.map((e) => e.text).join();

    if (enteredPin.length == 4) {
      if (mounted) setState(() => _isLoading = true);

      try {
        final user = Supabase.instance.client.auth.currentUser;

        if (user == null) {
          throw "No user logged in. Please login again.";
        }

        // Fetch MPIN data directly from the 'users' table
        final response = await Supabase.instance.client
            .from('users')
            .select('mpin')
            .eq('id', user.id)
            .maybeSingle();

        if (response == null) {
          throw "User record not found in database.";
        }

        final storedMpin = response['mpin'] as String?;

        if (enteredPin == storedMpin) {
          // SUCCESS: Tugma ang PIN
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );

            // Wait briefly for the snackbar
            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DSWDMainPage()),
                (route) => false,
              );
            }
          }
        } else {
          // FAIL: Hindi tugma ang PIN
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incorrect MPIN. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );

            // Clear inputs specifically on error
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      // 3. Stack para sa Loading Spinner overlay
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(child: Image.asset('assets/DSWD.png', height: 148)),
                const SizedBox(height: 16),
                const Text(
                  "Enter your MPIN",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Please enter your 4-digit security pin",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MPIN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          4,
                          (index) => _buildPinBox(index),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotMpinPage(),
                            ),
                          );
                        },
                  child: const Text(
                    "Forgot MPIN code?",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E3192)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPinBox(int index) {
    return Container(
      width: 65,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        obscureText: true,
        obscuringCharacter: '●',
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: strokeColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: strokeColor, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _verifyPin(); // Automatic verify kapag puno na ang 4 boxes
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }
}
