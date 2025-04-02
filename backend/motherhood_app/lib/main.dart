import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pregnancy_tracker_screen.dart';
import 'screens/community_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/health_insights_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/immunization_screen.dart';
import 'screens/baby_tracker_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/emergency_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pregnancy & Motherhood App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/pregnancy-tracker': (context) => const PregnancyTrackerScreen(),
        '/community': (context) => CommunityScreen(),
        '/dashboard': (context) => const UserDashboardScreen(),
        '/health-insights': (context) => HealthInsightsScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/immunization': (context) => ImmunizationScreen(),
        '/baby-tracker': (context) => BabyTrackerScreen(),
        '/faq': (context) => FAQScreen(),
        '/emergency':(context) =>EmergencyScreen()
        
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/profile") {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => ProfileScreen(
              toggleTheme: (args is Map<String, dynamic> && args.containsKey("toggleTheme"))
                  ? args["toggleTheme"]
                  : (mode) {}, // Default function if toggleTheme is missing
            ),
          );
        }
        return null;
      },
    );
  }
}

/// ✅ **Checks if user is logged in or not**
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user == null ? LoginScreen() : const HomeScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
