import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/load_page.dart';
import 'screens/login_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/inventory_page.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raffli Motor',
      theme: ThemeData(useMaterial3: true),
      home: const LoadPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(username: ''), // 🔹 route dashboard
        '/inventory': (context) => const InventoryPage(),              // 🔹 route inventory
      },
    );
  }
}

