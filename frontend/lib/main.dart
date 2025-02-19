import 'package:flutter/material.dart';
import 'utils/shared_preference_helpert.dart';
import 'apps/welcome_screen.dart';
import 'apps/splash_screen.dart'; // Using BlankScreen as home screen for now
import 'pages/chat_page.dart';
import 'pages/status_page.dart';
import 'pages/community_page.dart';
import 'pages/call_page.dart';
import 'pages/message_page.dart';
import 'apps/setting_widget.dart';
import 'apps/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if userId is stored
  String? userId = await SharedPreferencesHelper.getUserId();

  runApp(MyApp(initialRoute: userId != null ? '/home' : '/register'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ngobar App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4D8FAC),
          secondary: Color(0xFF88C1E4),
        ),
        scaffoldBackgroundColor: const Color(0xFFE5F3FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF274766),
          secondary: Color(0xFF396882),
        ),
        scaffoldBackgroundColor: const Color(0xFF1E2A3A),
      ),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: {
        '/register': (context) => const WelcomeScreen(),
        '/home': (context) => const SplashScreen(), // Using BlankScreen temporarily
        '/dashboard': (context) => const DashboardScreen(),
        '/chat': (context) => const ChatPage(),
        '/message': (context) => const MessagePage(recipientName: ''),
        '/status': (context) => const StatusPage(),
        '/community': (context) => const CommunityPage(),
        '/call': (context) => const CallPage(),
        '/setting': (context) => const SettingWidget(),
      },
    );
  }
}
