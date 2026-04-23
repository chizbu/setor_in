import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_theme.dart';
import 'user_data.dart';

class EditProfilScreen extends StatefulWidget {
  final UserData userData;
  const EditProfilScreen({super.key, required this.userData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _noTelponController;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _fotoSementara;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData.nama);
    _emailController = TextEditingController(text: widget.userData.email);
    _noTelponController = TextEditingController(text: widget.userData.noTelpon);
    _fotoSementara = widget.userData.fotoProfil;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelponController.dispose();
    super.dispose();
  }

  void _showFotoBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Foto Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 20)),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.black54, size: 24),
              title: const Text('Kamera', style: TextStyle(fontSize: 15, color: Colors.black87)),
              onTap: () async { Navigator.pop(ctx); await _ambilFoto(ImageSource.camera); },
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.image_outlined, color: Colors.black54, size: 24),
              title: const Text('Galeri', style: TextStyle(fontSize: 15, color: Colors.black87)),
              onTap: () async { Navigator.pop(ctx); await _ambilFoto(ImageSource.gallery); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _ambilFoto(ImageSource source) async {
    try {
      final XFile? foto = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 800, maxHeight: 800);
      if (foto != null && mounted) {
        setState(() => _fotoSementara = File(foto.path));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal ambil foto: $e')));
    }
  }

  Future<void> _handleSimpan() async {
    if (_formKey.currentState!.validate()) {
      widget.userData.nama = _namaController.text.trim();
      widget.userData.email = _emailController.text.trim();
      widget.userData.noTelpon = _noTelponController.text.trim();
      widget.userData.fotoProfil = _fotoSementara;
      await widget.userData.simpan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui'),
            backgroundColor: kPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: const Icon(Icons.chevron_left, size: 24, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Edit Profil',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _fotoSementara != null ? FileImage(_fotoSementara!) : null,
                            child: _fotoSementara == null
                                ? Icon(Icons.person, size: 56, color: Colors.grey.shade400)
                                : null,
                          ),
                          GestureDetector(
                            onTap: _showFotoBottomSheet,
                            child: Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Ketuk ikon kamera untuk ganti foto',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(height: 28),

                      _buildLabel('Nama'),
                      _buildTextField(
                        controller: _namaController,
                        hint: 'Masukan nama',
                        icon: Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Email'),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Masukan email',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                          final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!regex.hasMatch(v)) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Nomor Telpon'),
                      _buildTextField(
                        controller: _noTelponController,
                        hint: 'Masukan nomor telpon',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'Nomor telpon tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleSimpan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Simpan Perubahan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kPrimary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
      ),
      validator: validator,
    );
  }
}