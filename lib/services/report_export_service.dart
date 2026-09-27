import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../data/student_store.dart';

class ReportExportService {
  const ReportExportService._();

  static Future<void> sharePdf(
    StudentStore store,
    String displayName,
  ) async {
    final bytes = await buildPdf(store, displayName);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
          bytes,
          name: 'student-life-weekly-report.pdf',
          mimeType: 'application/pdf',
          ),
        ],
        fileNameOverrides: const ['student-life-weekly-report.pdf'],
      ),
    );
  }

  static Future<void> shareWord(
    StudentStore store,
    String displayName,
  ) async {
    final bytes = Uint8List.fromList(utf8.encode(buildRtf(store, displayName)));
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
          bytes,
          name: 'student-life-weekly-report.rtf',
          mimeType: 'application/rtf',
          ),
        ],
        fileNameOverrides: const ['student-life-weekly-report.rtf'],
      ),
    );
  }

  static Future<Uint8List> buildPdf(
    StudentStore store,
    String displayName,
  ) async {
    final totalTasks = store.tasks.length;
    final completion = totalTasks == 0
        ? 0.0
        : store.completedTasks / totalTasks;
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Student Life Hub - Weekly Report'),
          ),
          pw.Text('Student: $displayName'),
          pw.Text('Generated: ${DateTime.now().toLocal().toString().split('.').first}'),
          pw.SizedBox(height: 18),
          pw.Text('Overall progress', style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 6),
          pw.Container(
            width: 400,
            height: 8,
            color: PdfColors.grey300,
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Container(
                width: 400 * completion,
                height: 8,
                color: PdfColors.blue,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('${(completion * 100).round()}% of tasks are complete.'),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: const ['Metric', 'Value'],
            data: [
              ['Study streak', '${store.studyStreak} days'],
              ['Tasks completed', '${store.completedTasks}'],
              ['Classes planned', '${store.schedule.length}'],
              ['Total spending', 'USD ${store.totalExpenses.toStringAsFixed(2)}'],
              ['Campus events', '${store.events.length}'],
            ],
          ),
        ],
      ),
    );
    return document.save();
  }

  static String buildRtf(StudentStore store, String displayName) {
    final totalTasks = store.tasks.length;
    final completion = totalTasks == 0
        ? 0.0
        : store.completedTasks / totalTasks;
    final lines = [
      'Student Life Hub - Weekly Report',
      'Student: $displayName',
      'Generated: ${DateTime.now().toLocal().toString().split('.').first}',
      '',
      'Overall progress: ${(completion * 100).round()}% of tasks are complete.',
      '',
      'Study streak: ${store.studyStreak} days',
      'Tasks completed: ${store.completedTasks}',
      'Classes planned: ${store.schedule.length}',
      'Total spending: USD ${store.totalExpenses.toStringAsFixed(2)}',
      'Campus events: ${store.events.length}',
    ];
    final body = lines.map(_escapeRtf).join(r'\line ');
    return r'{\rtf1\ansi\deff0 {\fonttbl {\f0 Aptos;}}\f0\fs24 ' +
        body +
        r'\par}';
  }

  static String _escapeRtf(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('{', r'\{')
      .replaceAll('}', r'\}');
}
