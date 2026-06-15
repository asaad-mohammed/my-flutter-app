// ════════════════════════════════════════════════════════
//  widgets/shared_widgets.dart
//  ✅ إصلاح: شريط البحث يعمل فعلاً (GestureDetector بدلاً من Container ثابت)
//  ✅ إصلاح: HeaderIconBtn يقبل VoidCallback اختياري
//  ✅ إضافة: شارة الإشعارات مع عداد
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/data/mock_users.dart';

// ════════════════════════════════════════════════════════
//  HomeHeader — رأس الصفحة (الهيدر الزرقاء)
// ════════════════════════════════════════════════════════
class HomeHeader extends StatelessWidget {
  final AppStrings s;
  final MockUser user;
  final VoidCallback onLogout;
  // ✅ إضافة: دعم callback للبحث والإشعارات
  final VoidCallback? onSearchTap;
  final int notificationCount;

  const HomeHeader({
    super.key,
    required this.s,
    required this.user,
    required this.onLogout,
    this.onSearchTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 18,
          right: 18,
          bottom: 22,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.headerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        ),
        child: Column(children: [
          Row(children: [
            // أفاتار المستخدم
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 2),
              ),
              child: Center(
                child: Text(
                  user.nameAr.isNotEmpty ? user.nameAr[0] : '؟',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${s.homeGreeting} 👋',
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: Colors.white70)),
                  Text(
                    user.nameAr,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            // ✅ إضافة: شارة الإشعارات مع عداد
            Stack(
              clipBehavior: Clip.none,
              children: [
                HeaderIconBtn(icon: Icons.notifications_outlined),
                if (notificationCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5252),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        notificationCount > 9
                            ? '9+'
                            : '$notificationCount',
                        style: GoogleFonts.cairo(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onLogout,
              child: HeaderIconBtn(icon: Icons.logout_rounded),
            ),
          ]),
          const SizedBox(height: 14),
          // ✅ إصلاح: شريط البحث يُشير إلى شاشة بحث فعلية
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.search_rounded,
                    color: Colors.white60, size: 20),
                const SizedBox(width: 10),
                Text(
                  s.searchHint,
                  style: GoogleFonts.cairo(
                      color: Colors.white54, fontSize: 13),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⌘K',
                    style: GoogleFonts.cairo(
                        color: Colors.white60, fontSize: 10),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  HeaderIconBtn — زر أيقونة في الهيدر
//  ✅ إصلاح: إضافة onTap اختياري
// ════════════════════════════════════════════════════════
class HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const HeaderIconBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}

// ════════════════════════════════════════════════════════
//  SectionHeader — عنوان القسم بأيقونة ملوّنة
// ════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ]);
}

// ════════════════════════════════════════════════════════
//  InfoDivider — فاصل أقسام خفيف
// ════════════════════════════════════════════════════════
class InfoDivider extends StatelessWidget {
  const InfoDivider({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(height: 1, color: const Color(0xFFEEF2F7)),
      );
}

// ════════════════════════════════════════════════════════
//  SectionTitle — عنوان داخل الكارت (مع دائرة أيقونة)
// ════════════════════════════════════════════════════════
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  ✅ إضافة جديدة: EmptyState — شاشة فارغة موحدة
// ════════════════════════════════════════════════════════
class EmptyState extends StatelessWidget {
  final String emoji, title, subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    actionLabel!,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════
//  ✅ إضافة جديدة: LoadingOverlay — طبقة تحميل
// ════════════════════════════════════════════════════════
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x22000000), blurRadius: 20)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 3),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(message!,
                          style: GoogleFonts.cairo(
                              fontSize: 13, color: AppColors.textGray)),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}