import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'app_theme.dart';
import 'login_screen.dart';
import 'new_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String source;
  const OtpScreen({super.key, required this.email, required this.source});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final masked = name.length <= 2 ? name : '${name.substring(0, 2)}${'*' * (name.length - 2)}';
    return '$masked@${parts[1]}';
  }

  Future<void> _handleConfirm() async {
    final otp = _controllers.map((controller) => controller.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan 6 digit kode OTP.')));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final result = await ApiService().verifyOtp(widget.email, otp);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      if (widget.source == 'register') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Akun berhasil diaktifkan. Silakan masuk.'),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
      } else if (widget.source == 'reset_password') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => NewPasswordScreen(email: widget.email, otp: otp)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text((result['message'] ?? 'Kode OTP belum sesuai.').toString()),
        backgroundColor: kDanger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Widget _buildOtpBox(int index) => TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 18.7, fontWeight: FontWeight.w800, color: kText),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: kSurface,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 600 ? 72.0 : 22.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Align(alignment: Alignment.centerLeft, child: IconButton(
                      tooltip: 'Kembali', onPressed: () => Navigator.pop(context),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back, size: 23.6, color: kText),
                    )),
                    const SizedBox(height: 12),
                    Container(height: 34, decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(9)), child: const Center(child: Icon(Icons.eco_rounded, color: kPrimary, size: 18.9))),
                    const SizedBox(height: 15),
                    Text(widget.source == 'register' ? 'VERIFIKASI AKUN' : 'BANTUAN AKUN', style: const TextStyle(color: kPrimary, fontSize: 11.2, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                    const SizedBox(height: 5),
                    const Text('Verifikasi kode OTP', style: TextStyle(color: kText, fontSize: 23.1, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text('Kami mengirim kode verifikasi ke ${_maskEmail(widget.email)}.', style: const TextStyle(color: kTextSoft, fontSize: 13.8, height: 1.45)),
                    const SizedBox(height: 21),
                    const Text('Masukkan kode OTP', style: TextStyle(color: kText, fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 9),
                    Row(children: List.generate(6, (index) => Expanded(child: Padding(
                      padding: EdgeInsets.only(right: index == 5 ? 0 : 6),
                      child: SizedBox(height: 48, child: _buildOtpBox(index)),
                    )))),
                    const SizedBox(height: 13),
                    const Text('Belum menerima OTP? Pengiriman ulang belum didukung oleh server saat ini.', style: TextStyle(color: kTextSoft, fontSize: 11.2, height: 1.4)),
                    const SizedBox(height: 19),
                    SizedBox(height: 46, child: FilledButton(
                      onPressed: _isLoading ? null : _handleConfirm,
                      child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Konfirmasi'),
                    )),
                  ]),
                ),
              ),
            );
          }),
        ),
      );
}
