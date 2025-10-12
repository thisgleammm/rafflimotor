import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/secure_supabase_client.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_snackbar.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // Jika sudah loading, jangan proses lagi
    if (_isLoading) return;

    // Validasi input
    if (_usernameController.text.trim().isEmpty) {
      CustomSnackBar.showWarning(context, 'Username tidak boleh kosong');
      return;
    }

    if (_passwordController.text.isEmpty) {
      CustomSnackBar.showWarning(context, 'Password tidak boleh kosong');
      return;
    }

    try {
      // Set loading di awal proses login
      setState(() {
        _isLoading = true;
      });

      final response = await SecureSupabaseClient.loginUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response != null) {
        String username = response['username'] ?? 'User';

        // Simpan session secara asynchronous
        SessionService.saveSession(username).then((_) {
          if (!mounted) return;

          // Navigasi ke dashboard langsung
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(username: username),
            ),
          );

          // Tampilkan snackbar setelah navigasi
          CustomSnackBar.showSuccess(
            context,
            'Login berhasil! Selamat datang, $username',
          );
        });
      } else {
        CustomSnackBar.showError(context, 'Username atau password salah');
      }
    } catch (error) {
      if (mounted) {
        String errorMessage = ErrorHandler.getReadableError(error);

        if (ErrorHandler.isNetworkError(error)) {
          CustomSnackBar.showWarning(
            context,
            errorMessage,
            actionLabel: 'Coba Lagi',
            onAction: () => _signIn(),
          );
        } else {
          CustomSnackBar.showError(context, errorMessage);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
  image: DecorationImage(
    image: AssetImage("assets/colorwpp.png"),
    fit: BoxFit.cover, // agar gambar menutupi seluruh layar
  ),
),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo dari assets
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/app.png",
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Login Form Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Glad to see you again! Please enter your username and password to login to your account.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Username Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _isLoading
                                  ? Colors.grey.shade300
                                  : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2D3748),
                            ),
                            decoration: const InputDecoration(
                              hintText: "Username",
                              hintStyle: TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _isLoading
                                  ? Colors.grey.shade300
                                  : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2D3748),
                            ),
                            decoration: const InputDecoration(
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53E3E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: _isLoading ? null : _signIn,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
