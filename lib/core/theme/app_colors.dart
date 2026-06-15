// ════════════════════════════════════════════════════════
//  core/theme/app_colors.dart
//  ✅ ثيم السماء: أزرق سماوي + أبيض ناصع
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── الألوان الأساسية (سماوي + أبيض) ─────────────────
  static const Color primary      = Color(0xFF0288D1); // أزرق سماوي
  static const Color primaryLight = Color(0xFF4FC3F7); // سماوي فاتح
  static const Color primaryDark  = Color(0xFF01579B); // سماوي غامق
  static const Color primaryDeep  = Color(0xFF003C6E); // كحلي عميق
  static const Color secondary    = Color(0xFF29B6F6); // سماوي ساطع
  static const Color accent       = Color(0xFF00ACC1); // تيل سماوي

  // ── سماوي فاتح (accent) ───────────────────────────────
  static const Color accentBlue       = Color(0xFF4FC3F7);
  static const Color accentBlueLight  = Color(0xFF81D4FA);
  static const Color accentPale       = Color(0xFFB3E5FC);  // سماوي شاحب
  static const Color accentFaintest   = Color(0xFFE1F5FE);  // سماوي خفيف جداً

  // ── حالات ────────────────────────────────────────────
  static const Color teal      = Color(0xFF00BCD4);
  static const Color danger    = Color(0xFFE53935);
  static const Color pinkHeart = Color(0xFFE53935);
  static const Color success   = Color(0xFF43A047);
  static const Color warning   = Color(0xFFFB8C00);

  // ── خلفيات (أبيض + سماوي خفيف) ──────────────────────
  static const Color bg        = Color(0xFFF0F9FF); // أبيض سماوي خفيف
  static const Color bgCard    = Color(0xFFFFFFFF); // أبيض ناصع للكروت
  static const Color splashBg  = Color(0xFF01579B); // كحلي سماوي للـ Splash
  static const Color lightBlue = Color(0xFFE1F5FE); // سماوي خفيف
  static const Color lightTeal = Color(0xFFE0F7FA); // تيل خفيف

  // ── نصوص ──────────────────────────────────────────────
  static const Color textDark  = Color(0xFF0D2137);
  static const Color textGray  = Color(0xFF546E7A);
  static const Color textMuted = Color(0xFF78909C);
  static const Color textHint  = Color(0xFFB0BEC5);

  // ── محايد ─────────────────────────────────────────────
  static const Color white   = Color(0xFFFFFFFF);
  static const Color black   = Color(0xFF000000);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color black10 = Color(0x1A000000);
  static const Color black20 = Color(0x33000000);
  static const Color black50 = Color(0x80000000);

  // ── تدرجات سماوية ─────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF01579B), Color(0xFF0288D1),
  ];
  static const List<Color> headerGradient = [
    Color(0xFF01579B), Color(0xFF0288D1), Color(0xFF4FC3F7),
  ];
  // تدرج سماء حقيقية (من أبيض لسماوي)
  static const List<Color> skyGradient = [
    Color(0xFFFFFFFF), Color(0xFFE1F5FE), Color(0xFF81D4FA),
  ];
  static const List<Color> skyGradientDeep = [
    Color(0xFF0288D1), Color(0xFF4FC3F7), Color(0xFFB3E5FC),
  ];
  static const List<Color> cardGradientBlue = [
    Color(0xFF0288D1), Color(0xFF29B6F6),
  ];
  static const List<Color> emergencyGradient = [
    Color(0xFFC62828), Color(0xFFE53935),
  ];

  // ── إجراءات سريعة ────────────────────────────────────
  static const Color actionHealth  = Color(0xFF0288D1);
  static const Color actionAppt    = Color(0xFF00ACC1);
  static const Color actionMeds    = Color(0xFF00897B);
  static const Color actionReports = Color(0xFF7B1FA2);
  static const Color actionFamily  = Color(0xFFF57F17);

  // ── ثوابت مُحسوبة مسبقاً ──────────────────────────────
  static const Color accentLight    = Color(0x1A00ACC1);
  static const Color tealLight      = Color(0x1400BCD4);
  static const Color primaryShadow  = Color(0x200288D1);
}