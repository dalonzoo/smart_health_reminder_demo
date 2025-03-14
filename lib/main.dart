import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_health_reminder_demo/providers/gamification_provider.dart';
import 'package:smart_health_reminder_demo/providers/health_provider.dart';
import 'package:smart_health_reminder_demo/providers/reminder_provider.dart';
import 'package:smart_health_reminder_demo/providers/user_provider.dart';
import 'package:smart_health_reminder_demo/screens/home_screen.dart';
import 'package:smart_health_reminder_demo/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(prefs)),
        ChangeNotifierProvider(create: (_) => HealthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => GamificationProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ReminderProvider(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Health Reminder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

