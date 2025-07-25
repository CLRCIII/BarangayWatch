import 'package:endterm_barangay/providers/auth_provider.dart';
import 'package:endterm_barangay/providers/report_provider.dart';
import 'package:endterm_barangay/screens/login_screen.dart';
import 'package:endterm_barangay/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BarangayWatchApp());
}

class BarangayWatchApp extends StatelessWidget {
  const BarangayWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(home: RegisterScreen()),
    );
  }
}
