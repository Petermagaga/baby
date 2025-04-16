import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pregnancy_tracker_screen.dart';
import 'screens/community_screen.dart';
import 'screens/find_friend_screen.dart' as friend;
import 'screens/chat_screen.dart' as chat;
import 'screens/baby_tracker_screen.dart';
import 'screens/immunization_screen.dart';
import 'screens/update_baby_weight_screen.dart';


Map<String, WidgetBuilder> routes = {
  '/login': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/profile-setup': (context) => ProfileSetupScreen(),
  '/dashboard': (context) => DashboardScreen(),
  '/home': (context) => HomeScreen(),
  '/tracker': (context) => PregnancyTrackerScreen(),
  '/community': (context) => CommunityScreen(),
  '/find_friend': (context) => friend.FindFriendScreen(),
  '/chat': (context) => chat.ChatScreen(groupTitle: "Discussion Group"),

  '/baby_tracker': (context) => BabyTrackerScreen(),
  '/immunization': (context) => ImmunizationScreen(),
  '/update_baby_weight': (context) => UpdateBabyWeightScreen(),  

};
