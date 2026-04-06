import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add provider to pubspec.yaml
import 'package:attendify/Theme/appTheme.dart';
import 'package:attendify/util/appRoutes.dart';
import 'package:attendify/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendify',
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: appRoutes.loginPage,
      onGenerateRoute: appRoutes.generateRoute,
    );
  }
}