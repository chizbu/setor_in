import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'app_theme.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'resetpassword_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleMasuk() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final result = await ApiService().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Email atau kata sandi belum sesuai.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final horizontal = constraints.maxWidth > 600 ? 72.0 : 22.0;
          final heroHeight = constraints.maxWidth > 700 ? 220.0 : 188.0;
          final illustrationWidth = constraints.maxWidth > 700 ? 280.0 : 190.0;
          return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                height: heroHeight,
                padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
                decoration: const BoxDecoration(
                  color: kPrimaryDark,
                ),
                child: Stack(clipBehavior: Clip.hardEdge, children: [
                  Positioned(
                    right: -34,
                    top: -70,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: .08)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -12,
                    bottom: -22,
                    width: illustrationWidth,
                    height: heroHeight * .86,
                    child: Image.asset(
                      'assets/images/setor_story_illustration.webp',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.eco_rounded, color: Color(0xFFDDE5C9), size: 15.3),
                      const SizedBox(width: 6),
                      const Text('SETOR.IN', style: TextStyle(
                          color: Colors.white, fontSize: 11.2,
                          fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                      const Spacer(),
                      const Text('RUMAH HIJAU', style: TextStyle(
                          color: Color(0xFFDDE5C9), fontSize: 11.2,
                          fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                    ]),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(right: 112),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('NASABAH RUMAH HIJAU', style: TextStyle(
                            color: Color(0xFFDDE5C9), fontSize: 11.2,
                            fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                        SizedBox(height: 5),
                        Text('Sampah terpilah.\nNilai yang berarti.', style: TextStyle(
                            color: Colors.white, fontSize: 22, height: 1.08,
                            fontWeight: FontWeight.w800, letterSpacing: -.35)),
                      ]),
                    ),
                  ]),
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 22, horizontal, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Form(
                      key: _formKey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const Text('AKUN SETOR.IN', style: TextStyle(
                            color: kPrimary, fontSize: 11.2,
                            fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        const SizedBox(height: 5),
                        const Text('Masuk kembali', style: TextStyle(
                            color: kText, fontSize: 24.2,
                            fontWeight: FontWeight.w800, letterSpacing: -.4)),
                        const SizedBox(height: 3),
                        const Text('Lanjutkan langkah baikmu hari ini.',
                            style: TextStyle(color: kTextSoft, fontSize: 13.8)),
                        const SizedBox(height: 18),
                        const _AuthLabel('Email'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          decoration: const InputDecoration(
                            hintText: 'nama@email.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded, size: 21.2),
                          ),
                          validator: (value) {
                            final email = (value ?? '').trim();
                            if (email.isEmpty) return 'Email wajib diisi.';
                            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                              return 'Periksa kembali format email.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 13),
                        const _AuthLabel('Kata sandi'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleMasuk(),
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            hintText: 'Masukkan kata sandi',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 21.2),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                          validator: (value) => (value ?? '').isEmpty ? 'Kata sandi wajib diisi.' : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5)),
                            child: const Text('Lupa kata sandi?', style: TextStyle(fontSize: 13.8)),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 46,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _handleMasuk,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text('Masuk'), SizedBox(width: 7), Icon(Icons.arrow_forward_rounded, size: 18.9),
                                  ]),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text('Belum punya akun? ', style: TextStyle(color: kTextSoft, fontSize: 13.8)),
                          TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen())),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                            child: const Text('Daftar', style: TextStyle(fontSize: 13.8, fontWeight: FontWeight.w800)),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }
}

class _AuthLabel extends StatelessWidget {
  const _AuthLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(
            color: kText, fontSize: 12.5, fontWeight: FontWeight.w700)),
      );
}
