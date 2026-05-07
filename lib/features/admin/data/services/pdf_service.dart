import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<void> generateHisobotPdf({
    required String title,
    required DateTime? selectedMonth,
    required int arizalarCount,
    required int muammolarCount,
    required int navbatlarCount,
    required int elonlarCount,
    required Map<String, int> arizalarStatus,
    required Map<String, int> muammolarStatus,
    required Map<String, int> navbatlarStatus,
  }) async {
    final pdf = pw.Document();

    // Add page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MAHALLA XIZMATI',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: PdfColors.white,
                  ),
                ),
                if (selectedMonth != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    DateFormat('MMMM yyyy', 'uz').format(selectedMonth),
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Date
          pw.Text(
            'Hisobot sanasi: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 24),

          // Umumiy Statistika
          pw.Text(
            'UMUMIY STATISTIKA',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Arizalar', arizalarCount, PdfColors.blue),
                _buildStatItem('Muammolar', muammolarCount, PdfColors.red),
                _buildStatItem('Navbatlar', navbatlarCount, PdfColors.green),
                _buildStatItem('E\'lonlar', elonlarCount, PdfColors.purple),
              ],
            ),
          ),
          pw.SizedBox(height: 32),

          // Arizalar Status
          pw.Text(
            'STATUS BO\'YICHA ARIZALAR',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildStatusTable(
            arizalarStatus,
            arizalarCount,
            [
              'Yuborildi',
              'Ko\'rilmoqda',
              'Bajarildi',
              'Rad etildi',
            ],
          ),
          pw.SizedBox(height: 24),

          // Muammolar Status
          pw.Text(
            'STATUS BO\'YICHA MUAMMOLAR',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildStatusTable(
            muammolarStatus,
            muammolarCount,
            [
              'Yuborildi',
              'Ko\'rilmoqda',
              'Hal qilindi',
              'Rad etildi',
            ],
          ),
          pw.SizedBox(height: 24),

          // Navbatlar Status
          pw.Text(
            'NAVBATLAR STATISTIKASI',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildStatusTable(
            navbatlarStatus,
            navbatlarCount,
            [
              'Kutilmoqda',
              'Tasdiqlandi',
              'Tugallandi',
              'Bekor qilindi',
            ],
          ),
          pw.SizedBox(height: 32),

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Bu hisobot Mahalla Xizmati tizimi tomonidan avtomatik yaratilgan.',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    // Save and share
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _buildStatItem(String label, int count, PdfColor color) {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: color.shade(0.1),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            count.toString(),
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStatusTable(
    Map<String, int> statusData,
    int total,
    List<String> labels,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableCell('Status', isHeader: true),
            _buildTableCell('Soni', isHeader: true),
            _buildTableCell('Foiz', isHeader: true),
          ],
        ),
        // Data rows
        ...labels.map((label) {
          final key = _getStatusKey(label);
          final count = statusData[key] ?? 0;
          final percentage =
              total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
          return pw.TableRow(
            children: [
              _buildTableCell(label),
              _buildTableCell(count.toString()),
              _buildTableCell('$percentage%'),
            ],
          );
        }),
        // Total
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
          children: [
            _buildTableCell('JAMI', isHeader: true),
            _buildTableCell(total.toString(), isHeader: true),
            _buildTableCell('100%', isHeader: true),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _getStatusKey(String label) {
    switch (label) {
      case 'Yuborildi':
        return 'yuborildi';
      case 'Ko\'rilmoqda':
        return 'ko\'rilmoqda';
      case 'Bajarildi':
        return 'bajarildi';
      case 'Rad etildi':
        return 'rad_etildi';
      case 'Hal qilindi':
        return 'hal_qilindi';
      case 'Kutilmoqda':
        return 'kutilmoqda';
      case 'Tasdiqlandi':
        return 'tasdiqlandi';
      case 'Tugallandi':
        return 'tugallandi';
      case 'Bekor qilindi':
        return 'bekor_qilindi';
      default:
        return label.toLowerCase();
    }
  }
}
