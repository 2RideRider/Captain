import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:captain_app_flutter/providers/auth_provider.dart';
import 'package:captain_app_flutter/screens/wallet/wallet_screen.dart';
import 'package:captain_app_flutter/screens/profile/profile_screen.dart';
import 'package:captain_app_flutter/screens/settings/settings_screen.dart';

enum SimulationState {
  offline,
  onlineSearch,
  requestReceived,
  headingToPickup,
  arrived,
  inTrip,
  completed
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  int _currentTab = 0;
  SimulationState _simState = SimulationState.offline;

  GoogleMapController? mapController;
  final LatLng _center = const LatLng(28.6139, 77.2090); // New Delhi
  bool _locationPermissionGranted = false;

  // Mock ride details
  final String _riderName = "Rahul Sharma";
  final String _riderRating = "4.9";
  final String _pickupAddress = "Connaught Place, E Block";
  final String _dropAddress = "Indira Gandhi International Airport (T3)";
  final String _fareAmount = "₹ 245.00";
  final String _rideDistance = "14.2 km";
  final String _otpCode = "4832";

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  Timer? _searchTimer;
  Timer? _countdownTimer;
  int _countdownSeconds = 15;

  AnimationController? _radarController;
  AnimationController? _pulseController;

  // Map markers
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _otpController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _countdownTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _radarController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _locationPermissionGranted = true;
        });
      }
    }
  }

  // Toggles online status on backend
  void _toggleOnline(bool online) async {
    final success = await ref.read(authProvider.notifier).toggleOnlineStatus(online);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).errorMessage ?? 'Connection error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        if (online) {
          _simState = SimulationState.onlineSearch;
          _startRideRequestSimulation();
        } else {
          _simState = SimulationState.offline;
          _searchTimer?.cancel();
          _countdownTimer?.cancel();
          _markers.clear();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(online ? 'Duty Activated. You are Online!' : 'Duty Deactivated. You are Offline.'),
          backgroundColor: online ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownSeconds = 15;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownSeconds > 1) {
            _countdownSeconds--;
          } else {
            _countdownTimer?.cancel();
            _declineRide();
          }
        });
      }
    });
  }

  void _startRideRequestSimulation() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _simState == SimulationState.onlineSearch) {
        setState(() {
          _simState = SimulationState.requestReceived;
          // Set markers on the map
          _markers.add(
            Marker(
              markerId: const MarkerId('pickup'),
              position: const LatLng(28.6289, 77.2150),
              infoWindow: const InfoWindow(title: 'Pickup Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
          _markers.add(
            const Marker(
              markerId: MarkerId('drop'),
              position: LatLng(28.5562, 77.1000),
              infoWindow: InfoWindow(title: 'Drop Destination'),
            ),
          );
        });
        _startCountdown();
      }
    });
  }

  void _acceptRide() {
    _countdownTimer?.cancel();
    setState(() {
      _simState = SimulationState.headingToPickup;
    });
    // Center map on pickup marker
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: LatLng(28.6289, 77.2150), zoom: 14.5),
      ),
    );
  }

  void _declineRide() {
    _countdownTimer?.cancel();
    setState(() {
      _simState = SimulationState.onlineSearch;
      _markers.clear();
      _startRideRequestSimulation();
    });
  }

  void _arrivedAtPickup() {
    setState(() {
      _simState = SimulationState.arrived;
    });
  }

  void _verifyOtpAndStartRide() {
    if (_otpController.text.trim() == _otpCode || _otpController.text.trim().length >= 4) {
      setState(() {
        _simState = SimulationState.inTrip;
      });
      // Center map on drop marker
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: LatLng(28.5562, 77.1000), zoom: 13.5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please enter $_otpCode to start.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _completeTrip() {
    setState(() {
      _simState = SimulationState.completed;
    });
  }

  void _finishCompletedState() {
    setState(() {
      _simState = SimulationState.onlineSearch;
      _markers.clear();
      _otpController.clear();
      _startRideRequestSimulation();
    });
  }

  Widget _buildMapTab(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Stack(
      children: [
        // Google Map Background
        GoogleMap(
          onMapCreated: (controller) => mapController = controller,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.5,
          ),
          myLocationEnabled: _locationPermissionGranted,
          markers: _markers,
        ),

        // Glowing animated pulsing radar for online search
        if (_simState == SimulationState.onlineSearch)
          Center(
            child: RadarPulse(animation: _radarController!),
          ),

        // Semi-transparent overlay when offline
        if (_simState == SimulationState.offline)
          Container(
            color: Colors.black.withOpacity(0.55),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'YOU ARE OFFLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Go online to receive ride bookings',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

        // Top Status Header Panel
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: SafeArea(
            child: Column(
              children: [
                // Quick Toggle switch in Frosted Glassmorphism card
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _simState != SimulationState.offline
                            ? const Color(0xFF00C853).withOpacity(0.15)
                            : Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _simState != SimulationState.offline
                              ? const Color(0xFF00C853).withOpacity(0.35)
                              : Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController!,
                                builder: (context, child) {
                                  return Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _simState != SimulationState.offline ? const Color(0xFF00C853) : Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: _simState != SimulationState.offline
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF00C853).withOpacity(0.8),
                                                blurRadius: 4 + (_pulseController!.value * 6),
                                                spreadRadius: _pulseController!.value * 3,
                                              )
                                            ]
                                          : [],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _simState != SimulationState.offline ? 'DUTY ACTIVE' : 'DUTY INACTIVE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _simState != SimulationState.offline ? Colors.white : Colors.white70,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _simState != SimulationState.offline,
                            onChanged: _toggleOnline,
                            activeColor: const Color(0xFF00C853),
                            activeTrackColor: Colors.white.withOpacity(0.3),
                            inactiveThumbColor: Colors.white70,
                            inactiveTrackColor: Colors.white.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Floating Stats Summary Card
                if (_simState != SimulationState.offline)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Today\'s Income', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '₹ ${user?.walletBalance ?? 450.00}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        Container(height: 25, width: 1, color: Colors.grey.shade300),
                        const Column(
                          children: [
                            Text('Trips Done', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            SizedBox(height: 4),
                            Text(
                              '12',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        Container(height: 25, width: 1, color: Colors.grey.shade300),
                        Column(
                          children: [
                            const Text('Rating', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  '${user?.ratings ?? 4.8}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom Sheets for Ride States
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: _buildBottomRidePanel(),
        ),
      ],
    );
  }

  Widget _buildOtpGrid() {
    return GestureDetector(
      onTap: () {
        _otpFocusNode.requestFocus();
      },
      child: FocusScope(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            String char = "";
            if (_otpController.text.length > index) {char = _otpController.text[index];}
            bool isFocused = _otpController.text.length == index && _otpFocusNode.hasFocus;
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused ? const Color(0xFF00C853) : const Color(0xFFE2E8F0),
                  width: isFocused ? 2 : 1.5,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00C853).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(char, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBottomRidePanel() {
    switch (_simState) {
      case SimulationState.offline:
        return const SizedBox.shrink();

      case SimulationState.onlineSearch:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF00C853),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Searching for riders...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
        );

      case SimulationState.requestReceived:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW RIDE REQUEST',
                      style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                    ),
                  ),
                  Text(
                    _fareAmount,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF00C853)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE2E8F0),
                    radius: 20,
                    child: Text(_riderName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _riderName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text('$_riderRating Rating', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 10),
                            const Icon(Icons.payment, color: Colors.grey, size: 14),
                            const SizedBox(width: 2),
                            const Text('Cash', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 15s Circular Countdown Timer
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: _countdownSeconds / 15.0,
                          strokeWidth: 3.5,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _countdownSeconds > 5 ? const Color(0xFF00C853) : Colors.redAccent,
                          ),
                        ),
                      ),
                      Text(
                        '$_countdownSeconds',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _countdownSeconds > 5 ? const Color(0xFF1E293B) : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              // Route stepper details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.my_location, color: Color(0xFF00C853), size: 18),
                      Container(width: 1.5, height: 35, color: Colors.grey.shade300),
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PICKUP',
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _pickupAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'DROP-OFF',
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dropAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _declineRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF64748B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Accept Ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case SimulationState.headingToPickup:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HEADING TO PICKUP',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11, letterSpacing: 0.5),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('1.2 km away', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE2E8F0),
                    radius: 20,
                    child: Text(_riderName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _riderName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _pickupAddress,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.phone, color: Color(0xFF00C853), size: 18),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling rider...'),
                          backgroundColor: Color(0xFF00C853),
                        ),
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _arrivedAtPickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ARRIVED AT PICKUP',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );

      case SimulationState.arrived:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ENTER START OTP',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 11, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ask the rider for the 4-digit code to start the ride.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              // OTP Boxes
              _buildOtpGrid(),
              const SizedBox(height: 10),
              // Hidden TextField
              SizedBox(
                width: 0,
                height: 0,
                child: TextField(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _verifyOtpAndStartRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Verify & Start Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                ),
              ),
            ],
          ),
        );

      case SimulationState.inTrip:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRIP IN PROGRESS',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C853), fontSize: 11, letterSpacing: 0.5),
                  ),
                  Text(
                    'Remaining: $_rideDistance',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.navigation, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _dropAddress,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _completeTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'COMPLETE RIDE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );

      case SimulationState.completed:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 56),
              const SizedBox(height: 14),
              const Text(
                'Ride Completed Successfully!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                'Collect cash payment from $_riderName',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              // Detailed fare breakdown card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Base Fare', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text('₹ 50.00', style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Distance Fare (14.2 km)', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text('₹ 170.00', style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('RideMate Service Fee', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text('-₹ 25.00', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rider Tip', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text('₹ 50.00', style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL CASH TO COLLECT', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          _fareAmount,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF00C853)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _finishCompletedState,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildMapTab(context),
      const WalletScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00C853),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Go',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class RadarPulse extends StatelessWidget {
  final Animation<double> animation;

  const RadarPulse({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (index) {
              double delayFactor = index * 0.33;
              double progress = (animation.value + delayFactor) % 1.0;
              double size = 100 + (progress * 250);
              double opacity = (1.0 - progress) * 0.6;
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00C853).withOpacity(opacity * 0.15),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(opacity * 0.4),
                    width: 1.5,
                  ),
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF00C853),
                child: Icon(Icons.navigation, color: Colors.white, size: 24),
              ),
            ),
          ],
        );
      },
    );
  }
}
