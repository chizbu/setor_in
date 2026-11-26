import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_theme.dart';
import 'user_data.dart';
import '../../services/api_service.dart';

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
  late TextEditingController _alamatController;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoSementara;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData.nama);
    _emailController = TextEditingController(text: widget.userData.email);
    _noTelponController = TextEditingController(text: widget.userData.noTelpon);
    _alamatController = TextEditingController(text: widget.userData.alamat);
    _fotoSementara = widget.userData.fotoProfil;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelponController.dispose();
    _alamatController.dispose();
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Foto Profil',
                    style:
                        TextStyle(fontSize: AppTypography.subtitle, fontWeight: FontWeight.w700)),
                GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, size: AppIconSize.lg)),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Colors.black54, size: AppIconSize.lg),
              title: const Text('Kamera',
                  style: TextStyle(fontSize: AppTypography.bodyLarge, color: Colors.black87)),
              onTap: () async {
                Navigator.pop(ctx);
                await _ambilFoto(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.image_outlined,
                  color: Colors.black54, size: AppIconSize.lg),
              title: const Text('Galeri',
                  style: TextStyle(fontSize: AppTypography.bodyLarge, color: Colors.black87)),
              onTap: () async {
                Navigator.pop(ctx);
                await _ambilFoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _ambilFoto(ImageSource source) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 640,
        maxHeight: 640,
      );
      if (foto != null) {
        final bytes = await foto.readAsBytes();
        if (mounted && bytes.isNotEmpty) {
          setState(() => _fotoSementara = bytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil foto: $e')),
        );
      }
    }
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final noTelpon = _noTelponController.text.trim();
    final alamat = _alamatController.text.trim();

    widget.userData
      ..nama = nama
      ..email = email
      ..noTelpon = noTelpon
      ..alamat = alamat
      ..fotoProfil = _fotoSementara
      ..profileNeedsSync = true;
    await widget.userData.simpan();
    if (!mounted) return;

    final res = await ApiService().updateProfil({
      'nama': nama,
      'email': email,
      'no_telepon': noTelpon,
      'alamat': alamat,
    });

    if (res['success'] == true) {
      widget.userData.profileNeedsSync = false;
      await widget.userData.simpan();
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    final messenger = ScaffoldMessenger.of(context);
    final message = res['success'] == true
        ? 'Profil berhasil diperbarui.'
        : 'Perubahan profil tersimpan di perangkat. Server belum berhasil diperbarui.';
    final background = res['success'] == true ? kPrimary : kWarning;
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: AppIconSize.lg, color: kText),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontSize: AppTypography.subtitle,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 28),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _fotoSementara != null
                        ? MemoryImage(_fotoSementara!)
                        : null,
                    child: _fotoSementara == null
                        ? Icon(Icons.person,
                            size: 64, color: Colors.grey.shade400)
                        : null,
                  ),
                  GestureDetector(
                    onTap: _showFotoBottomSheet,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: AppIconSize.md, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Ketuk ikon kamera untuk ganti foto',
                  style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey.shade500)),
              const SizedBox(height: 28),
              _buildLabel('Nama lengkap'),
              _buildTextField(
                controller: _namaController,
                hint: 'Nama lengkap',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Email'),
              _buildTextField(
                controller: _emailController,
                hint: 'nama@email.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                  final regex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!regex.hasMatch(v)) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel('Nomor HP'),
              _buildTextField(
                controller: _noTelponController,
                hint: 'Nomor HP',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty
                    ? 'Nomor HP tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Alamat'),
              TextFormField(
                controller: _alamatController,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Alamat tempat tinggal',
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: Colors.grey),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: kSurface,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Alamat tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSimpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kPrimary.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Simpan Perubahan',
                          style: TextStyle(
                              fontSize: AppTypography.subtitle, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
            style: const TextStyle(
                fontSize: AppTypography.bodySmall,
            fontWeight: FontWeight.w800,
                color: kText)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: const TextStyle(fontSize: AppTypography.bodySmall, color: kText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: AppTypography.body),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: AppIconSize.lg),
        filled: true,
        fillColor: kSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDanger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDanger, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
