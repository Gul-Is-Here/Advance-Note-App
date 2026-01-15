import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:note_app/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  static final PdfExportService instance = PdfExportService._();
  PdfExportService._();

  // Export a single note to PDF
  Future<void> exportNoteToPdf(Note note) async {
    try {
      final pdf = pw.Document();

      // Get plain text from Quill content
      final plainText = _getPlainTextFromQuill(note.content);

      // Load custom font for better typography
      final fontData = await rootBundle.load(
        'assets/fonts/OpenSans-VariableFont_wdth.ttf',
      );
      final ttf = pw.Font.ttf(fontData);

      final boldFontData = await rootBundle.load(
        'assets/fonts/OpenSans-VariableFont_wdth.ttf',
      );
      final boldTtf = pw.Font.ttf(boldFontData);

      // Load app logo
      final logoData = await rootBundle.load('assets/images/noteicon.jpg');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build:
              (context) => [
                // Letterhead with logo
                _buildLetterhead(logoImage, ttf, boldTtf),
                pw.SizedBox(height: 30),

                // Header with gradient effect
                _buildHeader(note, ttf, boldTtf),
                pw.SizedBox(height: 30),

                // Metadata section
                _buildMetadata(note, ttf),
                pw.SizedBox(height: 30),

                // Content
                _buildContent(plainText, ttf),
              ],
          footer: (context) => _buildFooter(context, ttf),
        ),
      );

      // Save and share
      await _savAndSharePdf(pdf, note.title);
    } catch (e) {
      // Re-throw the error so it can be handled by the caller
      rethrow;
    }
  }

  // Export multiple notes to a single PDF
  Future<void> exportMultipleNotesToPdf(
    List<Note> notes,
    String fileName,
  ) async {
    try {
      final pdf = pw.Document();

      // Load fonts
      final fontData = await rootBundle.load(
        'assets/fonts/OpenSans-VariableFont_wdth.ttf',
      );
      final ttf = pw.Font.ttf(fontData);

      final boldFontData = await rootBundle.load(
        'assets/fonts/OpenSans-VariableFont_wdth.ttf',
      );
      final boldTtf = pw.Font.ttf(boldFontData);

      // Load app logo
      final logoData = await rootBundle.load('assets/images/noteicon.jpg');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Add cover page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:
              (context) =>
                  _buildCoverPage(notes.length, logoImage, ttf, boldTtf),
        ),
      );

      // Add each note
      for (var i = 0; i < notes.length; i++) {
        final note = notes[i];
        final plainText = _getPlainTextFromQuill(note.content);

        // Load logo for each page
        final logoData = await rootBundle.load('assets/images/noteicon.jpg');
        final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build:
                (context) => [
                  // Letterhead
                  _buildLetterhead(logoImage, ttf, boldTtf),
                  pw.SizedBox(height: 20),

                  // Note number indicator
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'Note ${i + 1} of ${notes.length}',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Header
                  _buildHeader(note, ttf, boldTtf),
                  pw.SizedBox(height: 20),

                  // Metadata
                  _buildMetadata(note, ttf),
                  pw.SizedBox(height: 20),

                  // Content
                  _buildContent(plainText, ttf),

                  // Page break if not last note
                  if (i < notes.length - 1) pw.NewPage(),
                ],
            footer: (context) => _buildFooter(context, ttf),
          ),
        );
      }

      await _savAndSharePdf(pdf, fileName);
    } catch (e) {
      // Re-throw the error so it can be handled by the caller
      rethrow;
    }
  }

  // Build PDF header
  pw.Widget _buildHeader(Note note, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.teal500, PdfColors.teal700],
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title
          pw.Text(
            note.title.isEmpty ? 'Untitled Note' : note.title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),

          // Category badge
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Text(
              note.category,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
                color: PdfColors.teal700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build metadata section
  pw.Widget _buildMetadata(Note note, pw.Font font) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Status indicators
          pw.Row(
            children: [
              if (note.isPinned)
                _buildBadge('📌 Pinned', PdfColors.orange100, font),
              if (note.isFavorite) ...[
                if (note.isPinned) pw.SizedBox(width: 8),
                _buildBadge('❤️ Favorite', PdfColors.red100, font),
              ],
              if (note.isLocked) ...[
                if (note.isPinned || note.isFavorite) pw.SizedBox(width: 8),
                _buildBadge('🔒 Locked', PdfColors.amber100, font),
              ],
            ],
          ),
          if (note.isPinned || note.isFavorite || note.isLocked)
            pw.SizedBox(height: 12),

          // Dates
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildMetadataItem(
                  '📅 Created',
                  dateFormat.format(note.createdAt),
                  font,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildMetadataItem(
                  '🔄 Updated',
                  dateFormat.format(note.updatedAt),
                  font,
                ),
              ),
            ],
          ),

          // Tags
          if (note.tags.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  note.tags
                      .map(
                        (tag) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(color: PdfColors.blue200),
                          ),
                          child: pw.Text(
                            '#$tag',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 10,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],

          // Reminder
          if (note.reminderDate != null) ...[
            pw.SizedBox(height: 12),
            _buildMetadataItem(
              '⏰ Reminder',
              dateFormat.format(note.reminderDate!),
              font,
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildBadge(String text, PdfColor color, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }

  pw.Widget _buildMetadataItem(String label, String value, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black),
        ),
      ],
    );
  }

  // Build content section
  pw.Widget _buildContent(String content, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Content',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal700,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            content.isEmpty ? 'No content available.' : content,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              lineSpacing: 1.5,
              color: PdfColors.grey900,
            ),
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // Build letterhead with logo and app info
  pw.Widget _buildLetterhead(
    pw.MemoryImage logo,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.teal300, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Logo
          pw.Container(
            width: 50,
            height: 50,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(12),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.grey400,
                  blurRadius: 4,
                  offset: const PdfPoint(0, 2),
                ),
              ],
            ),
            child: pw.ClipRRect(
              horizontalRadius: 12,
              verticalRadius: 12,
              child: pw.Image(logo, fit: pw.BoxFit.cover),
            ),
          ),
          pw.SizedBox(width: 16),

          // App name and tagline
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'MyNotes',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 22,
                    color: PdfColors.teal700,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Your thoughts, beautifully organized',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),

          // Download info
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.teal200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Get the App',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 9,
                    color: PdfColors.teal800,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'mynotes.app',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.teal600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build cover page for multiple notes
  pw.Widget _buildCoverPage(
    int noteCount,
    pw.MemoryImage logo,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          // App logo instead of emoji
          pw.Container(
            width: 120,
            height: 120,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(24),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.teal300,
                  blurRadius: 20,
                  offset: const PdfPoint(0, 8),
                ),
              ],
            ),
            child: pw.ClipRRect(
              horizontalRadius: 24,
              verticalRadius: 24,
              child: pw.Image(logo, fit: pw.BoxFit.cover),
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Text(
            'Notes Export',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 40,
              color: PdfColors.teal700,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal50,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              '$noteCount Notes Included',
              style: pw.TextStyle(
                font: font,
                fontSize: 18,
                color: PdfColors.teal900,
              ),
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Text(
            'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Build footer
  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.teal200, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.teal50,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // App info with download link
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'MyNotes App • ${DateFormat('yyyy').format(DateTime.now())}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                  color: PdfColors.teal800,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Download at: mynotes.app',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 8,
                  color: PdfColors.teal600,
                ),
              ),
            ],
          ),

          // Page numbers
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.teal700,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              'Page ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extract plain text from Quill JSON
  String _getPlainTextFromQuill(String content) {
    try {
      final document = Document.fromJson(jsonDecode(content));
      return document.toPlainText().trim();
    } catch (_) {
      return content;
    }
  }

  // Save and share PDF
  Future<void> _savAndSharePdf(pw.Document pdf, String fileName) async {
    print('📄 Saving PDF: $fileName');

    // Generate PDF bytes
    final bytes = await pdf.save();
    print('✅ PDF bytes generated: ${bytes.length} bytes');

    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '');
    final file = File('${tempDir.path}/${sanitizedFileName}_$timestamp.pdf');

    print('💾 Saving to: ${file.path}');

    // Write to file
    await file.writeAsBytes(bytes);
    print('✅ File written successfully');

    // Check if file exists
    final exists = await file.exists();
    print('📁 File exists: $exists');

    if (exists) {
      final fileSize = await file.length();
      print('📊 File size: $fileSize bytes');
    }

    print('📤 Attempting to share PDF...');

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Exported Note: $fileName',
      text: 'Here is your exported note in PDF format.',
    );

    print('✅ Share dialog completed');
  }
}
