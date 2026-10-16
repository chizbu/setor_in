import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'ui_components.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const NewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _handleSubmit() {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua kolom.')));
      return;
    }
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi minimal 8 karakter.')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi belum sama.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Fitur reset kata sandi belum tersedia. Kata sandi tidak diubah.'),
    ));
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: const TextStyle(color: kText, fontSize: 12.5, fontWeight: FontWeight.w700))),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 13.8, color: kText),
          decoration: InputDecoration(
            hintText: 'Minimal 8 karakter',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20.1),
            suffixIcon: IconButton(
              tooltip: obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20.1),
              onPressed: onToggle,
            ),
          ),
        ),
      ]);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 600 ? 72.0 : 22.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 26),
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
                    const Text('BANTUAN AKUN', style: TextStyle(color: kPrimary, fontSize: 11.2, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                    const SizedBox(height: 5),
                    const Text('Buat kata sandi baru', style: TextStyle(color: kText, fontSize: 23.1, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    const Text('Kata sandi baru minimal 8 karakter.', style: TextStyle(color: kTextSoft, fontSize: 13.8)),
                    const SizedBox(height: 14),
                    const InlineNotice(message: 'Backend belum menyediakan endpoint reset kata sandi. Kata sandi tidak akan diubah dari layar ini.'),
                    const SizedBox(height: 17),
                    _passwordField(label: 'Kata sandi baru', controller: _passwordController, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
                    const SizedBox(height: 13),
                    _passwordField(label: 'Konfirmasi kata sandi', controller: _confirmController, obscure: _obscureConfirm, onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                    const SizedBox(height: 19),
                    SizedBox(height: 46, child: FilledButton(onPressed: _handleSubmit, child: const Text('Periksa ketersediaan'))),
                  ]),
                ),
              ),
            );
          }),
        ),
      );
}
