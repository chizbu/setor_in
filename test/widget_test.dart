import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyek_2_setor_in/main.dart';
import 'package:proyek_2_setor_in/screens/auth/harga_sampah_screen.dart';
import 'package:proyek_2_setor_in/screens/auth/register_screen.dart';
import 'package:proyek_2_setor_in/screens/auth/setor_sampah_screen.dart';
import 'package:proyek_2_setor_in/screens/auth/dashboard_screen.dart';
import 'package:proyek_2_setor_in/screens/auth/chatbot_screen.dart';
import 'package:proyek_2_setor_in/screens/auth/user_data.dart';
import 'package:proyek_2_setor_in/screens/auth/profil_screen.dart';
import 'package:proyek_2_setor_in/screens/auth/tarik_saldo_screen.dart';
import 'package:proyek_2_setor_in/services/api_service.dart';
import 'package:proyek_2_setor_in/screens/auth/app_theme.dart';

void main() {
  test('API defaults to the requested production endpoint', () {
    expect(ApiService.baseUrl, 'https://setorin.my.id/api');
  });

  test('Saldo mapping preserves Rupiah zero and rejects legacy coin fields', () {
    expect(ApiService.extractSaldoTersedia({'saldo': 0}), 0);
    expect(ApiService.extractSaldoTersedia({'saldo': {'tersedia': 0}}), 0);
    expect(ApiService.extractSaldoTersedia({'saldo_rupiah': '1.000'}), '1.000');
    expect(ApiService.extractSaldoTersedia({'jumlah_saldo': 90000}), isNull);
  });

  test('Global AppBar titles and back icons use the shared header style', () {
    final theme = AppTheme.theme.appBarTheme;
    expect(theme.centerTitle, isFalse);
    expect(theme.toolbarHeight, 56);
    expect(theme.titleTextStyle?.fontSize, 18);
    expect(theme.iconTheme?.size, 24);
  });

  test('UserData persists profile photo bytes and pending-sync state', () async {
    SharedPreferences.setMockInitialValues({});
    final userData = UserData();
    userData.resetLoadFlag();
    userData
      ..nama = 'Nasabah Uji'
      ..fotoProfil = Uint8List.fromList([1, 2, 3, 4])
      ..profileNeedsSync = true;
    await userData.simpan();

    userData.resetLoadFlag();
    await userData.load();
    expect(userData.nama, 'Nasabah Uji');
    expect(userData.fotoProfil!.toList(), [1, 2, 3, 4]);
    expect(userData.profileNeedsSync, isTrue);
    userData.resetLoadFlag();
  });

  testWidgets('First launch shows the illustrated intro before onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('SETOR.IN'), findsOneWidget);
    expect(find.text('Pilahkan. Setorkan. Tumbuhkan.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Pilah & Setor Sampah'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Tunjukkan QR Nasabah'), findsOneWidget);
  });

  testWidgets('Harga screen reports missing API session and offers retry',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HargaSampahScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Harga sampah'), findsOneWidget);
    expect(find.text('Belum tersambung'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('Registration includes address and enforces PRD password length',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    expect(find.text('Alamat *'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Nama Uji');
    await tester.enterText(find.byType(TextFormField).at(1), '081234567890');
    await tester.enterText(find.byType(TextFormField).at(2), 'Jl. Contoh 1');
    await tester.enterText(find.byType(TextFormField).at(3), 'uji@example.com');
    await tester.enterText(find.byType(TextFormField).at(4), '1234567');
    await tester.enterText(find.byType(TextFormField).at(5), '1234567');
    final submit = find.text('Daftar dan lanjutkan');
    await tester.dragUntilVisible(
      submit,
      find.byType(CustomScrollView),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Minimal 8 karakter.'), findsOneWidget);
  });

  testWidgets('Dashboard never treats legacy balance as Proyek 3 balance',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Rp0'), findsOneWidget);
    expect(find.text('Saldo belum tersinkron'), findsNothing);
    expect(find.textContaining('Token tidak tersedia'), findsOneWidget);
    await tester.tap(find.byTooltip('Sembunyikan saldo'));
    await tester.pumpAndSettle();
    expect(find.text('Rp••••••'), findsOneWidget);
  });

  testWidgets('Tarik saldo shows provider grid and location-only cash discovery',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TarikSaldoScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tarik Saldo'), findsOneWidget);
    expect(find.text('Rp 0'), findsOneWidget);
    expect(find.text('Belum tersinkron'), findsNothing);
    expect(find.byKey(const ValueKey('payout-provider-BCA')), findsOneWidget);
    expect(find.byKey(const ValueKey('payout-provider-Mandiri')), findsOneWidget);
    expect(find.byKey(const ValueKey('payout-provider-DANA')), findsOneWidget);
    expect(find.byKey(const ValueKey('payout-provider-OVO')), findsOneWidget);
    expect(find.byKey(const ValueKey('payout-provider-GoPay')), findsOneWidget);
    expect(find.byKey(const ValueKey('payout-provider-ShopeePay')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('withdraw-mode-locations')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('cash-location-Agen tarik tunai')), findsOneWidget);
    expect(find.byKey(const ValueKey('cash-location-Alfamart')), findsOneWidget);
    expect(find.byKey(const ValueKey('cash-location-Indomaret')), findsOneWidget);
    expect(find.byKey(const ValueKey('cash-location-Bank Sampah Rumah Hijau')), findsOneWidget);
    expect(find.text('Tinjau detail'), findsNothing);
    expect(find.textContaining('tidak membuat permintaan tunai'), findsOneWidget);
  });

  testWidgets('Dashboard header uses the updated locally saved profile photo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final image = await rootBundle.load('assets/images/setobot-icon.png');
    final userData = UserData()..resetLoadFlag();
    userData
      ..nama = 'Foto Baru'
      ..fotoProfil = image.buffer.asUint8List(image.offsetInBytes, image.lengthInBytes)
      ..profileNeedsSync = true;
    await userData.simpan();

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Foto'), findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar).first);
    expect(avatar.backgroundImage, isA<MemoryImage>());
    userData.resetLoadFlag();
  });

  testWidgets('Profile account information is left aligned', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ProfilScreen()));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('NAMA LENGKAP'),
      find.byType(ListView).first,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    final label = tester.widget<Text>(find.text('NAMA LENGKAP'));
    expect(label.textAlign, TextAlign.left);
    final value = tester.widget<Text>(find.text('Belum dilengkapi').first);
    expect(value.textAlign, TextAlign.left);
  });

  testWidgets('Dashboard Lihat semua opens Aktivitas, not Riwayat Transaksi',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();
    final seeAll = find.text('Lihat semua');
    await tester.ensureVisible(seeAll);
    await tester.tap(seeAll);
    await tester.pumpAndSettle();
    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Riwayat transaksi'), findsNothing);
    expect(find.text('Membuka Aktivitas'), findsOneWidget);
  });

  testWidgets('QR card does not generate a code from the account ID',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: SetorSampahScreen()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('QR unik belum diterbitkan oleh server'),
        findsOneWidget);
    expect(
        find.textContaining('Kode tidak dibuat dari ID akun'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Chatbot states privacy and general-answer limitations',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ChatbotScreen()));
    await tester.pumpAndSettle();
    expect(find.text('SetoBot'), findsOneWidget);
    expect(find.textContaining('Jangan kirim email'), findsOneWidget);
    expect(find.textContaining('Saya bisa membantu tentang pemilahan'), findsOneWidget);
    expect(find.text('Tulis pertanyaan…'), findsOneWidget);
  });
}
