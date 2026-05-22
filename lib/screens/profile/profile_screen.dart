import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captain_app_flutter/providers/auth_provider.dart';
import 'package:captain_app_flutter/providers/documents_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(documentsProvider.notifier).fetchDocuments();
      ref.read(authProvider.notifier).refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final vehicle = user?.vehicle;
    final vehicleType = vehicle?['type'] ?? 'N/A';
    final vehicleModel = vehicle?['model'] ?? 'N/A';
    final plateNumber = vehicle?['plateNumber'] ?? 'N/A';
    final vehicleColor = vehicle?['color'] ?? 'N/A';

    IconData getVehicleIcon(String type) {
      switch (type.toLowerCase()) {
        case 'bike':
          return Icons.directions_bike;
        case 'auto':
          return Icons.local_taxi;
        case 'car':
        default:
          return Icons.directions_car;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            // Driver Profile Header Card (Premium redesign with gradient avatar and quick-action chips)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Gradient avatar border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: const Color(0xFFE8F5E9),
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'C',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00C853),
                              ),
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF00C853),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'N/A',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.ratings ?? 0.0} ★',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, color: Color(0xFF059669), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Verified Partner',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderInfo(context, label: 'Role', value: 'Captain', icon: Icons.sports_motorsports_outlined),
                      _buildHeaderInfo(context, label: 'Phone', value: user?.phone ?? 'N/A', icon: Icons.phone_outlined),
                      _buildHeaderInfo(context, label: 'Email', value: user?.email ?? 'N/A', icon: Icons.email_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionChip(
                        label: 'Call Admin',
                        icon: Icons.phone_in_talk,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      _buildActionChip(
                        label: 'Support Chat',
                        icon: Icons.chat_bubble_outline_rounded,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stylized Indian License Plate Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions_car_filled_outlined, color: Color(0xFF00C853)),
                      SizedBox(width: 10),
                      Text(
                        'Vehicle Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          getVehicleIcon(vehicleType),
                          color: const Color(0xFF00C853),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleModel.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type: ${vehicleType.toUpperCase()}  |  Color: $vehicleColor',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Custom Indian License Plate Widget
                  _buildLicensePlate(plateNumber),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Document Checklist Widget (Directly visual, extremely premium)
            _buildDocumentChecklist(),
            const SizedBox(height: 24),

            // Partner Actions List Menu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildProfileMenuItem(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Ride History',
                    subtitle: 'Logs of all past completed rides',
                    onTap: () {},
                  ),
                  _buildProfileMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Frequently asked questions & FAQs',
                    onTap: () {},
                  ),
                  _buildProfileMenuItem(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'About RideMate',
                    subtitle: 'Terms of service & privacy policy',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLicensePlate(String plateNumber) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFACC15), // Yellow background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0F172A), width: 3), // Solid black border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left IND blue band
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8), // Blue IND strip
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFACC15),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'IND',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Bold spaced typography matching transport standards
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: Text(
                plateNumber.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentChecklist() {
    final docState = ref.watch(documentsProvider);
    final docList = docState.documents;

    Map<String, dynamic> getDocInfo(String type, String displayName, IconData icon) {
      final doc = docList.firstWhere(
        (d) => d.type.toLowerCase() == type.toLowerCase(),
        orElse: () => DriverDoc(id: '', type: type, documentUrl: '', status: 'Not Uploaded'),
      );

      String statusText = 'Not Uploaded';
      Color textColor = const Color(0xFF64748B);
      Color bgColor = const Color(0xFFF1F5F9);

      switch (doc.status.toLowerCase()) {
        case 'approved':
          statusText = 'Approved';
          textColor = const Color(0xFF059669);
          bgColor = const Color(0xFFECFDF5);
          break;
        case 'pending':
          statusText = 'Under Review';
          textColor = const Color(0xFFD97706);
          bgColor = const Color(0xFFFFFBEB);
          break;
        case 'rejected':
          statusText = 'Rejected';
          textColor = const Color(0xFFDC2626);
          bgColor = const Color(0xFFFEF2F2);
          break;
        case 'action required':
        case 'not uploaded':
        default:
          statusText = 'Not Uploaded';
          textColor = const Color(0xFFDC2626);
          bgColor = const Color(0xFFFEF2F2);
          break;
      }

      return {
        'type': type,
        'name': displayName,
        'status': statusText,
        'icon': icon,
        'color': textColor,
        'bgColor': bgColor,
        'rejectionReason': doc.rejectionReason,
        'doc': doc,
      };
    }

    final List<Map<String, dynamic>> documents = [
      getDocInfo('license', 'Driving License', Icons.badge_outlined),
      getDocInfo('rc', 'Vehicle Registration (RC)', Icons.description_outlined),
      getDocInfo('aadhaar', 'Aadhaar Card', Icons.fingerprint_outlined),
      getDocInfo('insurance', 'Commercial Insurance', Icons.shield_outlined),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: Color(0xFF00C853)),
              SizedBox(width: 10),
              Text(
                'Document Verification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: documents.map((docItem) {
              final type = docItem['type'] as String;
              final name = docItem['name'] as String;
              final status = docItem['status'] as String;
              final icon = docItem['icon'] as IconData;
              final textColor = docItem['color'] as Color;
              final bgColor = docItem['bgColor'] as Color;
              final rejectionReason = docItem['rejectionReason'] as String?;
              final docObj = docItem['doc'] as DriverDoc;

              final hasUploaded = docObj.documentUrl.isNotEmpty;
              final isApproved = status == 'Approved';
              final isPending = status == 'Under Review';
              final isRejected = status == 'Rejected';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: const Color(0xFF64748B), size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badges & Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Action buttons based on status
                            if (!hasUploaded || isRejected)
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF00C853), size: 20),
                                tooltip: 'Upload',
                                onPressed: () => _showUploadBottomSheet(type, name),
                              )
                            else ...[
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 18),
                                tooltip: 'Re-upload',
                                onPressed: () => _showUploadBottomSheet(type, name),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 18),
                                tooltip: 'Delete',
                                onPressed: () => _deleteDocument(type, name),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    if (isRejected && rejectionReason != null && rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rejection Reason:',
                                    style: TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    rejectionReason,
                                    style: const TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showUploadBottomSheet(String type, String displayName) {
    String selectedUrl = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600'; // Default mock document image
    final urlController = TextEditingController(text: selectedUrl);

    final presets = {
      'license': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      'rc': 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      'aadhaar': 'https://images.unsplash.com/photo-1598257006458-087169a1f08d?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      'insurance': 'https://images.unsplash.com/photo-1517524206127-48bbd363f3d7?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
    };

    if (presets.containsKey(type)) {
      selectedUrl = presets[type]!;
      urlController.text = selectedUrl;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: Color(0xFF00C853), size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Upload $displayName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select a document source preset or enter a custom URL to simulate uploading driver credentials.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SIMULATED PRESET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetChip(
                        label: 'Standard PDF/Mock Scan',
                        url: presets[type] ?? 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
                        isSelected: selectedUrl == (presets[type] ?? 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600'),
                        onTap: (url) {
                          setModalState(() {
                            selectedUrl = url;
                            urlController.text = url;
                          });
                        },
                      ),
                      _buildPresetChip(
                        label: 'Alternate Driver Card Mockup',
                        url: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600',
                        isSelected: selectedUrl == 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600',
                        onTap: (url) {
                          setModalState(() {
                            selectedUrl = url;
                            urlController.text = url;
                          });
                        },
                      ),
                      _buildPresetChip(
                        label: 'Camera Capture Simulation',
                        url: 'https://images.unsplash.com/photo-1508962914676-134849a727f0?w=600',
                        isSelected: selectedUrl == 'https://images.unsplash.com/photo-1508962914676-134849a727f0?w=600',
                        onTap: (url) {
                          setModalState(() {
                            selectedUrl = url;
                            urlController.text = url;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DOCUMENT IMAGE URL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlController,
                    onChanged: (val) {
                      setModalState(() {
                        selectedUrl = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter document image url...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00C853)),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (urlController.text.trim().isEmpty) return;
                            Navigator.pop(context);
                            
                            // Show premium snackbar loading indicator
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                    const SizedBox(width: 16),
                                    Text('Uploading $displayName...'),
                                  ],
                                ),
                                duration: const Duration(seconds: 15),
                                backgroundColor: const Color(0xFF334155),
                              ),
                            );

                            final success = await ref
                                .read(documentsProvider.notifier)
                                .uploadDocument(type, urlController.text.trim());

                            ScaffoldMessenger.of(this.context).hideCurrentSnackBar();

                            if (success) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('$displayName uploaded successfully! Waiting for admin review.'),
                                  backgroundColor: const Color(0xFF00C853),
                                ),
                              );
                              // Refresh profile to reflect pending documents
                              ref.read(authProvider.notifier).refreshProfile();
                            } else {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to upload document. Please try again.'),
                                  backgroundColor: Color(0xFFDC2626),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF00C853),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Upload',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String url,
    required bool isSelected,
    required Function(String) onTap,
  }) {
    return InkWell(
      onTap: () => onTap(url),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDocument(String type, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete $displayName'),
          content: Text('Are you sure you want to delete your $displayName? This will reset your verification status.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Text('Deleting $displayName...'),
            ],
          ),
          duration: const Duration(seconds: 15),
          backgroundColor: const Color(0xFF334155),
        ),
      );

      final success = await ref.read(documentsProvider.notifier).deleteDocument(type);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName deleted successfully.'),
            backgroundColor: const Color(0xFF00C853),
          ),
        );
        ref.read(authProvider.notifier).refreshProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete document. Please try again.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      onPressed: onPressed,
      avatar: Icon(icon, color: const Color(0xFF00C853), size: 16),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 12),
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, {required String label, required String value, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 90,
          child: Text(
            value,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
    );
  }
}
