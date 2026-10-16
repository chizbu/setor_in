import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'app_theme.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _alamat = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _loading = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _phone.dispose();
    _alamat.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final email = _email.text.trim();
    final result = await ApiService().register(
      nama: _nama.text.trim(),
      email: email,
      alamat: _alamat.text.trim(),
      password: _password.text,
      passwordConfirmation: _confirmation.text,
      noTelepon: _phone.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => OtpScreen(email: email, source: 'register')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['message']?.toString() ?? 'Registrasi belum berhasil.'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  String? _required(String? value, String field) =>
      (value ?? '').trim().isEmpty ? '$field wajib diisi.' : null;

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    bool obscure = false,
    VoidCallback? toggle,
    int minLines = 1,
    int maxLines = 1,
    TextCapitalization capitalization = TextCapitalization.none,
  }) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: label, style: const TextStyle(color: kText, fontSize: 12.5, fontWeight: FontWeight.w700)),
              const TextSpan(text: ' *', style: TextStyle(color: kDanger, fontSize: 12.5)),
            ])),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            textCapitalization: capitalization,
            obscureText: obscure,
            minLines: minLines,
            maxLines: maxLines,
            validator: validator ?? (value) => _required(value, label),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 18.9),
              alignLabelWithHint: maxLines > 1,
              suffixIcon: toggle == null ? null : IconButton(
                tooltip: obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                onPressed: toggle,
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 21.2),
              ),
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 600 ? 70.0 : 20.0;
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 7, horizontal, 0),
                  child: Row(children: [
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: () => Navigator.maybePop(context),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back, size: 23.6),
                    ),
                    const Spacer(),
                    const Text('RUMAH HIJAU', style: TextStyle(
                        color: kTextSoft, fontSize: 11.2,
                        fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ]),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontal, 3, horizontal, 28),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Form(
                        key: _formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          _signupBanner(),
                          const SizedBox(height: 12),
                          const Text('Buat akun Setor.in', style: TextStyle(
                              color: kText, fontSize: 19.8, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          const Text('Daftar sebagai nasabah Rumah Hijau. Email dipakai untuk verifikasi OTP.',
                              style: TextStyle(color: kTextSoft, fontSize: 12.5, height: 1.4)),
                          const SizedBox(height: 14),
                          _field(label: 'Nama lengkap', controller: _nama, hint: 'Nama sesuai identitas', icon: Icons.person_outline_rounded, capitalization: TextCapitalization.words),
                          _field(label: 'Nomor HP', controller: _phone, hint: 'Contoh: 08xxxxxxxxxx', icon: Icons.phone_outlined, keyboard: TextInputType.phone, validator: (value) {
                            final number = (value ?? '').replaceAll(RegExp(r'\D'), '');
                            if (number.isEmpty) return 'Nomor HP wajib diisi.';
                            if (number.length < 9 || number.length > 15) return 'Periksa kembali nomor HP.';
                            return null;
                          }),
                          _field(label: 'Alamat', controller: _alamat, hint: 'Alamat tempat tinggal', icon: Icons.location_on_outlined, minLines: 2, maxLines: 2, capitalization: TextCapitalization.sentences),
                          _field(label: 'Email', controller: _email, hint: 'nama@email.com', icon: Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress, validator: (value) {
                            final email = (value ?? '').trim();
                            if (email.isEmpty) return 'Email wajib diisi.';
                            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) return 'Format email belum valid.';
                            return null;
                          }),
                          _field(label: 'Kata sandi', controller: _password, hint: 'Minimal 8 karakter', icon: Icons.lock_outline_rounded, obscure: _hidePassword, toggle: () => setState(() => _hidePassword = !_hidePassword), validator: (value) {
                            if ((value ?? '').isEmpty) return 'Kata sandi wajib diisi.';
                            if (value!.length < 8) return 'Minimal 8 karakter.';
                            return null;
                          }),
                          _field(label: 'Konfirmasi kata sandi', controller: _confirmation, hint: 'Ulangi kata sandi', icon: Icons.lock_outline_rounded, obscure: _hideConfirmation, toggle: () => setState(() => _hideConfirmation = !_hideConfirmation), validator: (value) {
                            if ((value ?? '').isEmpty) return 'Konfirmasi wajib diisi.';
                            if (value != _password.text) return 'Kata sandi belum sama.';
                            return null;
                          }),
                          const SizedBox(height: 2),
                          SizedBox(height: 46, child: FilledButton(
                            onPressed: _loading ? null : _register,
                            child: _loading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Daftar dan lanjutkan'), SizedBox(width: 7), Icon(Icons.arrow_forward_rounded, size: 18.9)]),
                          )),
                          const SizedBox(height: 9),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('Sudah punya akun? ', style: TextStyle(color: kTextSoft, fontSize: 12.5)),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 3)),
                              child: const Text('Masuk', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                            ),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ]);
          }),
        ),
      );

  Widget _signupBanner() => Container(
        height: 92,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: kPrimaryDark, borderRadius: BorderRadius.circular(13)),
        child: Stack(children: [
          Positioned(right: -4, bottom: -18, width: 135, height: 102,
              child: Image.asset('assets/images/setor_story_illustration.webp', fit: BoxFit.contain, alignment: Alignment.bottomRight)),
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 15, 125, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('MULAI DI SINI', style: TextStyle(color: Color(0xFFDDE5C9), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              SizedBox(height: 5),
              Text('Kebiasaan baik,\nbermula dari rumah.', style: TextStyle(color: Colors.white, fontSize: 16.1, height: 1.08, fontWeight: FontWeight.w800)),
            ]),
          ),
        ]),
      );
}
