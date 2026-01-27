import 'package:flutter/material.dart';
import 'package:hilo/main.dart'; // Import for MyHomePage if needed, or define route
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading or wait for data
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Dice Tracker'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background
      body: Stack(
        children: [
          // Centered Content (Logo + Title)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.blue.withOpacity(0.3),
                    //     blurRadius: 20,
                    //     offset: const Offset(0, 10),
                    //   ),
                    // ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/d_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'Dice Tracker',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900, // Extra bold
                    color: Color(0xFF0F172A), // Dark slate/black
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Loading Indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'LOADING ...',
                  style: TextStyle(
                    color: Color(0xFF3B82F6), // Blue
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 150,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2), // Track color
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B82F6),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
