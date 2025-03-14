import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_health_reminder_demo/providers/ThemeProvider.dart';
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
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool darkModeEnabled = false;
  bool isDarkModeSet = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final SharedPreferences prefs = await _prefs;
    isDarkModeSet = prefs.containsKey('darkMode');

    setState(() {
      darkModeEnabled = prefs.getBool('darkMode') ?? false;

      if(isDarkModeSet){
        if(darkModeEnabled) {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        }
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Health Reminder',
      theme: Provider.of<ThemeProvider>(context).themeData,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

