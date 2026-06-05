import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfService {
  // Generate Report PDF
  static Future<File> generateReportPdf({
    required String title,
    required String month,
    required int totalArizalar,
    required int bajarilganArizalar,
    required int korilmoqdaArizalar,
    required int totalMuammolar,
    required int halQilinganMuammolar,
    required Map<String, int> arizaByCategory,
    required Map<String, int> muammoByType,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Date
            pw.Text(
              'Sana: $month',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),

            // Arizalar statistikasi
            pw.Header(
              level: 1,
              child: pw.Text(
                'Arizalar statistikasi',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: ['Ko\'rsatkich', 'Soni'],
              data: [
                ['Jami arizalar', totalArizalar.toString()],
                ['Bajarilgan', bajarilganArizalar.toString()],
                ['Ko\'rilmoqda', korilmoqdaArizalar.toString()],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),

            // Arizalar kategoriya bo'yicha
            pw.Header(
              level: 1,
              child: pw.Text(
                'Arizalar kategoriya bo\'yicha',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: ['Kategoriya', 'Soni'],
              data: arizaByCategory.entries
                  .map((e) => [e.key, e.value.toString()])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),

            // Muammolar statistikasi
            pw.Header(
              level: 1,
              child: pw.Text(
                'Muammolar statistikasi',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: ['Ko\'rsatkich', 'Soni'],
              data: [
                ['Jami muammolar', totalMuammolar.toString()],
                ['Hal qilingan', halQilinganMuammolar.toString()],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),

            // Muammolar turi bo'yicha
            pw.Header(
              level: 1,
              child: pw.Text(
                'Muammolar turi bo\'yicha',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: ['Turi', 'Soni'],
              data: muammoByType.entries
                  .map((e) => [e.key, e.value.toString()])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            // Footer
            pw.SizedBox(height: 40),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Yaratilgan: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/hisobot_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Print PDF
  static Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
    );
  }

  // Share PDF
  static Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }

  // Generate Ariza PDF
  static Future<File> generateArizaPdf({
    required String arizaNumber,
    required String fullName,
    required String category,
    required String description,
    required String status,
    required DateTime createdAt,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ARIZA',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Ariza raqami: $arizaNumber'),
              pw.SizedBox(height: 10),
              pw.Text('F.I.O: $fullName'),
              pw.SizedBox(height: 10),
              pw.Text('Kategoriya: $category'),
              pw.SizedBox(height: 10),
              pw.Text('Holati: $status'),
              pw.SizedBox(height: 10),
              pw.Text('Sana: ${DateFormat('dd.MM.yyyy HH:mm').format(createdAt)}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Ariza matni:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(description),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/ariza_$arizaNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
