
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:flutter/services.dart';
import '../models/phase_record.dart';

class ExportButton extends StatefulWidget {
  const ExportButton({
    this.width,
    this.height,
    // required this.pickedFromDate,
    // required this.pickedToDate,
    required this.chartRecords,
  });

  final double? width;
  final double? height;
  // final DateTime? pickedFromDate;
  // final DateTime? pickedToDate;
  final List<PhaseRecord> chartRecords;

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  WidgetsToImageController controller = WidgetsToImageController();
  WidgetsToImageController controller2 = WidgetsToImageController();
  List<DateTime> chartStartDates = [];
  List<DateTime> chartEndDates = [];
  List<String> chartTitles = [];
  @override
  void initState() {
    super.initState();
    _initializeLists();
  }

  void _initializeLists() {
    // chartStartDates = widget.startDates ?? [];
    // chartEndDates = widget.endDates ?? [];
    // chartTitles = widget.titles ?? [];
    // chartPlannedStartDates = widget.plannedStartDates ?? [];
    // chartPlannedEndDates = widget.plannedEndDates ?? [];
  }

  Future exportPdf(
      ) async {
    print("exportPdf started");
    late Uint8List? bytes;
    late Uint8List? bytes2;
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');
    try {
      bytes = await controller.capture(
        options: const CaptureOptions(
          //format: ImageFormat.jpeg,
          quality: 100,
        ),
      );
      print('byttes: $bytes');
    } catch (e) {
      print('error: $e');
    }
    try {
      bytes2 = await controller2.capture(
        options: const CaptureOptions(
          //format: ImageFormat.jpeg,
          quality: 100,
        ),
      );
      print('bytes2: $bytes2');
    } catch (e) {
      print('error2: $e');
    }
    int totalBudget = 0;
    for(int i = 0; i< widget.chartRecords.length; i++){
      totalBudget = totalBudget + (widget.chartRecords[i].amount ?? 0);
    }

    // // Delay to ensure chart widget is rendered
    // await Future.delayed(const Duration(milliseconds: 300));

    // final Uint8List chartImage = await _renderChartToImage(chartKey);
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(10),
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Text('Project Title:- '),
                    pw.Container(
                      width: 200,
                      height: 50,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('  Budget Reports'),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.black,
                          width: 2, // 1 PDF point ≈ 1 px
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Budget'),
                        pw.Container(
                          width: 50,
                          height: 40,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue,
                            border:
                            pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(children: [
                      pw.Text('Expense'),
                      pw.Container(
                        width: 50,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red,
                          border:
                          pw.Border.all(color: PdfColors.black, width: 1),
                        ),
                      ),
                    ]),
                  ],
                ),
                pw.Expanded(
                  child: pw.Column(
                     //crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                     //mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Text('Budget vs Expense', style: pw.TextStyle(fontSize: 14)),
                      pw.SizedBox(height: 10),
                      // // ===== VARIANCE CHART =====

                      // ===== ACTUAL CHART =====
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          margin: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border:
                            pw.Border.all(color: PdfColors.black, width: 2),
                          ),
                          child: bytes == null
                              ? pw.Center(child: pw.Text('No schedule chart'))
                              : pw.Image(
                            pw.MemoryImage(bytes),
                           // fit: pw.BoxFit.contain,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 10),

                      pw.Text('Budget Comparison', style: pw.TextStyle(fontSize: 14)),
                      pw.SizedBox(height: 10),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          margin: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border:
                            pw.Border.all(color: PdfColors.black, width: 2),
                          ),
                          child: bytes2 == null
                              ? pw.Center(child: pw.Text('No variance chart'))
                              : pw.Image(
                            pw.MemoryImage(bytes2),
                            //fit: pw.BoxFit.contain,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          );
        }));
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Schedule Overview',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(
                  width: 0.8,
                  color: PdfColors.grey600,
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1.2), // Start
                  1: pw.FlexColumnWidth(1.2), // End
                  2: pw.FlexColumnWidth(0.8), // Days
                  3: pw.FlexColumnWidth(2.0), // Title
                  4: pw.FlexColumnWidth(1.5), // Phase
                  5: pw.FlexColumnWidth(1.5), // Dependency
                },
                children: [
                  // ================= HEADER ROW =================
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _headerCell('Start'),
                      _headerCell('End'),
                      _headerCell('Days'),
                      _headerCell('Title'),
                      _headerCell('Phase'),
                      _headerCell('Dependency'),
                    ],
                  ),

                  // ================= DATA ROWS =================
                  ...widget.chartRecords.map((record) {
                    final start = record.startDate != null
                        ? dateFormat.format(record.startDate!)
                        : '-';

                    final end = record.endDate != null
                        ? dateFormat.format(record.endDate!)
                        : '-';

                    //final days = record.duration.toString() ?? '-';

                    final title = (record.stageName != null &&
                        record.stageName!.trim().isNotEmpty)
                        ? record.stageName!
                        : '-';

                    // final phase = (record.existingPhase != null &&
                    //     record.existingPhase!.trim().isNotEmpty)
                    //     ? record.existingPhase!
                    //     : '-';
                    //
                    // final dependency = (record.dependency != null &&
                    //     record.dependency!.trim().isNotEmpty)
                    //     ? record.dependency!
                    //     : '-';

                    return pw.TableRow(
                      children: [
                        _dataCell(start),
                        _dataCell(end),
                       // _dataCell(days),
                        _dataCell(title),
                        // _dataCell(phase),
                        // _dataCell(dependency),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Text('totalBudget = $totalBudget'),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());

    print("exportPdf finished");
  }

  pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _dataCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('data'),
      ),
      body: Column(children: [
        Stack(
          children: [
            Opacity(
              opacity: 0.01,
              child: WidgetsToImage(
                controller: controller,
                child: ScheduleGanttChart(
                  width: 400,
                  height: 400,
                  budgetRecords: widget.chartRecords,
                ),
              ),
            ),Opacity(
              opacity: 0.01,
              child: WidgetsToImage(
                controller: controller2,
                child: PieChartSample2(
                  width: 800,
                  height: 1000,
                  pieLegend: widget.chartRecords.map((e)=> e.stageName).toList(),
                  // reload:  ()async{ return Colors.blue;},
                  pieColor: widget.chartRecords.map((e)=> e.color).toList(),
                  pieValue: widget.chartRecords.map((E)=> E.amount).toList(),
                  sumValues: 300,
                ),
              ),
            ),
            InkWell(
              onTap: exportPdf,
              child: Container(
                width: widget.width,
                height: widget.height,
      
                decoration: BoxDecoration(
                  color: const Color(0xFFF9CF58),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description,
                      size: 24,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text('Run Reports',
                        style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class ScheduleGanttChart extends StatelessWidget {
  const ScheduleGanttChart({
    super.key,
    this.width,
    this.height,
    required this.budgetRecords,
  });

  final double? width;
  final double? height;

  final List<PhaseRecord> budgetRecords;

  @override
  Widget build(BuildContext context) {
    // Safety: if empty, return placeholder

    // Ensure we iterate only over the smallest matching length
    final int len = budgetRecords.length;
    if (len == 0) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text("No chart data available")),
      );
    }


    // Build bar groups (one group per task)
    final List<BarChartGroupData> barGroups = List.generate(len, (i) {

      // Clamp inside visible window
      double fromY = 0;
      double toY = budgetRecords[i].amount.toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            fromY: fromY,
            toY: toY,
            width: 10,
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
            // You can set backDrawRodData for outlines if desired:
            // backDrawRodData: BackgroundBarChartRodData(show: true, y: totalDays, color: Colors.grey[200]),
          ),BarChartRodData(
            fromY: fromY,
            toY: toY,
            width: 10,
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
            // You can set backDrawRodData for outlines if desired:
            // backDrawRodData: BackgroundBarChartRodData(show: true, y: totalDays, color: Colors.grey[200]),
          ),
        ],
      );
    });

    // Prepare left axis titles (weeks). left axis represents "days since pickFromDate".
    SideTitles leftSideTitles = SideTitles(
      showTitles: true,
      reservedSize: 56,
    );

    // Bottom titles for task names
    SideTitles bottomSideTitles = SideTitles(
      showTitles: true,
      reservedSize: 56,
      getTitlesWidget: (double value, TitleMeta meta) {
        final int index = value.toInt();
        if (index < 0 || index >= len) return const SizedBox();
        return RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            width: 80,
            child: Text(
              budgetRecords[index].stageName,
               style: const TextStyle(fontSize: 10 ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );

    return Container(
      width: width,
      height: height ?? 300,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          alignment: BarChartAlignment.start,
          // groupsSpace: 12,
          gridData: FlGridData(
            show: false,
            drawVerticalLine: false,
            horizontalInterval: 7,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: leftSideTitles),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text("Tasks"),
              sideTitles: bottomSideTitles,
            ),
            rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(enabled: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({
    super.key,
    this.width,
    this.height,
    required this.pieLegend,
    required this.pieValue,
    required this.pieColor,
    // required this.reload,
    this.sumValues,
  });

  final double? width;
  final double? height;
  final List<String> pieLegend;
  final List<int> pieValue;
  final List<Color> pieColor;
  // final Future Function() reload;
  final int? sumValues;

  @override
  State<PieChartSample2> createState() => _PieChartSample2State();
}

class _PieChartSample2State extends State<PieChartSample2> {
  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.pieValue.length, (i) {
      final legend = widget.pieLegend[i];
      final value = widget.pieValue[i];
      final color = widget.pieColor[i];
      Widget buildwidget = Padding(
        padding: EdgeInsetsDirectional.fromSTEB(50, 0, 0, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/my-meal-wise-hznnpt/assets/ni1tdqzvxxwn/Polygon_5.png',
                      width: 13,
                      height: 12,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xCD121212),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                        child: Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              legend,
                              //'carbohydrates',
                              style: TextStyle(
                                color: Colors.white, //Colors.white,
                                fontSize: 12,
                                fontFamily: 'Inter,',
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                              ),
                              // FlutterFlowTheme.of(context).bodyMedium.override(
                              //       fontFamily: 'Inter',
                              //       color: Colors.white,
                              //       fontSize: 12,
                              //       letterSpacing: 0,
                              //       fontWeight: FontWeight.w600,
                              //     ),
                            ),
                            Row(
                              spacing: 10,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: color,
                                  ),
                                ),
                                Text(
                                  value.toString(),
                                  //'25g',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Inter,',
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

      final isTouched = i == touchedIndex;
      // FFAppState().pieColor = color;
      // FFAppState().pieName = legend;
      // FFAppState().pieValue = value;
      final badgewidget = isTouched ? buildwidget : null;

      final fontSize = isTouched ? 25.0 : 16.0;
      //final radius = isTouched ? 80.0 : 70.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: color,
        badgeWidget: badgewidget,
        value: value / widget.sumValues! * 360,
        borderSide: BorderSide(width: 1, color: Colors.black),
        title: '${(value / widget.sumValues! * 100).toStringAsFixed(0)}%',
        radius: 100.0,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          shadows: shadows,
        ),
      );
    });
  }

// build widget
}
