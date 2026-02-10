import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'file_report.dart';
import 'submitted_reports.dart'; 
import 'global/top_bar.dart';
import 'notification.dart';
import 'profile.dart';

class DSWDMainPage extends StatefulWidget {
  const DSWDMainPage({super.key});

  @override
  State<DSWDMainPage> createState() => _DSWDMainPageState();
}

class _DSWDMainPageState extends State<DSWDMainPage> {
  int _selectedIndex = 0;

  // Default location (Manila)
  LatLng _currentLocation = const LatLng(14.5995, 120.9842);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _showAboutPopup();
  }

  // --- MAP LOGIC ---

  void _handleZoom(double zoomDelta) {
    double newZoom = _mapController.camera.zoom + zoomDelta;
    _mapController.move(_mapController.camera.center, newZoom);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(_currentLocation, 15.0);
  }

  // --- ABOUT POP-UP LOGIC ---
  void _showAboutPopup() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "About",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "This app enables citizens to report Families and Individuals in Street Situations (FISS) in their community to the Department of Social Welfare and Development (DSWD). Your reports help us provide timely assistance and support to those in need.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Key Features",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• Location-Based Reporting: Pin exact locations.\n"
                    "• Photo Documentation: Attach photos for context.\n"
                    "• Facility Locator: Navigate to closest DSWD centers.\n"
                    "• Automated Rule-Based Chat: 24/7 interface.\n"
                    "• Status Tracking: Monitor report progress.\n"
                    "• Trust Logic: Secure community verification.",
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "I Understand",
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
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      appBar: GlobalAppBar(onAboutTap: _showAboutPopup),

      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // FLOATING SEARCH BAR
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black, size: 26),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: TextStyle(fontSize: 17),
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // MAP BUTTONS
          Positioned(
            bottom: 140,
            left: 20,
            child: Column(
              children: [
                _buildMapSquareButton(Icons.add, () => _handleZoom(1)),
                _buildMapSquareButton(Icons.remove, () => _handleZoom(-1)),
              ],
            ),
          ),

          Positioned(
            bottom: 140,
            right: 20,
            child: GestureDetector(
              onTap: _determinePosition,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 60,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home
            _buildNavIcon(Icons.home, _selectedIndex == 0, 0),

            _buildNavIcon(
              Icons.description_outlined,
              _selectedIndex == 1,
              1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmittedReportsPage(),
                  ),
                ).then((_) => setState(() => _selectedIndex = 0));
              },
            ),

            // Central Plus Button (File Report)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FileReportPage(),
                  ),
                ).then((_) {
                  setState(() => _selectedIndex = 0);
                });
              },
              child: Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  color: _selectedIndex == 2 ? Colors.black : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 45),
              ),
            ),

            // Submitted Reports (via Notification Icon)
            _buildNavIcon(
              Icons.notifications_none,
              _selectedIndex == 3,
              3,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                ).then((_) => setState(() => _selectedIndex = 0));
              },
            ),

            // Profile
             _buildNavIcon(
              Icons.person_outline,
              _selectedIndex == 4,
              3,
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                ).then((_) => setState(() => _selectedIndex = 0));
              },
            ),

          ],
        ),
      ),
    );
  }

  // --- REUSABLE UI HELPERS ---

  Widget _buildNavIcon(
    IconData icon,
    bool isActive,
    int index, {
    VoidCallback? onTap,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 35,
        color: isActive ? Colors.black : Colors.grey[400],
      ),
      onPressed:
          onTap ??
          () {
            setState(() {
              _selectedIndex = index;
            });
          },
    );
  }

  Widget _buildMapSquareButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }
}
