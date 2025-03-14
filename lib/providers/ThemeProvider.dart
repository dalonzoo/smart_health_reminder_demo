import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = AppTheme.lightTheme;

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    _themeData = _themeData == AppTheme.lightTheme
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
    notifyListeners(); // Notifica il cambiamento a tutta l'app
  }
}
