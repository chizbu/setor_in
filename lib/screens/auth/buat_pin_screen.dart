import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'user_data.dart';
import '../../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
//  BUAT PIN SCREEN — Input PIN 2x (buat + konfirmasi)
// ══════════════════════════════════════════════════════════════

class BuatPinScreen extends StatefulWidget {
  const BuatPinScreen({super.key});

  @override
  State<BuatPinScreen> createState() => _BuatPinScreenState();
}

class _BuatPinScreenState extends State<BuatPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 6;

  String _pin1 = '';
  String _pin2 = '';
  bool _isStep2 = false;
  bool _isLoading = false;
  String? _errorMsg;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    setState(() => _errorMsg = null);

    if (_isStep2) {
      if (key == 'DEL') {
        if (_pin2.isNotEmpty) setState(() => _pin2 = _pin2.substring(0, _pin2.length - 1));
      } else if (_pin2.length < _pinLength) {
        setState(() => _pin2 += key);
        if (_pin2.length == _pinLength) _validateAndSubmit();
      }
    } else {
      if (key == 'DEL') {
        if (_pin1.isNotEmpty) setState(() => _pin1 = _pin1.substring(0, _pin1.length - 1));
      } else if (_pin1.length < _pinLength) {
        setState(() => _pin1 += key);
        if (_pin1.length == _pinLength) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _isStep2 = true);
          });
        }
      }
    }
  }

  Future<void> _validateAndSubmit() async {
    if (_pin1 != _pin2) {
      _shakeCtrl.forward(from: 0);
      setState(() {
        _errorMsg = 'PIN tidak cocok. Silakan ulangi.';
        _pin2 = '';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _isStep2 = false;
          _pin1 = '';
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService().setPin(pin: _pin1);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success']) {
      UserData().hasPin = true;
      await UserData().simpan();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('PIN berhasil dibuat! 🎉'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context, true); // return true = PIN berhasil dibuat
    } else {
      setState(() {
        _errorMsg = res['message'] ?? 'Gagal menyimpan PIN';
        _isStep2 = false;
        _pin1 = '';
        _pin2 = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isStep2 ? _pin2 : _pin1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          onPressed: () {
            if (_isStep2) {
              setState(() {
                _isStep2 = false;
                _pin2 = '';
                _errorMsg = null;
              });
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
        title: const Text('Buat PIN Transaksi',
            style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Spacer(flex: 1),

          // ── Icon ──
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isStep2 ? Icons.lock_outline : Icons.vpn_key_rounded,
              color: kPrimary,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ──
          Text(
            _isStep2 ? 'Konfirmasi PIN Baru' : 'Masukkan PIN Baru',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            _isStep2
                ? 'Masukkan ulang PIN 6 digit Anda'
                : 'Buat PIN 6 digit untuk keamanan transaksi',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),

          // ── Dots ──
          AnimatedBuilder(
            animation: _shakeAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(_shakeAnim.value * (_shakeCtrl.isAnimating ? 1 : 0), 0),
              child: child,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (i) {
                final filled = i < currentPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: filled ? 16 : 14,
                  height: filled ? 16 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? kPrimary : Colors.grey.shade300,
                    boxShadow: filled
                        ? [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)]
                        : null,
                  ),
                );
              }),
            ),
          ),

          // ── Error message ──
          if (_errorMsg != null) ...[
            const SizedBox(height: 16),
            Text(_errorMsg!,
                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
          ],

          const SizedBox(height: 32),

          // ── Keypad ──
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  CircularProgressIndicator(color: kPrimary),
                  const SizedBox(height: 16),
                  const Text('Menyimpan PIN...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _keyRow(['1', '2', '3']),
                  const SizedBox(height: 12),
                  _keyRow(['4', '5', '6']),
                  const SizedBox(height: 12),
                  _keyRow(['7', '8', '9']),
                  const SizedBox(height: 12),
                  _keyRow(['', '0', 'DEL']),
                ],
              ),
            ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _keyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox(width: 80, height: 60);
        return GestureDetector(
          onTap: () => _onKey(key),
          child: Container(
            width: 80,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: key == 'DEL'
                ? Icon(Icons.backspace_outlined, color: Colors.grey.shade700, size: 22)
                : Text(key,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
        );
      }).toList(),
    );
  }
}
