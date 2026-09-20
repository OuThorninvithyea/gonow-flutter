import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
    context.go(isAuthenticated ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, // Hidden on splash — no title needed
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 336 / 430,
          child: AspectRatio(
            aspectRatio: 1,
            child: Lottie.asset(
              'assets/animations/gonow_splash.lottie',
              repeat: false,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
