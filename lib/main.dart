// lib/main.dart
import 'package:eventory/modles/user_model.dart';
import 'package:eventory/screnns/wrapper.dart';
import 'package:eventory/services/auth.dart';
import 'package:eventory/providers/theme_provider.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<UserModel?>.value(
          initialData: UserModel(uid: ""),
          value: AuthServices().user,
          catchError: (_, __) => null,
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider()..loadThemePrefs(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light().copyWith(
              primaryColor: const Color(0xffFF611A),
              colorScheme: ColorScheme.light().copyWith(
                primary: const Color(0xffFF611A),
                secondary: const Color(0xffFF9349),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xffFF611A)),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: const Color(0xffFF611A),
              colorScheme: ColorScheme.dark().copyWith(
                primary: const Color(0xffFF611A),
                secondary: const Color(0xffFF9349),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                elevation: 0,
                iconTheme: const IconThemeData(color: Color(0xffFF611A)),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const Wrapper(),
          );
        },
      ),
    );
  }
}