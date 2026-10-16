import 'package:flutter/material.dart';

import 'app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Fitur reset kata sandi belum tersedia karena backend belum memiliki endpoint OTP reset.'),
      duration: Duration(seconds: 5),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 600 ? 72.0 : 22.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Align(alignment: Alignment.centerLeft, child: IconButton(
                        tooltip: 'Kembali',
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.arrow_back, size: 23.6),
                      )),
                      const SizedBox(height: 10),
                      Container(
                        height: 34,
                        decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(9)),
                        child: const Center(child: Icon(Icons.eco_rounded, color: kPrimary, size: 18.9)),
                      ),
                      const SizedBox(height: 13),
                      const Text('BANTUAN AKUN', style: TextStyle(color: kPrimary, fontSize: 11.2, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                      const SizedBox(height: 5),
                      const Text('Lupa kata sandi?', style: TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -.3)),
                      const SizedBox(height: 4),
                      const Text('Masukkan email akunmu untuk memulai pemulihan akses.', style: TextStyle(color: kTextSoft, fontSize: 13.8, height: 1.4)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(color: const Color(0xFFF4EEDF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5DDC9))),
                        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(Icons.info_outline_rounded, color: kWarning, size: 17.7),
                          SizedBox(width: 7),
                          Expanded(child: Text('Fitur reset kata sandi belum tersedia karena backend belum memiliki endpoint OTP reset. Kata sandi tidak akan diubah dari layar ini.', style: TextStyle(color: kTextSoft, fontSize: 11.2, height: 1.4))),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      const Padding(padding: EdgeInsets.only(bottom: 5), child: Text('Email', style: TextStyle(color: kText, fontSize: 12.5, fontWeight: FontWeight.w700))),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'nama@email.com', prefixIcon: Icon(Icons.mail_outline_rounded, size: 20.1)),
                        validator: (value) {
                          final email = (value ?? '').trim();
                          if (email.isEmpty) return 'Email wajib diisi.';
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) return 'Format email tidak valid.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 13),
                      SizedBox(height: 46, child: FilledButton(onPressed: _handleNext, child: const Text('Periksa ketersediaan'))),
                    ]),
                  ),
                ),
              ),
            );
          }),
        ),
      );
}
