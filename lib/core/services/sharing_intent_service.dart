import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../models/voice_intent_model.dart';
import 'smart_transaction_parser.dart';

/// Service untuk menangani penerimaan berkas atau teks dari aplikasi luar
/// (seperti Mind Space ColorOS, WhatsApp, Galeri, atau Browser via Android Share Sheet).
class SharingIntentService {
  final SmartTransactionParser _parser;

  SharingIntentService(this._parser);

  StreamSubscription? _textIntentSub;
  StreamSubscription? _mediaIntentSub;

  final _intentsController = StreamController<List<VoiceIntentModel>>.broadcast();

  /// Stream yang memancarkan daftar [VoiceIntentModel] yang berhasil diekstrak
  Stream<List<VoiceIntentModel>> get onIntentsReceived => _intentsController.stream;

  /// Inisialisasi listener untuk background & cold-start sharing
  void initSharingListener() {
    // 1. Tangani Shared Media (Text, Images, Files) saat app aktif di background/foreground
    _mediaIntentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) async {
        await _processIncomingMedia(files);
      },
      onError: (err) {
        debugPrint('[SharingIntentService] Media Stream Error: $err');
      },
    );

    // 2. Tangani Shared Media saat app dibuka dari cold start
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) async {
      if (files.isNotEmpty) {
        await _processIncomingMedia(files);
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  /// Memproses teks langsung
  Future<void> _processIncomingText(String text) async {
    final parsed = _parser.parse(text);
    if (parsed.isNotEmpty) {
      _intentsController.add(parsed);
    }
  }

  /// Memproses file gambar melalui Offline Google ML Kit OCR
  Future<void> _processIncomingMedia(List<SharedMediaFile> files) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final combinedExtractedIntents = <VoiceIntentModel>[];

      for (final file in files) {
        final path = file.path;
        if (path.isEmpty) continue;

        // Cek ekstensi file umum gambar
        final lower = path.toLowerCase();
        if (lower.endsWith('.png') ||
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.webp') ||
            lower.endsWith('.bmp')) {
          final inputImage = InputImage.fromFilePath(path);
          final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
          final ocrText = recognizedText.text;

          debugPrint('[SharingIntentService] OCR Raw Output:\n$ocrText');

          final parsedIntents = _parser.parse(ocrText);
          combinedExtractedIntents.addAll(parsedIntents);
        } else {
          // Jika teks dibagikan langsung
          final parsedIntents = _parser.parse(path);
          combinedExtractedIntents.addAll(parsedIntents);
        }
      }

      if (combinedExtractedIntents.isNotEmpty) {
        _intentsController.add(combinedExtractedIntents);
      }
    } catch (e) {
      debugPrint('[SharingIntentService] Error processing OCR image: $e');
    } finally {
      await textRecognizer.close();
    }
  }

  /// Bersihkan stream subscription saat aplikasi didispose
  void dispose() {
    _textIntentSub?.cancel();
    _mediaIntentSub?.cancel();
    _intentsController.close();
  }
}
