import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(
    home: ForgotMpinPage(),
    debugShowCheckedModeBanner: false,
  ));
}

// --- SCREEN 1: FORGOT MPIN (EMAIL) ---
class ForgotMpinPage extends StatefulWidget {
  const ForgotMpinPage({super.key});

  @override
  State<ForgotMpinPage> createState() => _ForgotMpinPageState();
}

class _ForgotMpinPageState extends State<ForgotMpinPage> {
  final _formKey = GlobalKey<FormState>();
  final Color strokeColor = const Color(0xFFA29696);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(child: Image.asset('assets/DSWD.png', height: 148, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100))),
                  const SizedBox(height: 8),
                  Text(
                    'Forgot MPIN',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please write your e-mail address\nto receive confirmation code',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 16, height: 1.2),
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email Address", style: GoogleFonts.inter(fontSize: 16, color: Colors.black)),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter Email',
                            prefixIcon: Icon(Icons.email_outlined, color: strokeColor),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: strokeColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: strokeColor, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter email';
                            if (!value.contains('@')) return 'Email must contain @';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const VerificationPage()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3192),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text("Confirm", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 2: VERIFICATION CODE (6 DIGITS) ---
class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final Color strokeColor = const Color(0xFFA29696);

  @override
  void dispose() {
    for (var controller in _controllers) { controller.dispose(); }
    for (var node in _focusNodes) { node.dispose(); }
    super.dispose();
  }

  bool get _isComplete => _controllers.every((c) => c.text.isNotEmpty);

  Widget _buildCodeBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor, width: 2)),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty) {
            if (index < 5) { _focusNodes[index + 1].requestFocus(); } else { _focusNodes[index].unfocus(); }
          } else {
            if (index > 0) { _focusNodes[index - 1].requestFocus(); }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context)
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(child: Image.asset('assets/DSWD.png', height: 148, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100))),
              const SizedBox(height: 8),
              Text('Verification Code', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Enter the verification code we\'ve sent\nto your usertesting@gmail.com', 
                textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildCodeBox(index)),
                ),
              ),
              const SizedBox(height: 32),
              Text('Re-send code in 2:00', style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isComplete 
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewMpinPage()))
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3192),
                      disabledBackgroundColor: const Color(0xFFBDBDBD),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
                    ),
                    child: Text("Confirm Code", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 3: NEW MPIN (FIXED UI & HIDDEN) ---
class NewMpinPage extends StatefulWidget {
  const NewMpinPage({super.key});

  @override
  State<NewMpinPage> createState() => _NewMpinPageState();
}

class _NewMpinPageState extends State<NewMpinPage> {
  // Gagamit tayo ng separate list para i-store ang actual values (yung numbers)
  final List<String> _actualValues = ["", "", "", ""];
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final Color strokeColor = const Color(0xFFA29696);

  @override
  void dispose() {
    for (var controller in _controllers) { controller.dispose(); }
    for (var node in _focusNodes) { node.dispose(); }
    super.dispose();
  }

  bool get _isComplete => _actualValues.every((v) => v.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(child: Image.asset('assets/DSWD.png', height: 148, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100))),
                    const SizedBox(height: 16),
                    Text("Enter your new MPIN", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Please enter your new 4-digit security pin", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 48),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Text(
                              "MPIN",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) => _buildPinBox(index)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isComplete 
                            ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessMpinPage()))
                            : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3192),
                            disabledBackgroundColor: const Color(0xFFBDBDBD),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text("Confirm", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text("Contact Us | About Us", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  Widget _buildPinBox(int index) {
    return Container(
      width: 65, height: 60, // HINDI NA LILIIT ITO
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        obscureText: false, // Gawing false para hindi lumiit ang font layout
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          // Pinapantay ang vertical alignment
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: strokeColor, width: 2)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Pag-save ng actual value at palitan ang display ng tuldok
            _actualValues[index] = value;
            _controllers[index].text = "●"; 
            
            if (index < 3) { _focusNodes[index + 1].requestFocus(); } else { _focusNodes[index].unfocus(); }
          } else {
            _actualValues[index] = "";
            if (index > 0) { _focusNodes[index - 1].requestFocus(); }
          }
          setState(() {});
        },
      ),
    );
  }
}

// --- SCREEN 4: SUCCESS PAGE ---
class SuccessMpinPage extends StatelessWidget {
  const SuccessMpinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(),
            Center(child: Image.asset('assets/VerifiedCheck.png', height: 150, errorBuilder: (c, e, s) => const Icon(Icons.check_circle, color: Colors.green, size: 100))),
            const SizedBox(height: 32),
            Text('MPIN Changed!', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your MPIN has been changed successfully', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text("Login", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}