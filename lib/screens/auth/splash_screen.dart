import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'user_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeFromLaunch();
  }

  Future<void> _routeFromLaunch() async {
    // Keep the illustrated intro visible long enough to read, then continue
    // through the same first-run/authentication flow as before.
    await Future.delayed(const Duration(milliseconds: 2200));
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    if (prefs.getBool('isFirstRun') ?? true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      await UserData().load();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: Stack(
        children: [
          Positioned(
            top: -96,
            right: -92,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .07)),
              ),
            ),
          ),
          Positioned(
            left: -150,
            bottom: -140,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(width * .055, 18, width * .055, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.eco_rounded,
                              color: Color(0xFFE7E9D9), size: 22.4),
                          const SizedBox(width: 10),
                          const Text(
                            'SETOR.IN',
                            style: TextStyle(
                              color: Color(0xFFE7E9D9),
                              fontSize: 14.9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'RUMAH HIJAU',
                            style: TextStyle(
                              color: const Color(0xFFE7E9D9).withValues(alpha: .72),
                              fontSize: 11.2,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: SizedBox(
                            width: width * .9,
                            height: constraints.maxHeight * .57,
                            child: Image.asset(
                              'assets/images/setor_story_illustration.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Pilahkan. Setorkan. Tumbuhkan.',
                              maxLines: 1,
                              style: TextStyle(
                                color: const Color(0xFFF5F4E8),
                                fontSize: width < 390 ? 25 : 29,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sampah terpilah, nilai yang berarti.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFE7E9D9).withValues(alpha: .78),
                              fontSize: 14.9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 25),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Color(0xFFE7E9D9),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'Menyiapkan aplikasi',
                            style: TextStyle(
                              color: const Color(0xFFE7E9D9).withValues(alpha: .68),
                              fontSize: 13.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
