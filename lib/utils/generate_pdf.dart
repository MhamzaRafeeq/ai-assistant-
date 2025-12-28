import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  /// Call this method from anywhere in your app
  static Future<void> generateShareAndPrintPdf() async {
    final pdf = pw.Document();
    List<pw.Widget> obligations =[];
    List<String> keyObligations = ['obligation1','obligation2', 'obligation3' ];
    for(int i = 0; i< keyObligations.length; i++){
      obligations.add(pw.Text(keyObligations[i]));

    }

    /// Dummy table data
    final tableHeaders = ['Stage Name', 'Amount', 'Due Date'];

    final tableData = [
      ['Foundation', '1500000', 'pick a date'],
      ['Decking', '1000000', 'pick a date'],
      ['Parapet', '800000', 'pick a date'],
    ];
    pw.TextStyle heading1  = pw.TextStyle(
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
    );pw.TextStyle heading2  = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );pw.TextStyle heading3  = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );


    /// Multi-page document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'ContractAgreement',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Agreement Information',
            style: heading2,
          ),
          pw.Text('Contract Reference ID: [Auto generated]'),
          pw.Text('Agreement Dates: [Selected Date]'),
          pw.Text('property Location: [Address]'),
          pw.Text('project Type: Residential'),
          pw.SizedBox(height: 20),
          pw.Text('parties involved', style: heading2,),
          pw.Text('Client Details',style: heading3 ),
          pw.Text('Name: client name'),
          pw.Text('Address: client address'),
          pw.Text('State: dropdown'),
          pw.SizedBox(height: 12),
          pw.Text('Contracter Details', style: heading3),
          pw.Text('Name: contracter name'),
          pw.Text('Company: contrcters company'),
          pw.Text('Address: company address'),
          pw.Text('Proffession: company profession'),

          pw.Text(
            'This is a multi-page PDF with a table.',
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Project Description & Budget', style: heading2),
          pw.Text('project scope: project scope'),
          pw.Text('project Contract Sum: Numerical Input'),
          pw.SizedBox(height:10 ),


          /// Table
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),

          pw.SizedBox(height: 20),
          pw.Text('Timeline & Obligations', style: heading2),
          pw.Text('Commencement date: date'),
          pw.Text('Completion date: date'),
          pw.Text('Project duration: days'),
          pw.SizedBox(height: 20),

          pw.Text('key obligations'),
          pw.Column(
            children: obligations,
          ),
          pw.SizedBox(height: 20),
          pw.Text('Contractual Terms', style: heading2),
          pw.Text('some text for contractual terms'),

          pw.Text('Signatures', style: heading2),
          pw.Row(
            children: [
              pw.Text('Client: name provided'),

            ]
          ),



          /// Force next page content
          pw.Text(
            'This content appears on the next page.',
            style: const pw.TextStyle(fontSize: 16),
          ),
        ],
      ),
    );

    /// Save PDF locally
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sample_document.pdf');
    await file.writeAsBytes(await pdf.save());

    /// Share PDF
    // await SharePlus.instance.share(
    //   ShareParams(text: 'Here is your document', files: [XFile(file.path)]),
    // );
    // await Share.shareXFiles([
    //   XFile(file.path),
    // ], text: 'Here is your PDF document');

    /// Print PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
