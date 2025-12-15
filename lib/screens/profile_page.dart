import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/auth_service.dart';
import '../widgets/confirmation_dialog.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Versi ${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Red Header with Profile Photo
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Red curved header
              Container(
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFFDA1818),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                ),
              ),
              // Profile Photo (overlapping)
              Positioned(
                bottom: -60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 65,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 70),
          // Username
          Text(
            widget.username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDA1818),
            ),
          ),
          const SizedBox(height: 30),
          // Menu Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // _buildMenuItem(
                  //   context,
                  //   icon: LucideIcons.settings,
                  //   title: 'Pengaturan',
                  //   onTap: () {
                  //     // Navigate to settings page
                  //   },
                  // ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.info,
                    title: 'Tentang',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  // const SizedBox(height: 12),
                  // _buildMenuItem(
                  //   context,
                  //   icon: LucideIcons.history,
                  //   title: 'History',
                  //   onTap: () {
                  //     // Navigate to history page
                  //   },
                  // ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.logOut,
                    title: 'Keluar',
                    onTap: () async {
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Konfirmasi keluar?',
                          content: 'Apakah Anda yakin ingin keluar?',
                          confirmText: 'Ya',
                          cancelText: 'Tidak',
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        final authService = AuthService();
                        await authService.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon/Logo
              SizedBox(
                width: 80,
                height: 80,
                child: ClipOval(
                  child: Image.asset(
                    'assets/app.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // App Name
              const Text(
                'Raffli Motor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              // Version
              Text(
                _appVersion,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Aplikasi manajemen bengkel motor yang membantu Anda mengelola inventori sparepart, transaksi penjualan, dan layanan servis dengan mudah dan efisien.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Features
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fitur Utama:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('Manajemen Inventori Sparepart'),
                    _buildFeatureItem('Transaksi Penjualan & Servis'),
                    _buildFeatureItem('Histori Penjualan'),
                    _buildFeatureItem('Dashboard Analytics'),
                    _buildFeatureItem('Generate Nota PDF'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Developer Info
              Text(
                '© 2024 Raffli Motor',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDA1818),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 16, color: Color(0xFFDA1818)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDA1818).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFDA1818), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Color(0xFFDA1818),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
