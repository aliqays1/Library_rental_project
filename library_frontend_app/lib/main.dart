import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/faq_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. AuthProvider manages user state (login/logout/id)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // 2. BookProvider now "listens" to AuthProvider.
        // Whenever AuthProvider updates (like after login), 
        // it pushes the email and username into BookProvider.
        ChangeNotifierProxyProvider<AuthProvider, BookProvider>(
          create: (_) => BookProvider(),
          update: (_, auth, bookProvider) {
            // This is the bridge that fixes your "My Rentals" empty screen issue
            return bookProvider!..setUserData(
              auth.user?['email'], 
              auth.user?['username'],
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibraRead',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // The app starts at the Login Screen
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigation(),
        '/faq': (context) => const FAQScreen(),
      },
    );
  }
}