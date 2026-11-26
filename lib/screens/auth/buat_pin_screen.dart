import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'app_theme.dart';
import 'user_data.dart';

class BuatPinScreen extends StatefulWidget {
  const BuatPinScreen({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<BuatPinScreen> createState() => _BuatPinScreenState();
}

class _BuatPinScreenState extends State<BuatPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 6;

  int _step = 1;
  String _pinLama = '';
  String _pinBaru = '';
  String _pinKonfirmasi = '';
  bool _isLoading = false;
  String? _errorMsg;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _step = widget.isEdit ? 0 : 1;

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnim = Tween<double>(
      begin: 0,
      end: 12,
    ).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  String get _currentPin {
    if (_step == 0) return _pinLama;
    if (_step == 1) return _pinBaru;
    return _pinKonfirmasi;
  }

  String get _title {
    if (_step == 0) return 'Masukkan PIN lama';
    if (_step == 1) return 'Masukkan PIN baru';
    return 'Konfirmasi PIN baru';
  }

  String get _subtitle {
    if (_step == 0) {
      return 'Verifikasi PIN saat ini untuk melanjutkan';
    }

    if (_step == 1) {
      return 'Buat PIN 6 digit untuk keamanan transaksi';
    }

    return 'Masukkan ulang PIN baru Anda';
  }

  void _onKey(String key) {
    if (_isLoading) return;

    setState(() => _errorMsg = null);

    if (key == 'DEL') {
      setState(() {
        if (_step == 0 && _pinLama.isNotEmpty) {
          _pinLama = _pinLama.substring(0, _pinLama.length - 1);
        } else if (_step == 1 && _pinBaru.isNotEmpty) {
          _pinBaru = _pinBaru.substring(0, _pinBaru.length - 1);
        } else if (_step == 2 && _pinKonfirmasi.isNotEmpty) {
          _pinKonfirmasi =
              _pinKonfirmasi.substring(0, _pinKonfirmasi.length - 1);
        }
      });

      return;
    }

    if (_currentPin.length >= _pinLength) return;

    setState(() {
      if (_step == 0) {
        _pinLama += key;
      } else if (_step == 1) {
        _pinBaru += key;
      } else {
        _pinKonfirmasi += key;
      }
    });

    if (_currentPin.length != _pinLength) return;

    if (_step == 0 || _step == 1) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _step++);
        }
      });
    } else {
      _validateAndSubmit();
    }
  }

  Future<void> _validateAndSubmit() async {
    if (_pinBaru != _pinKonfirmasi) {
      _shakeCtrl.forward(from: 0);

      setState(() {
        _errorMsg = 'PIN baru tidak cocok. Silakan ulangi.';
        _pinKonfirmasi = '';
        _step = 2;
      });

      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService().setPin(
      pin: _pinBaru,
      pinLama: widget.isEdit ? _pinLama : null,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final userData = UserData();

      userData.hasPin = true;
      await userData.simpan();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'PIN berhasil diubah.'
                : 'PIN berhasil dibuat.',
          ),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );

      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _errorMsg = (result['message'] ?? 'Gagal menyimpan PIN.').toString();
      _pinBaru = '';
      _pinKonfirmasi = '';
      _step = widget.isEdit ? 0 : 1;

      if (widget.isEdit) {
        _pinLama = '';
      }
    });
  }

  void _handleBack() {
    if (_isLoading) return;

    if (_step == 2) {
      setState(() {
        _step = 1;
        _pinKonfirmasi = '';
        _errorMsg = null;
      });
    } else if (_step == 1 && widget.isEdit) {
      setState(() {
        _step = 0;
        _pinBaru = '';
        _errorMsg = null;
      });
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Ubah PIN' : 'Buat PIN Transaksi',
        ),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Container(
              width: 72,
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
              ),
              decoration: const BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _step == 0
                    ? Icons.lock_outline
                    : Icons.vpn_key_outlined,
                color: kPrimaryDark,
                size: AppIconSize.xl,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kText,
                fontSize: AppTypography.title,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextSoft,
                fontSize: AppTypography.body,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeAnim.value * (_shakeCtrl.isAnimating ? 1 : 0),
                    0,
                  ),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  final filled = index < _currentPin.length;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    width: filled ? 16 : 14,
                    height: filled ? 16 : 14,
                    decoration: BoxDecoration(
                      color: filled ? kPrimary : kBorder,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kDanger,
                  fontSize: AppTypography.caption,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(
                  child: CircularProgressIndicator(
                    color: kPrimary,
                  ),
                ),
              )
            else
              _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _keyRow(['1', '2', '3']),
        const SizedBox(height: AppSpacing.sm),
        _keyRow(['4', '5', '6']),
        const SizedBox(height: AppSpacing.sm),
        _keyRow(['7', '8', '9']),
        const SizedBox(height: AppSpacing.sm),
        _keyRow(['', '0', 'DEL']),
      ],
    );
  }

  Widget _keyRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        if (key.isEmpty) {
          return const Expanded(
            child: SizedBox(height: 56),
          );
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
            ),
            child: Material(
              color: kSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                onTap: () => _onKey(key),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  height: 56,
                  child: Center(
                    child: key == 'DEL'
                        ? const Icon(
                            Icons.backspace_outlined,
                            color: kTextSoft,
                            size: AppIconSize.lg,
                          )
                        : Text(
                            key,
                            style: const TextStyle(
                              color: kText,
                              fontSize: AppTypography.title,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}