import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/simpanan_model.dart';
import '../models/pinjaman_model.dart';
import '../models/angsuran_model.dart';
import '../utils/formatters.dart';

class PdfService {
  Future<File> generateLaporanSimpanan({
    required List<SimpananModel> simpananList,
    required String namaKoperasi,
    required String periode,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    final totalSimpanan = simpananList.fold<double>(0, (sum, s) => sum + s.jumlah);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(namaKoperasi, 'LAPORAN SIMPANAN', periode, font, fontBold),
          pw.SizedBox(height: 20),
          pw.Text(
            'Periode: $periode',
            style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          _buildSimpananTable(simpananList, font, fontBold),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total Simpanan: ${Formatters.formatRupiah(totalSimpanan)}',
                style: pw.TextStyle(font: fontBold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );

    return await _savePdf('laporan_simpanan_$periode.pdf', pdf);
  }

  Future<File> generateLaporanPinjaman({
    required List<PinjamanModel> pinjamanList,
    required String namaKoperasi,
    required String periode,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    final totalPinjaman = pinjamanList.fold<double>(0, (sum, p) => sum + p.jumlah);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(namaKoperasi, 'LAPORAN PINJAMAN', periode, font, fontBold),
          pw.SizedBox(height: 20),
          pw.Text(
            'Periode: $periode',
            style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          _buildPinjamanTable(pinjamanList, font, fontBold),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total Pinjaman: ${Formatters.formatRupiah(totalPinjaman)}',
                style: pw.TextStyle(font: fontBold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );

    return await _savePdf('laporan_pinjaman_$periode.pdf', pdf);
  }

  Future<File> generateLaporanAngsuran({
    required List<AngsuranModel> angsuranList,
    required String namaKoperasi,
    required String periode,
  }) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    final totalDibayar = angsuranList
        .where((a) => a.status == 'lunas')
        .fold<double>(0, (sum, a) => sum + (a.dibayar ?? 0));
    final totalBelum = angsuranList
        .where((a) => a.status != 'lunas')
        .fold<double>(0, (sum, a) => sum + a.jumlah);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(namaKoperasi, 'LAPORAN ANGSURAN', periode, font, fontBold),
          pw.SizedBox(height: 20),
          _buildAngsuranTable(angsuranList, font, fontBold),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Dibayar: ${Formatters.formatRupiah(totalDibayar)}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.Text(
                    'Total Belum: ${Formatters.formatRupiah(totalBelum)}',
                    style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.red700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return await _savePdf('laporan_angsuran_$periode.pdf', pdf);
  }

  pw.Widget _buildHeader(
    String namaKoperasi,
    String title,
    String periode,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          namaKoperasi,
          style: pw.TextStyle(font: fontBold, fontSize: 20),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          title,
          style: pw.TextStyle(font: fontBold, fontSize: 16),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildSimpananTable(
    List<SimpananModel> data,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal700),
          children: [
            _tableCell('No', fontBold, white: true),
            _tableCell('Anggota', fontBold, white: true),
            _tableCell('Jenis', fontBold, white: true),
            _tableCell('Jumlah', fontBold, white: true),
            _tableCell('Tanggal', fontBold, white: true),
          ],
        ),
        ...data.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final s = entry.value;
          return pw.TableRow(
            children: [
              _tableCell('$i', font),
              _tableCell(s.userId, font),
              _tableCell(s.labelJenis, font),
              _tableCell(Formatters.formatRupiah(s.jumlah), font),
              _tableCell(Formatters.formatDate(s.tanggal ?? DateTime.now()), font),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPinjamanTable(
    List<PinjamanModel> data,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal700),
          children: [
            _tableCell('No', fontBold, white: true),
            _tableCell('Anggota', fontBold, white: true),
            _tableCell('Jumlah', fontBold, white: true),
            _tableCell('Tenor', fontBold, white: true),
            _tableCell('Status', fontBold, white: true),
          ],
        ),
        ...data.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final p = entry.value;
          return pw.TableRow(
            children: [
              _tableCell('$i', font),
              _tableCell(p.userId, font),
              _tableCell(Formatters.formatRupiah(p.jumlah), font),
              _tableCell('${p.tenor} bln', font),
              _tableCell(p.labelStatus, font),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildAngsuranTable(
    List<AngsuranModel> data,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal700),
          children: [
            _tableCell('No', fontBold, white: true),
            _tableCell('Angsuran Ke', fontBold, white: true),
            _tableCell('Jumlah', fontBold, white: true),
            _tableCell('Jatuh Tempo', fontBold, white: true),
            _tableCell('Status', fontBold, white: true),
          ],
        ),
        ...data.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final a = entry.value;
          return pw.TableRow(
            children: [
              _tableCell('$i', font),
              _tableCell('${a.angsuranKe}', font),
              _tableCell(Formatters.formatRupiah(a.jumlah), font),
              _tableCell(Formatters.formatDate(a.jatuhTempo), font),
              _tableCell(a.labelStatus, font),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableCell(String text, pw.Font font, {bool white = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          color: white ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  Future<File> _savePdf(String fileName, pw.Document pdf) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> openPdf(File file) async {
    await OpenFile.open(file.path);
  }
}
