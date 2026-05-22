import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captain_app_flutter/providers/auth_provider.dart';
import 'package:captain_app_flutter/screens/auth/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _darkMode = false;
  bool _gpsHighAccuracy = true;
  String _selectedLanguage = 'English';
  String _selectedNavProvider = 'Google Maps';

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of RideMate Captain? You will not receive any ride requests while signed out.',
          style: TextStyle(color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showNavigationProviderModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Navigation Provider',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNavOption(
                    logoColor: const Color(0xFF4285F4),
                    title: 'Google Maps',
                    subtitle: 'Official Google Maps navigation engine',
                    logoIcon: Icons.map_outlined,
                    isSelected: _selectedNavProvider == 'Google Maps',
                    onTap: () {
                      setState(() => _selectedNavProvider = 'Google Maps');
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNavOption(
                    logoColor: const Color(0xFF33CCFF),
                    title: 'Waze',
                    subtitle: 'Crowdsourced traffic and road alerts',
                    logoIcon: Icons.question_answer_outlined,
                    isSelected: _selectedNavProvider == 'Waze',
                    onTap: () {
                      setState(() => _selectedNavProvider = 'Waze');
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNavOption(
                    logoColor: const Color(0xFF1E293B),
                    title: 'Apple Maps / OSM',
                    subtitle: 'Default operating system maps provider',
                    logoIcon: Icons.navigation_outlined,
                    isSelected: _selectedNavProvider == 'Apple Maps / OSM',
                    onTap: () {
                      setState(() => _selectedNavProvider = 'Apple Maps / OSM');
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavOption({
    required Color logoColor,
    required String title,
    required String subtitle,
    required IconData logoIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: logoColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(logoIcon, color: logoColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00C853))
            else
              const Icon(Icons.circle_outlined, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App settings section
            const Text(
              'App Configurations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
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
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive ride requests and system alerts',
                    value: _pushNotifications,
                    icon: Icons.notifications_none_rounded,
                    iconBgColor: const Color(0xFFEFF6FF), // blue
                    iconColor: const Color(0xFF3B82F6),
                    onChanged: (val) {
                      setState(() {
                        _pushNotifications = val;
                      });
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSwitchTile(
                    title: 'High Accuracy GPS',
                    subtitle: 'Better tracking for ride navigation',
                    value: _gpsHighAccuracy,
                    icon: Icons.location_on_outlined,
                    iconBgColor: const Color(0xFFECFDF5), // green
                    iconColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() {
                        _gpsHighAccuracy = val;
                      });
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Reduce eye strain at night',
                    value: _darkMode,
                    icon: Icons.dark_mode_outlined,
                    iconBgColor: const Color(0xFFF5F3FF), // purple
                    iconColor: const Color(0xFF8B5CF6),
                    onChanged: (val) {
                      setState(() {
                        _darkMode = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Account & Preferences section
            const Text(
              'Preferences & Security',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
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
                  _buildMenuTile(
                    title: 'App Language',
                    valueText: _selectedLanguage,
                    icon: Icons.translate_rounded,
                    iconBgColor: const Color(0xFFFFF7ED), // orange
                    iconColor: const Color(0xFFF97316),
                    onTap: _showLanguageDialog,
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMenuTile(
                    title: 'Change Password',
                    icon: Icons.lock_outline_rounded,
                    iconBgColor: const Color(0xFFFFF1F2), // red/pink
                    iconColor: const Color(0xFFF43F5E),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildMenuTile(
                    title: 'Navigation Provider',
                    valueText: _selectedNavProvider,
                    icon: Icons.navigation_outlined,
                    iconBgColor: const Color(0xFFECFDF5), // emerald green
                    iconColor: const Color(0xFF10B981),
                    onTap: _showNavigationProviderModal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Red-themed Logout Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign Out of RideMate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'You will go offline and will not receive any ride bookings until you log back in.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB91C1C),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Log Out Account',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        value: value,
        activeColor: const Color(0xFF00C853),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    String? valueText,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valueText != null)
            Text(valueText, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold)),
        children: ['English', 'Español', 'Hindi', 'Tamil'].map((lang) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() {
                _selectedLanguage = lang;
              });
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _selectedLanguage == lang ? FontWeight.bold : FontWeight.normal,
                      color: _selectedLanguage == lang ? const Color(0xFF0F172A) : const Color(0xFF475569),
                    ),
                  ),
                  if (_selectedLanguage == lang)
                    const Icon(Icons.check, color: Color(0xFF00C853)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
