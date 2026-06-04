import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'app_theme.dart';

/// Halaman proses & sukses penukaran koin.
/// Menampilkan animasi "sedang memproses" selama [processingDuration],
/// lalu transisi ke tampilan sukses dengan detail transaksi.
class TukarKoinSuccessScreen extends StatefulWidget {
  final int koinDitukar;
  final int saldoDidapat;
  final int sisaKoin;

  const TukarKoinSuccessScreen({
    super.key,
    required this.koinDitukar,
    required this.saldoDidapat,
    required this.sisaKoin,
  });

  @override
  State<TukarKoinSuccessScreen> createState() =>
      _TukarKoinSuccessScreenState();
}

class _TukarKoinSuccessScreenState extends State<TukarKoinSuccessScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = true;

  // Animasi processing (spin + pulse)
  late AnimationController _spinCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Animasi success
  late AnimationController _successCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  // Confetti particles
  late AnimationController _confettiCtrl;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // ── Processing Animations ──
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── Success Animations (dimulai nanti) ──
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successCtrl,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _successCtrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // ── Confetti ──
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _generateParticles();

    // Simulasi proses selesai setelah delay
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _transitionToSuccess();
    });
  }

  void _generateParticles() {
    final rng = Random();
    final colors = [
      kPrimary,
      kAccent,
      kWarning,
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];
    for (int i = 0; i < 40; i++) {
      _particles.add(_ConfettiParticle(
        x: rng.nextDouble(),
        y: -0.1 - rng.nextDouble() * 0.3,
        size: 4 + rng.nextDouble() * 6,
        speed: 0.3 + rng.nextDouble() * 0.7,
        drift: (rng.nextDouble() - 0.5) * 0.3,
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextDouble() - 0.5) * 4,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  void _transitionToSuccess() {
    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = false);
    _spinCtrl.stop();
    _pulseCtrl.stop();
    _successCtrl.forward();
    _confettiCtrl.forward();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F8EF),
                    Colors.white,
                    Colors.white,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Confetti overlay (hanya saat sukses)
            if (!_isProcessing)
              AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (context, _) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _confettiCtrl.value,
                    ),
                  );
                },
              ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _isProcessing
                      ? _buildProcessingView()
                      : _buildSuccessView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PROCESSING VIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProcessingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated spinner with coin icon
        ScaleTransition(
          scale: _pulseAnim,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Spinning ring
                RotationTransition(
                  turns: _spinCtrl,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 4,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _SpinnerPainter(
                        progress: _spinCtrl,
                      ),
                    ),
                  ),
                ),
                // Inner circle with coin icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9146), Color(0xFF26D077)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Title
        const Text(
          'Memproses Penukaran...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Menukar ${widget.koinDitukar} koin ke saldo',
          style: const TextStyle(
            fontSize: 14,
            color: kTextSoft,
          ),
        ),
        const SizedBox(height: 32),

        // Progress info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kPrimaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPrimary.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              _processingInfoRow(
                Icons.monetization_on_rounded,
                'Koin ditukar',
                '${widget.koinDitukar} Koin',
                kWarning,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: kPrimary.withValues(alpha: 0.1),
                ),
              ),
              _processingInfoRow(
                Icons.account_balance_wallet_outlined,
                'Saldo didapat',
                'Rp ${_fmt(widget.saldoDidapat)}',
                kPrimary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Animated dots
        _AnimatedDots(),
      ],
    );
  }

  Widget _processingInfoRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: kTextSoft),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SUCCESS VIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSuccessView() {
    return AnimatedBuilder(
      animation: _successCtrl,
      builder: (context, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon with animation
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9146), Color(0xFF26D077)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Title
            Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnim.value),
                child: const Text(
                  'Penukaran Berhasil!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnim.value),
                child: const Text(
                  'Koin kamu telah berhasil ditukar ke saldo',
                  style: TextStyle(fontSize: 14, color: kTextSoft),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Result card
            Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnim.value * 0.6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9146), Color(0xFF26D077)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Detail Transaksi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _resultColumn(
                            Icons.monetization_on_rounded,
                            '-${widget.koinDitukar}',
                            'Koin Ditukar',
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: Colors.white24,
                          ),
                          _resultColumn(
                            Icons.account_balance_wallet_outlined,
                            '+Rp ${_fmt(widget.saldoDidapat)}',
                            'Saldo Didapat',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detail breakdown
            Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnim.value * 0.4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _detailRow(
                        'Koin Ditukar',
                        '${widget.koinDitukar} Koin',
                        kWarning,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      _detailRow(
                        'Saldo Didapat',
                        'Rp ${_fmt(widget.saldoDidapat)}',
                        kPrimary,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      _detailRow(
                        'Sisa Koin',
                        '${widget.sisaKoin} Koin',
                        kText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Action buttons
            Opacity(
              opacity: _fadeAnim.value,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        // Pop semua sampai ke root (Beranda/Dashboard)
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        // Pop hanya halaman ini, kembali ke Keuangan
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kPrimary.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Tukar Koin Lagi',
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _resultColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ANIMATED DOTS (loading indicator)
// ═══════════════════════════════════════════════════════════════
class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_ctrl.value - delay).clamp(0.0, 1.0);
            final y = sin(t * pi) * -8;
            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.3 + t * 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SPINNER PAINTER
// ═══════════════════════════════════════════════════════════════
class _SpinnerPainter extends CustomPainter {
  final AnimationController progress;

  _SpinnerPainter({required this.progress}) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Track
    final trackPaint = Paint()
      ..color = kPrimary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(2), 0, 2 * pi, false, trackPaint);

    // Active arc
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0x00179B49),
          Color(0xFF0D9146),
          Color(0xFF26D077),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(2), -pi / 2, pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════
//  CONFETTI
// ═══════════════════════════════════════════════════════════════
class _ConfettiParticle {
  double x, y, size, speed, drift, rotation, rotationSpeed;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = p.y + progress * p.speed * 1.4;
      final currentX = p.x + sin(progress * pi * 2 + p.drift * 10) * 0.05;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      if (currentY > 1.2 || opacity <= 0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX * size.width, currentY * size.height);
      canvas.rotate(p.rotation + progress * p.rotationSpeed);

      // Draw small rectangle confetti
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
