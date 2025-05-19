import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class IconGenerator {
  static Future<void> generateAppIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    // Draw background with gradient
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2196F3), // Material Blue
          Color(0xFF1976D2), // Darker Blue
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    // Draw outer circle
    final outerCirclePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.4,
      outerCirclePaint,
    );

    // Draw clock face
    final clockPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35,
      clockPaint,
    );

    // Draw clock hands
    final handPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    // Hour hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, size.height * 0.3),
      handPaint,
    );

    // Minute hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width * 0.7, size.height / 2),
      handPaint,
    );

    // Draw checkmark
    final checkPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.65)
      ..lineTo(size.width * 0.7, size.height * 0.35);
    canvas.drawPath(path, checkPaint);

    // Draw small dots around the clock
    final dotPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;
    
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30) * (pi / 180);
      final x = size.width / 2 + (size.width * 0.4) * cos(angle);
      final y = size.height / 2 + (size.height * 0.4) * sin(angle);
      canvas.drawCircle(
        Offset(x, y),
        size.width * 0.01,
        dotPaint,
      );
    }

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Convert to ICO
    final imageData = img.decodeImage(pngBytes);
    if (imageData != null) {
      // Create different sizes for the ICO
      final sizes = [16, 32, 48, 64, 128, 256];
      final images = <img.Image>[];
      
      for (final size in sizes) {
        final resized = img.copyResize(
          imageData,
          width: size,
          height: size,
          interpolation: img.Interpolation.linear,
        );
        images.add(resized);
      }

      // Save as ICO
      final icoData = img.encodeIco(images[0]); // Use the largest image for now
      
      // Save to Windows resources directory
      final windowsResourceDir = Directory('windows/runner/resources');
      if (await windowsResourceDir.exists()) {
        final windowsIconFile = File('${windowsResourceDir.path}/app_icon.ico');
        await windowsIconFile.writeAsBytes(icoData);
        print('Icon saved to: ${windowsIconFile.path}');
        
        // Verify the file was created
        if (await windowsIconFile.exists()) {
          print('Icon file successfully created and saved');
        } else {
          print('Failed to create icon file');
        }
      } else {
        print('Windows resources directory not found at: ${windowsResourceDir.path}');
      }
    }
  }
} 