import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<Uint8List> generateReceipt({
    required String transactionId,
    required DateTime date,
    required String? customerName,
    required List<Map<String, dynamic>> items,
    required double serviceFee,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    final pdf = pw.Document();

    // Load Logo
    // Menggunakan asset yang ada
    final logoData = await rootBundle.load('assets/app.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Menggunakan ukuran kertas struk (Roll 80mm equivalent ~ 226 points width)
    // Margin kecil untuk memaksimalkan ruang
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Image(logoImage, width: 50, height: 50),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Raffli Motor',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      'Jl. Raya Contoh No. 123',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Telp: 0812-3456-7890',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.5),

              // Info Transaksi
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'ID: ${transactionId.substring(0, 8)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              if (customerName != null && customerName.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'Pelanggan: $customerName',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),

              pw.Divider(thickness: 0.5),

              // Items Header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Qty',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),

              // Items List
              ...items.map((item) {
                // Handle different item structure or extract logic before calling this
                // Assumption: item map has 'product_name', 'quantity', 'price'
                final name = item['product_name'] ?? 'Item';
                final qty = item['quantity'] ?? 1;
                final price = item['price'] ?? 0;
                final total = price * qty;

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          name.toString(),
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          qty.toString(),
                          style: const pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          currencyFormat.format(total),
                          style: const pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Jasa
              if (serviceFee > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        'Jasa Service',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        currencyFormat.format(serviceFee),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],

              pw.Divider(thickness: 0.5),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    currencyFormat.format(totalPrice),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Metode Bayar',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    paymentMethod,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(
                  'Terima Kasih Atas Kunjungan Anda',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '"Barang yang sudah dibeli tidak dapat dikembalikan"',
                  style: pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
