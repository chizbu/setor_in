import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_2_setor_in/screens/auth/prd_screens.dart';

void main() {
  test('format Rupiah mengikuti format Indonesia tanpa spasi setelah Rp', () {
    expect(rupiah(1800), 'Rp1.800');
    expect(rupiah('1250000'), 'Rp1.250.000');
    expect(rupiah(0), 'Rp0');
  });

  testWidgets('FAQ menampilkan jawaban saat pertanyaan dibuka', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FaqScreen()));
    expect(find.text('Sampah apa yang bisa disetor?'), findsOneWidget);
    await tester.tap(find.text('Sampah apa yang bisa disetor?'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Lihat halaman Harga untuk daftar jenis sampah aktif yang diterima Rumah Hijau.',
      ),
      findsOneWidget,
    );
  });
}
