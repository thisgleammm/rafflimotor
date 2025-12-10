import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_service.dart';
import '../widgets/confirmation_dialog.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

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
            username,
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
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.settings,
                    title: 'Pengaturan',
                    onTap: () {
                      // TODO: Navigate to settings page
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.info,
                    title: 'Tentang',
                    onTap: () {
                      // TODO: Navigate to about page
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    context,
                    icon: LucideIcons.history,
                    title: 'History',
                    onTap: () {
                      // TODO: Navigate to history page
                    },
                  ),
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
