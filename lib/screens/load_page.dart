import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class LoadPage extends StatefulWidget {
  const LoadPage({super.key});

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi zoom-in logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();

    // Tetap jalankan pengecekan session seperti semula
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final authService = AuthService();
    final isValid = await authService.validateSession();

    if (mounted) {
      if (isValid) {
        // Session valid, ambil user info
        final user = await authService.getCurrentUser();
        final username = user?['username'] ?? 'User';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(username: username),
          ),
        );
      } else {
        // Session invalid/expired, ke login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/colorwpp.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset("assets/app.png", width: 150),
          ),
        ),
      ),
    );
  }
}
