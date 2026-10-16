import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'login_screen.dart';

enum _Artwork { sorting, qr, growth }

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.label,
    required this.title,
    required this.description,
    required this.artwork,
  });

  final String label;
  final String title;
  final String description;
  final _Artwork artwork;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      label: 'LANGKAH 01  /  KEBIASAAN BARU',
      title: 'Pilah & Setor Sampah',
      description:
          'Bersihkan dan pilah sampah dari rumah, lalu bawa ke Rumah Hijau, mitra resmi Setor.in.',
      artwork: _Artwork.sorting,
    ),
    _OnboardingSlide(
      label: 'LANGKAH 02  /  SETOR DI MITRA',
      title: 'Tunjukkan QR Nasabah',
      description:
          'Petugas Rumah Hijau menimbang dan mencatat setoranmu. Nilainya menjadi saldo Rupiah setelah diverifikasi.',
      artwork: _Artwork.qr,
    ),
    _OnboardingSlide(
      label: 'LANGKAH 03  /  NILAI TERSIMPAN',
      title: 'Sampah jadi nilai',
      description:
          'Pantau saldo Rupiah dan riwayat setoranmu. Ajukan penukaran saldo melalui aplikasi saat sudah siap.',
      artwork: _Artwork.growth,
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _continue() {
    if (_isLastPage) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2E6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final isCompact = constraints.maxHeight < 680;
            final horizontalPadding = isWide
                ? (constraints.maxWidth * 0.055).clamp(32.0, 84.0).toDouble()
                : 24.0;
            final contentWidth = constraints.maxWidth - horizontalPadding * 2;
            final topGap = (isWide
                ? math.min(
                    constraints.maxHeight * (isCompact ? 0.06 : 0.12),
                    isCompact ? 40.0 : 112.0,
                  )
                : 18.0).toDouble();
            final heroHeight = (isWide
                ? math.min(
                    contentWidth / 2.95,
                    constraints.maxHeight * (isCompact ? 0.34 : 0.43),
                  )
                : math.min(
                    math.max(contentWidth * 0.76, 220.0),
                    constraints.maxHeight * 0.42,
                  )).toDouble();
            final contentGap = (isWide
                ? math.min(
                    constraints.maxHeight * (isCompact ? 0.08 : 0.14),
                    isCompact ? 48.0 : 116.0,
                  )
                : 28.0).toDouble();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(isWide),
                  SizedBox(height: topGap),
                  SizedBox(
                    height: heroHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) => _buildHero(
                        _slides[index],
                        isWide: isWide,
                      ),
                    ),
                  ),
                  SizedBox(height: contentGap),
                  _buildCopy(_slides[_currentPage], isWide: isWide),
                  const Spacer(),
                  _buildProgress(),
                  const SizedBox(height: 16),
                  _buildActionButton(isWide),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          const Icon(Icons.eco_rounded, size: 16.5, color: Color(0xFF63744D)),
          const SizedBox(width: 8),
          const Text(
            'SETOR.IN',
            style: TextStyle(
              color: Color(0xFF2D3527),
              fontSize: 13.8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
          const Spacer(),
          if (!_isLastPage)
            TextButton(
              onPressed: _finishOnboarding,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF46543A),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(48, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lewati',
                style: TextStyle(
                  fontSize: isWide ? 13 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHero(_OnboardingSlide slide, {required bool isWide}) {
    final isQr = slide.artwork == _Artwork.qr;
    final background = isQr
        ? const Color(0xFF34422F)
        : const Color(0xFFE5E7D4);

    return ClipRRect(
      borderRadius: BorderRadius.circular(isWide ? 18 : 16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: background),
          Positioned(
            top: -78,
            right: -74,
            child: Container(
              width: isWide ? 240 : 180,
              height: isWide ? 240 : 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isQr ? Colors.white : const Color(0xFF6B7658))
                      .withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 18,
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isQr ? const Color(0xFFDDE5C9) : const Color(0xFF66754F),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  isQr ? 'KARTU NASABAH' : 'KEBIASAAN BAIK',
                  style: TextStyle(
                    color: isQr ? const Color(0xFFE1E7D5) : const Color(0xFF3D4534),
                    fontSize: 11.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: isQr
                ? Container(
                    width: isWide ? 190 : 152,
                    height: isWide ? 190 : 152,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8EE),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      size: isWide ? 132 : 108,
                      color: const Color(0xFF34422F),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 38 : 18,
                      isWide ? 26 : 28,
                      isWide ? 38 : 18,
                      isWide ? 12 : 16,
                    ),
                    child: Image.asset(
                      slide.artwork == _Artwork.sorting
                          ? 'assets/images/recycling_guide_illustration.webp'
                          : 'assets/images/setor_story_illustration.webp',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopy(_OnboardingSlide slide, {required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slide.label,
          style: const TextStyle(
            color: Color(0xFF66724F),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          slide.title,
          style: TextStyle(
            color: const Color(0xFF252B21),
            fontSize: isWide ? 30 : 24,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slide.description,
          style: TextStyle(
            color: const Color(0xFF818477),
            fontSize: isWide ? 14 : 13,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    final progress = (_currentPage + 1) / _slides.length;
    final step = (_currentPage + 1).toString().padLeft(2, '0');

    return Row(
      children: [
        Text(
          step,
          style: const TextStyle(
            color: Color(0xFF3E4935),
            fontSize: 11.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFFD9DACC)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: const ColoredBox(color: Color(0xFF64764D)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '03',
          style: TextStyle(
            color: Color(0xFF6C725F),
            fontSize: 11.2,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isWide) {
    return SizedBox(
      height: isWide ? 54 : 52,
      child: FilledButton(
        onPressed: _continue,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF65784E),
          foregroundColor: const Color(0xFFF8F8EF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLastPage ? 'Mulai Sekarang' : 'Lanjut',
              style: const TextStyle(
                fontSize: 16.1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20.1),
          ],
        ),
      ),
    );
  }
}
