// ════════════════════════════════════════════════════════
//  tabs/features_tab.dart
//  تبويب "الميزات" — إجراءات مطلوبة + اقتراحات
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../widgets/features_widgets.dart';

class FeaturesTab extends ConsumerWidget {
  const FeaturesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(languageProvider);
    final user = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── AppBar ──
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Text(
              isAr ? 'الميزات' : 'Features',
              style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 18,
                child: Text(
                  user != null ? user.nameAr.substring(0, 1) : 'إ',
                  style: GoogleFonts.cairo(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                onPressed: () {},
              ),
            ],
          ),

          // ── المحتوى ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // حالة النظام
                SystemStatusBar(isAr: isAr),
                const SizedBox(height: 20),

                // ── مطلوب اتخاذ إجراء ──
                FeaturesSectionLabel(
                  label: isAr ? 'مطلوب اتخاذ إجراء' : 'Action Required',
                ),
                const SizedBox(height: 10),
                ActionCard(
                  icon:     Icons.timer_outlined,
                  color:    AppColors.danger,
                  title:    isAr ? 'تأكيد السلامة' : 'Safety Check-In',
                  sub:      isAr ? 'يجب اتخاذ إجراء' : 'Action needed',
                  btnLabel: isAr ? 'حل المشكلة' : 'Fix Issue',
                  onTap: () {},
                ),
                const SizedBox(height: 11),
                ActionCard(
                  icon:     Icons.wifi_tethering_rounded,
                  color:    AppColors.danger,
                  title:    isAr ? 'مشاركة الموقع في الطوارئ' : 'Emergency Location Sharing',
                  sub:      isAr ? 'يجب اتخاذ إجراء' : 'Action needed',
                  btnLabel: isAr ? 'تفعيل الآن' : 'Enable Now',
                  onTap: () {},
                ),
                const SizedBox(height: 20),

                // ── اقتراحات ──
                FeaturesSectionLabel(
                  label: isAr ? 'اقتراحات' : 'Suggestions',
                ),
                const SizedBox(height: 10),
                SuggestionCard(
                  icon:            Icons.flash_on_rounded,
                  iconBg:          AppColors.primary,
                  title:           isAr ? 'اتصالات الطوارئ' : 'Emergency Contacts',
                  body:            isAr
                      ? 'اضغط على زر التشغيل 5 مرات أو أكثر بسرعة للاتصال وطلب المساعدة ومشاركة موقعك الجغرافي'
                      : 'Press power button 5+ times quickly to call for help and share your location',
                  primaryLabel:   isAr ? 'بدء الإعداد' : 'Start Setup',
                  secondaryLabel: isAr ? 'مشاهدة عرض' : 'Watch Demo',
                  onPrimary:   () {},
                  onSecondary: () {},
                ),
                const SizedBox(height: 11),
                SuggestionCard(
                  icon:            Icons.group_rounded,
                  iconBg:          AppColors.accent,
                  title:           isAr ? 'دائرة الثقة' : 'Circle of Trust',
                  body:            isAr
                      ? 'أضف أفراد عائلتك وأصدقائك المقربين ليصلهم إشعار فوري في حالة الطوارئ'
                      : 'Add family and close friends to receive an instant emergency alert',
                  primaryLabel:   isAr ? 'إضافة جهة' : 'Add Contact',
                  secondaryLabel: isAr ? 'تعرف أكثر' : 'Learn More',
                  onPrimary:   () {},
                  onSecondary: () {},
                ),

              ]),
            ),
          ),
        ],
      ),
    );
  }
}