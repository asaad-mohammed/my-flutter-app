// ════════════════════════════════════════════════════════
//  widgets/rating_dialog.dart
//  ✅ إصلاح: منطق shouldShow (يظهر بعد 3 فتحات فقط لا دائماً)
//  ✅ إصلاح: معالجة خطأ context.mounted قبل showDialog
//  ✅ تحسين: أنيميشن النجوم
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

// ════════════════════════════════════════════════════════
//  RatingManager — منطق متى يظهر التقييم
// ════════════════════════════════════════════════════════
class RatingManager {
  static const _keyCount = 'app_open_count';
  static const _keyRated = 'app_rated';
  static const _keyLastSkip = 'app_rating_skipped_at';
  static const _showAfter = 3; // ✅ إصلاح: يظهر بعد 3 فتحات فعلاً
  static const _remindDays = 3; // تذكير بعد 3 أيام من التخطي

  // ✅ إصلاح: منطق shouldShow الصحيح
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();

    // لا تُظهر إذا قيّم المستخدم مسبقاً
    if (prefs.getBool(_keyRated) == true) return false;

    // فحص التخطي — هل مضت 3 أيام؟
    final skipMs = prefs.getInt(_keyLastSkip);
    if (skipMs != null) {
      final skippedAt = DateTime.fromMillisecondsSinceEpoch(skipMs);
      if (DateTime.now().difference(skippedAt).inDays < _remindDays) {
        return false;
      }
    }

    final count = prefs.getInt(_keyCount) ?? 0;
    return count >= _showAfter;
  }

  static Future<void> incrementCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyCount) ?? 0) + 1;
    await prefs.setInt(_keyCount, count);
  }

  static Future<void> markRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRated, true);
  }

  static Future<void> markSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSkip, DateTime.now().millisecondsSinceEpoch);
  }

  /// استدعِ هذه في initState لكل شاشة رئيسية
  static Future<void> checkAndShow(BuildContext context, bool isAr) async {
    await incrementCount();
    if (await shouldShow()) {
      // ✅ إصلاح: التحقق من context.mounted قبل await
      if (!context.mounted) return;
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) showRatingDialog(context, isAr: isAr);
    }
  }
}

// ════════════════════════════════════════════════════════
//  showRatingDialog — دالة إظهار نافذة التقييم
// ════════════════════════════════════════════════════════
void showRatingDialog(BuildContext context, {required bool isAr}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.elasticOut);
      return ScaleTransition(
        scale: curved,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: _RatingDialog(isAr: isAr),
        ),
      );
    },
  );
}

