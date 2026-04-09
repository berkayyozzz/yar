import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

class ShareService {
  /// Captures the [boundary] widget as a PNG and opens the native share sheet.
  static Future<void> shareCard({
    required RenderRepaintBoundary boundary,
    Rect? sharePositionOrigin,
    int score = 0,
    double pixelRatio = 3.0,
  }) async {
    final file = await _captureToFile(boundary, pixelRatio);
    
    // On iPad, sharePositionOrigin is required to avoid crashes
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text: 'My budget roast score: $score/100 🔥\n#SmartBudgetRoast #GetJudged',
      subject: 'My Budget Roast',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Captures and saves the image to the documents directory.
  static Future<String> saveCard({
    required RenderRepaintBoundary boundary,
    double pixelRatio = 3.0,
  }) async {
    final file = await _captureToFile(boundary, pixelRatio);
    final dir = await getApplicationDocumentsDirectory();
    final savePath =
        '${dir.path}/roast_${DateTime.now().millisecondsSinceEpoch}.png';
    await file.copy(savePath);
    
    // Save to system gallery
    await Gal.putImage(savePath);
    
    return savePath;
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  static Future<File> _captureToFile(
      RenderRepaintBoundary boundary, double pixelRatio) async {
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/roast_card_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }
}
