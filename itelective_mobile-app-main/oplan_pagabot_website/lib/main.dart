import 'package:flutter/material.dart';
import 'admin-login.dart';
// import 'landingpage.dart'; // You can switch this to launch the landing page instead

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oplan Pag-abot',
      home: AdminLoginPage(),
    ),
  );
}
