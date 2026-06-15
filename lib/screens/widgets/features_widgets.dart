// ════════════════════════════════════════════════════════
//  widgets/features_widgets.dart
//  ويدجت خاصة بتبويب "الميزات"
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

// ════════════════════════════════════════════════════════
//  SystemStatusBar — شريط حالة النظام (أخضر)
// ════════════════════════════════════════════════════════
class SystemStatusBar extends StatelessWidget {
  final bool isAr;

  const SystemStatusBar({super.key, required this.isAr});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isAr ? 'النظام يعمل بشكل طبيعي' : 'System Operating Normally',
                style: GoogleFonts.cairo(
                    fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Text(
                isAr ? 'جميع خدمات الطوارئ متاحة' : 'All emergency services available',
                style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAr ? '✓ نشط' : '✓ Active',
              style: GoogleFonts.cairo(
                  fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  FeaturesSectionLabel — تسمية القسم (نص رمادي)
// ════════════════════════════════════════════════════════
class FeaturesSectionLabel extends StatelessWidget {
  final String label;

  const FeaturesSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textGray,
        ),
      );
}

// ════════════════════════════════════════════════════════
//  ActionCard — بطاقة "مطلوب اتخاذ إجراء"
// ════════════════════════════════════════════════════════
class ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, sub, btnLabel;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.btnLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(sub,
                  style: GoogleFonts.cairo(
                      fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 9),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: Size.zero,
              elevation: 0,
            ),
            child: Text(btnLabel,
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  SuggestionCard — بطاقة اقتراح مع زرّين
// ════════════════════════════════════════════════════════
class SuggestionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title, body;
  final String primaryLabel, secondaryLabel;
  final VoidCallback onPrimary, onSecondary;

  const SuggestionCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.cairo(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textGray, size: 20),
          ]),
          const SizedBox(height: 9),
          Text(body,
              style: GoogleFonts.cairo(
                  fontSize: 12, color: AppColors.textGray, height: 1.55)),
          const SizedBox(height: 13),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              onPressed: onSecondary,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDark,
                side: const BorderSide(color: Color(0xFFCFD8DC)),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                minimumSize: Size.zero,
              ),
              child: Text(secondaryLabel,
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                minimumSize: Size.zero,
                elevation: 0,
              ),
              child: Text(primaryLabel,
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ]),
        ]),
      );
}