// ════════════════════════════════════════════════════════
//  _RatingDialog — الواجهة الكاملة
// ════════════════════════════════════════════════════════
class _RatingDialog extends StatefulWidget {
  final bool isAr;
  const _RatingDialog({required this.isAr});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog>
    with SingleTickerProviderStateMixin {
  int _stars = 0;
  final _commentCtrl = TextEditingController();
  bool _submitted = false;
  late AnimationController _successCtrl;
  late Animation<double> _successAnim;

  // أسئلة سريعة بناءً على التقييم
  final Map<int, List<String>> _quickAr = {
    1: ['صعب الاستخدام', 'بطيء', 'أخطاء كثيرة', 'لا يفيدني'],
    2: ['يحتاج تحسين', 'غير مكتمل', 'واجهة معقدة'],
    3: ['جيد لكن...', 'يحتاج ميزات', 'سريع الاستجابة'],
    4: ['سهل الاستخدام', 'مفيد جداً', 'أنصح به'],
    5: ['ممتاز!', 'أنقذ حياتي', 'الأفضل', 'سريع ودقيق'],
  };
  final Map<int, List<String>> _quickEn = {
    1: ['Hard to use', 'Too slow', 'Many bugs', "Doesn't help"],
    2: ['Needs improvement', 'Incomplete', 'Complex UI'],
    3: ['Good but...', 'Needs features', 'Fast enough'],
    4: ['Easy to use', 'Very helpful', 'Recommend it'],
    5: ['Excellent!', 'Life-saver!', 'The best', 'Fast & accurate'],
  };
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successAnim =
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) return; // ✅ إصلاح: لا إرسال بدون نجوم
    await RatingManager.markRated();
    setState(() => _submitted = true);
    _successCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _skip() async {
    await RatingManager.markSkipped();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 30,
                  offset: Offset(0, 10)),
            ],
          ),
          child: _submitted ? _buildSuccess(isAr) : _buildForm(isAr),
        ),
      ),
    );
  }

  // ── شاشة النجاح ──────────────────────────────────────
  Widget _buildSuccess(bool isAr) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _successAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                ),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? 'شكراً لك! 🙏' : 'Thank you! 🙏',
            style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? 'رأيك يساعدنا على تحسين تطبيق إغاثة وتقديم خدمة أفضل'
                : 'Your feedback helps us improve Ighatha',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
                fontSize: 13, color: AppColors.textGray, height: 1.5),
          ),
        ]),
      );

  // ── نموذج التقييم ─────────────────────────────────────
  Widget _buildForm(bool isAr) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        // هيدر
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.headerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr
                        ? 'قيّم تجربتك مع إغاثة'
                        : 'Rate your Ighatha experience',
                    style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  Text(
                    isAr
                        ? 'رأيك يساعدنا على التحسين المستمر'
                        : 'Your feedback drives our improvement',
                    style:
                        GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _skip,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(children: [
            // ── النجوم ──
            Text(
              _stars == 0
                  ? (isAr
                      ? 'كم تقيّم هذا التطبيق؟'
                      : 'How do you rate this app?')
                  : _starLabel(isAr, _stars),
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starNum = i + 1;
                final filled = starNum <= _stars;
                return GestureDetector(
                  onTap: () => setState(() {
                    _stars = starNum;
                    _selectedTags.clear();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedScale(
                      scale: filled ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: filled
                            ? const Color(0xFFFFC107)
                            : Colors.grey.shade300,
                        size: 42,
                      ),
                    ),
                  ),
                );
              }),
            ),

            // ── أوصاف النجوم ──
            if (_stars > 0) ...[
              const SizedBox(height: 16),
              Text(
                isAr
                    ? 'ما الذي ينطبق على تجربتك؟'
                    : 'What describes your experience?',
                style:
                    GoogleFonts.cairo(fontSize: 12, color: AppColors.textGray),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    (isAr ? _quickAr[_stars] : _quickEn[_stars])!.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected)
                        _selectedTags.remove(tag);
                      else
                        _selectedTags.add(tag);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(tag,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textDark,
                          )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // حقل التعليق
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _commentCtrl,
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: 3,
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: isAr
                        ? 'أضف تعليقاً (اختياري)...'
                        : 'Add a comment (optional)...',
                    hintStyle: GoogleFonts.cairo(
                        fontSize: 12, color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _stars > 0 ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isAr ? 'إرسال التقييم' : 'Submit Rating',
                    style: GoogleFonts.cairo(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            // ── زر التخطي إن لم يختر نجوم بعد ──
            if (_stars == 0)
              TextButton(
                onPressed: _skip,
                child: Text(
                  isAr ? 'ربما لاحقاً' : 'Maybe later',
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: AppColors.textGray),
                ),
              ),
          ]),
        ),
      ]);

  String _starLabel(bool isAr, int stars) {
    final ar = ['رديء 😞', 'ضعيف 😕', 'مقبول 🙂', 'جيد 😊', 'ممتاز! 🌟'];
    final en = ['Poor 😞', 'Fair 😕', 'Good 🙂', 'Great 😊', 'Excellent! 🌟'];
    return isAr ? ar[stars - 1] : en[stars - 1];
  }
}