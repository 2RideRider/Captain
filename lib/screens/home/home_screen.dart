import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = false;
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(28.6139, 77.2090);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captain Dashboard'),
        actions: [
          Switch(
            value: isOnline,
            onChanged: (value) {
              setState(() {
                isOnline = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isOnline ? 'You are now Online' : 'You are now Offline'),
                  backgroundColor: isOnline ? Colors.green : Colors.red,
                ),
              );
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
          ),
          if (!isOnline)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Text(
                  'Go Online to start receiving ride requests',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Earnings summary at top
          if (isOnline)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today\'s Earnings', style: TextStyle(color: Colors.grey)),
                        Text('₹ 450.00', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Completed', style: TextStyle(color: Colors.grey)),
                        Text('12 Rides', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: isOnline 
        ? Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: const Text(
              'Finding nearby rides...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        : null,
    );
  }
}
