import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  static Future<void> shareToWhatsApp({
    required String text,
    String? imagePath,
  }) async {
    try {
      // First try to use WhatsApp directly
      await _openWhatsAppWithText(text);
    } catch (e) {
      // Fallback to general sharing if WhatsApp is not available
      try {
        if (imagePath != null) {
          await Share.shareXFiles([XFile(imagePath)], text: text);
        } else {
          await Share.share(text);
        }
      } catch (shareError) {
        throw 'No se pudo compartir: $shareError';
      }
    }
  }

  static Future<void> _openWhatsAppWithText(String text) async {
    final encodedText = Uri.encodeComponent(text);

    // Try different WhatsApp URL schemes
    final whatsappUrls = [
      'whatsapp://send?text=$encodedText',
      'https://wa.me/?text=$encodedText',
      'https://api.whatsapp.com/send?text=$encodedText',
    ];

    for (final url in whatsappUrls) {
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          return; // Success, exit the function
        }
      } catch (e) {
        continue; // Try next URL
      }
    }

    // If none of the WhatsApp URLs work, throw an error
    throw 'WhatsApp no está instalado o no está disponible';
  }

  static Future<String?> captureWidget(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return null;

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/plant_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      return null;
    }
  }

  static String generatePlantShareText({
    required String plantStage,
    required int moodPoints,
    required int currentLevel,
  }) {
    final messages = [
      '🌱 ¡Mira cómo ha crecido mi jardín del amor! 💕',
      'Mi planta está en la etapa: $plantStage 🌿',
      'Puntos de felicidad acumulados: $moodPoints ✨',
      'Nivel actual: $currentLevel 🎉',
      '',
      '¡Cada día que me siento bien, mi planta crece más! 🌸',
      'Descarga Love Garden App y cultiva tu propia felicidad 💝',
    ];

    return messages.join('\n');
  }

  static Future<void> shareGeneralApp() async {
    const text = '''
¡Descubre Love Garden App! 🌱💕

Una app que te envía mensajes lindos según la hora del día y hace crecer una planta virtual basada en tu estado de ánimo.

¡Cultiva tu felicidad y comparte tu crecimiento! 🌸✨

#LoveGarden #Bienestar #Felicidad
    ''';

    await Share.share(text);
  }
}
