import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.delete_sweep_rounded,
      'iconColor': kPrimary,
      'bgColor': Color(0xFFE8F8EF),
      'title': 'Pilah & Setor Sampah',
      'description': 'Kumpulkan dan pilah sampah rumah tanggamu, lalu setorkan ke mitra Bank Sampah Setor.in terdekat dari lokasimu.',
    },
    {
      'icon': Icons.monetization_on_rounded,
      'iconColor': Colors.amber.shade600,
      'bgColor': Color(0xFFFEF3C7),
      'title': 'Kumpulkan Koin Reward',
      'description': 'Setiap kilogram sampah yang disetor akan ditimbang oleh petugas dan dikonversi langsung menjadi koin emas di akunmu.',
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'iconColor': Colors.blue.shade600,
      'bgColor': Color(0xFFDBEAFE),
      'title': 'Tukar Saldo Rupiah',
      'description': 'Tukarkan koin emasmu menjadi saldo Rupiah secara instan, lalu tarik ke rekening bank atau e-wallet pilihanmu kapan saja.',
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 16),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    isLastPage ? '' : 'Lewati',
                    style: const TextStyle(
                      color: kTextSoft,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),

            // PageView Slider Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: slide['bgColor'],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              slide['icon'],
                              size: 90,
                              color: slide['iconColor'],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // Slide Title
                        Text(
                          slide['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kText,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Slide Description
                        Text(
                          slide['description'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.6,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? kPrimary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
