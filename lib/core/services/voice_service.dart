// ════════════════════════════════════════════════════════
//  core/services/voice_service.dart
//  خدمة تحويل النص إلى صوت (TTS) — مشتركة عبر التطبيق
// ════════════════════════════════════════════════════════
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  VoiceService._internal();
  static final VoiceService instance = VoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _enabled = true; // يمكن ربطه بزر تشغيل/إيقاف الصوت من الإعدادات

  bool get isEnabled => _enabled;
  void setEnabled(bool value) => _enabled = value;

  Future<void> _init(bool isAr) async {
    await _tts.setLanguage(isAr ? 'ar-SA' : 'en-US');
    await _tts.setSpeechRate(0.48);   // سرعة مناسبة وواضحة
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  /// نطق نص معيّن. isAr لتحديد اللغة.
  Future<void> speak(String text, {required bool isAr}) async {
    if (!_enabled || text.trim().isEmpty) return;
    if (!_initialized) await _init(isAr);
    await _tts.setLanguage(isAr ? 'ar-SA' : 'en-US');
    await _tts.stop(); // إيقاف أي نطق سابق قبل البدء بالجديد
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}