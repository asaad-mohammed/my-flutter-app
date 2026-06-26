// ════════════════════════════════════════════════════════
//  tabs/profile_tab.dart  — تصميم القائمة الجديد
//  ✅ مطابق لتصميم الصورة المرجعية مع الحفاظ على اللون الأزرق
//  ✅ إختيار اللغة (عربي / إنجليزي / كردي) + الوضع الداكن + سياسة الخصوصية
//  ✅ الضغط على الاسم يفتح صفحة معلوماتي
//  ✅ تمت إضافة بطاقة "أفراد العائلة" لشبكة الخيارات
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/data/mock_users.dart';
import '../../core/providers/app_providers.dart' hide familyProvider;
import '../../core/providers/family_provider.dart';
import '../login_screen.dart';
import 'first_aid_tab.dart';
import '../emergency_contacts_screen.dart';
import 'family_tab.dart';

// ────────────────────────────────────────────────────────
//  لغات التطبيق المدعومة في هذه الصفحة
// ────────────────────────────────────────────────────────
enum AppLang { ar, en, ku }

extension AppLangX on AppLang {
  bool get isRtl => this != AppLang.en; // العربية والكردية كلاهما من اليمين لليسار
  String get nativeName => switch (this) {
        AppLang.ar => 'العربية',
        AppLang.en => 'English',
        AppLang.ku => 'کوردی',
      };
}

/// دالة ترجمة مساعدة: تُعيد النص المناسب حسب اللغة المختارة.
String tr(AppLang lang, {required String ar, required String en, required String ku}) {
  switch (lang) {
    case AppLang.ar:
      return ar;
    case AppLang.en:
      return en;
    case AppLang.ku:
      return ku;
  }
}

// ────────────────────────────────────────────────────────
//  Provider اللغة (عربي/إنجليزي/كردي) بنفس نمط Notifier
//  المستخدم في باقي المشروع
// ────────────────────────────────────────────────────────
class AppLanguageNotifier extends Notifier<AppLang> {
  @override
  AppLang build() => AppLang.ar;

  void set(AppLang lang) => state = lang;
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLang>(
  AppLanguageNotifier.new,
);

// ────────────────────────────────────────────────────────
//  Provider محلي لحالة الوضع الداكن (بنفس نمط Notifier
//  المستخدم في باقي المشروع - بدون الحاجة لـ StateProvider)
// ────────────────────────────────────────────────────────
class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _logout() {
    ref.read(sessionProvider.notifier).logout();
    ref.read(authProvider.notifier).resetError();
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (ctx, anim, sec) => const LoginScreen(),
      transitionsBuilder: (ctx, a, sec, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _confirmLogout(AppLang lang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          tr(lang, ar: 'تسجيل الخروج', en: 'Logout', ku: 'چوونەدەرەوە'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          tr(lang,
              ar: 'هل أنت متأكد من تسجيل الخروج؟',
              en: 'Are you sure you want to logout?',
              ku: 'دڵنیایت لە چوونەدەرەوە؟'),
          style: GoogleFonts.cairo(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr(lang, ar: 'إلغاء', en: 'Cancel', ku: 'هەڵوەشاندنەوە'),
                style: GoogleFonts.cairo(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              tr(lang, ar: 'تسجيل الخروج', en: 'Logout', ku: 'چوونەدەرەوە'),
              style: GoogleFonts.cairo(color: AppColors.danger, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _openMyInfo(MockUser user, AppLang lang) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyInfoScreen(user: user, lang: lang)),
    );
  }

  void _openLanguageSheet(AppLang lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(lang: lang, ref: ref),
    );
  }

  void _openPrivacyPolicy(AppLang lang) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PrivacyPolicyScreen(lang: lang)),
    );
  }

  void _openHealthCard(MockUser user, AppLang lang) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _HealthCardScreen(user: user, lang: lang)),
    );
  }

  void _openReportsLog(AppLang lang) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ReportsLogScreen(lang: lang)),
    );
  }

  void _openContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
    );
  }

  void _openFirstAid() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FirstAidTab()),
    );
  }

  void _openFamily() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FamilyTab()),
    );
  }

  void _openComplaints(AppLang lang) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ComplaintsScreen(lang: lang)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final user = ref.watch(sessionProvider);
    final isDark = ref.watch(darkModeProvider);

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _logout());
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: FadeTransition(
          opacity: _fade,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── رأس الصفحة ──
                _MenuHeader(lang: lang),
                const SizedBox(height: 14),

                // ── بطاقة المستخدم (قابلة للضغط) ──
                _UserRow(user: user, lang: lang, onTap: () => _openMyInfo(user, lang)),
                const SizedBox(height: 16),

                // ── شبكة الخيارات ──
                _MenuGrid(
                  lang: lang,
                  onHealthCard: () => _openHealthCard(user, lang),
                  onFamily: _openFamily,
                  onContacts: _openContacts,
                  onFirstAid: _openFirstAid,
                  onReports: () => _openReportsLog(lang),
                  onComplaints: () => _openComplaints(lang),
                ),
                const SizedBox(height: 26),

                // ── قسم الحساب والتطبيق ──
                Text(
                  tr(lang, ar: 'الحساب والتطبيق', en: 'Account & App', ku: 'هەژمار و ئەپ'),
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: AppColors.textGray, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _SettingsList(
                  lang: lang,
                  isDark: isDark,
                  onLanguageTap: () => _openLanguageSheet(lang),
                  onDarkModeChanged: (v) =>
                      ref.read(darkModeProvider.notifier).set(v),
                  onPrivacyTap: () => _openPrivacyPolicy(lang),
                ),
                const SizedBox(height: 22),

                // ── تسجيل الخروج ──
                _LogoutButton(lang: lang, onTap: () => _confirmLogout(lang)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _MenuHeader
// ════════════════════════════════════════════════════════
class _MenuHeader extends StatelessWidget {
  final AppLang lang;
  const _MenuHeader({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          lang.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          color: AppColors.textGray,
        ),
      ),
      Expanded(
        child: Center(
          child: Text(
            tr(lang, ar: 'القائمة الرئيسية', en: 'Main Menu', ku: 'مینیوی سەرەکی'),
            style: GoogleFonts.cairo(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
        ),
      ),
      const SizedBox(width: 38),
    ]);
  }
}

// ════════════════════════════════════════════════════════
//  _UserRow
// ════════════════════════════════════════════════════════
class _UserRow extends StatelessWidget {
  final MockUser user;
  final AppLang lang;
  final VoidCallback onTap;
  const _UserRow({required this.user, required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showAr = lang != AppLang.en;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_rounded, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                showAr ? user.nameAr : user.nameEn,
                style: GoogleFonts.cairo(
                    fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 2),
              Text(
                '${user.age} ${tr(lang, ar: "سنة", en: "yrs", ku: "ساڵ")}',
                style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textGray),
              ),
            ]),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.nameAr.isNotEmpty ? user.nameAr[0] : '؟',
                style: GoogleFonts.cairo(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _MenuGrid — شبكة بطاقات الخيارات
// ════════════════════════════════════════════════════════
class _MenuGrid extends StatelessWidget {
  final AppLang lang;
  final VoidCallback onHealthCard, onFamily, onContacts, onFirstAid, onReports, onComplaints;
  const _MenuGrid({
    required this.lang,
    required this.onHealthCard,
    required this.onFamily,
    required this.onContacts,
    required this.onFirstAid,
    required this.onReports,
    required this.onComplaints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: _MenuCard(
          icon: Icons.favorite_rounded,
          label: tr(lang, ar: 'البطاقة الصحية', en: 'Health Card', ku: 'کارتی تەندروستی'),
          onTap: onHealthCard,
        )),
        const SizedBox(width: 10),
        Expanded(child: _MenuCard(
          icon: Icons.family_restroom_rounded,
          label: tr(lang, ar: 'أفراد العائلة', en: 'Family Members', ku: 'ئەندامانی خێزان'),
          onTap: onFamily,
        )),
        const SizedBox(width: 10),
        Expanded(child: _MenuCard(
          icon: Icons.contact_phone_rounded,
          label: tr(lang, ar: 'جهات الإتصال', en: 'Contacts', ku: 'کەسانی پەیوەندی'),
          onTap: onContacts,
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _MenuCard(
          icon: Icons.medical_services_rounded,
          label: tr(lang, ar: 'الإسعافات الأولية', en: 'First Aid', ku: 'یاریدەی پێشەکی'),
          onTap: onFirstAid,
        )),
        const SizedBox(width: 10),
        Expanded(child: _MenuCard(
          icon: Icons.campaign_rounded,
          label: tr(lang, ar: 'سجل البلاغات', en: 'Reports Log', ku: 'تۆماری ڕاپۆرتەکان'),
          onTap: onReports,
        )),
        const SizedBox(width: 10),
        Expanded(child: _MenuCard(
          icon: Icons.chat_bubble_rounded,
          label: tr(lang, ar: 'الاقتراحات والشكاوى', en: 'Feedback', ku: 'سکالا و پێشنیار'),
          onTap: onComplaints,
        )),
      ]),
    ]);
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFF2F7)),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
                fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _SettingsList — اللغة / الوضع الداكن / سياسة الخصوصية
// ════════════════════════════════════════════════════════
class _SettingsList extends StatelessWidget {
  final AppLang lang;
  final bool isDark;
  final VoidCallback onLanguageTap, onPrivacyTap;
  final ValueChanged<bool> onDarkModeChanged;
  const _SettingsList({
    required this.lang,
    required this.isDark,
    required this.onLanguageTap,
    required this.onDarkModeChanged,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(children: [
        _SettingsRow(
          icon: Icons.public_rounded,
          label: tr(lang, ar: 'إختيار اللغة', en: 'Language', ku: 'هەلبژاردنی زمان'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(lang.nativeName,
                style: GoogleFonts.cairo(fontSize: 12.5, color: AppColors.textGray)),
            const SizedBox(width: 4),
            Icon(
              lang.isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              color: AppColors.textGray, size: 20,
            ),
          ]),
          onTap: onLanguageTap,
        ),
        _divider(),
        _SettingsRow(
          icon: Icons.dark_mode_rounded,
          label: tr(lang, ar: 'الوضع الداكن', en: 'Dark Mode', ku: 'دۆخی تاریک'),
          trailing: Switch(
            value: isDark,
            onChanged: onDarkModeChanged,
            activeThumbColor: AppColors.primary,
          ),
          onTap: () => onDarkModeChanged(!isDark),
        ),
        _divider(),
        _SettingsRow(
          icon: Icons.privacy_tip_rounded,
          label: tr(lang, ar: 'سياسة الخصوصية', en: 'Privacy Policy', ku: 'سیاسەتی تایبەتمەندی'),
          trailing: Icon(
            lang.isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            color: AppColors.textGray, size: 20,
          ),
          onTap: onPrivacyTap,
        ),
      ]),
    );
  }

  Widget _divider() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        height: 0.6,
        color: const Color(0xFFF0F3F8),
      );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          trailing,
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _LogoutButton
// ════════════════════════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  final AppLang lang;
  final VoidCallback onTap;
  const _LogoutButton({required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          tr(lang, ar: 'تسجيل الخروج', en: 'Logout', ku: 'چوونەدەرەوە'),
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _LanguageSheet
// ════════════════════════════════════════════════════════
class _LanguageSheet extends StatelessWidget {
  final AppLang lang;
  final WidgetRef ref;
  const _LanguageSheet({required this.lang, required this.ref});

  void _select(BuildContext context, AppLang newLang) {
    ref.read(appLanguageProvider.notifier).set(newLang);
    // نحافظ على توافق باقي التطبيق: العربية والكردية كلاهما RTL
    ref.read(languageProvider.notifier).state = newLang != AppLang.en;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFE0E7F0), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text(tr(lang, ar: 'إختيار اللغة', en: 'Choose Language', ku: 'هەلبژاردنی زمان'),
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        _LangOption(
          label: 'العربية', selected: lang == AppLang.ar,
          onTap: () => _select(context, AppLang.ar),
        ),
        const SizedBox(height: 8),
        _LangOption(
          label: 'English', selected: lang == AppLang.en,
          onTap: () => _select(context, AppLang.en),
        ),
        const SizedBox(height: 8),
        _LangOption(
          label: 'کوردی', selected: lang == AppLang.ku,
          onTap: () => _select(context, AppLang.ku),
        ),
      ]),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18, color: selected ? AppColors.primary : AppColors.textGray),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.cairo(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.textDark)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  MyInfoScreen — معلوماتي (تظهر عند الضغط على الاسم)
// ════════════════════════════════════════════════════════
class MyInfoScreen extends StatelessWidget {
  final MockUser user;
  final AppLang lang;
  const MyInfoScreen({super.key, required this.user, required this.lang});

  @override
  Widget build(BuildContext context) {
    final showAr = lang != AppLang.en;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg, elevation: 0,
        title: Text(tr(lang, ar: 'معلوماتي', en: 'My Info', ku: 'زانیاریەکانم'),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2)),
                child: Center(
                  child: Text(
                    user.nameAr.isNotEmpty ? user.nameAr[0] : '؟',
                    style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(showAr ? user.nameAr : user.nameEn,
                  style: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(showAr ? user.nameEn : user.nameAr,
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 16),
          _InfoBox(children: [
            _InfoRow(label: tr(lang, ar: 'رقم الهوية', en: 'National ID', ku: 'ژمارەی ناسنامە'), value: user.id, icon: Icons.badge_outlined),
            _InfoRow(label: tr(lang, ar: 'رقم الهاتف', en: 'Phone', ku: 'ژمارەی مۆبایل'), value: user.phone, icon: Icons.phone_rounded),
            _InfoRow(label: tr(lang, ar: 'الجنسية', en: 'Nationality', ku: 'هاوڵاتیێتی'), value: user.nationality, icon: Icons.flag_rounded),
            _InfoRow(label: tr(lang, ar: 'الجنس', en: 'Gender', ku: 'ڕەگەز'), value: user.gender, icon: Icons.person_rounded),
            _InfoRow(label: tr(lang, ar: 'العمر', en: 'Age', ku: 'تەمەن'), value: '${user.age}', icon: Icons.cake_rounded),
          ]),
        ]),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final List<Widget> children;
  const _InfoBox({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 12, offset: Offset(0, 3))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: children),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.cairo(fontSize: 12.5, color: AppColors.textGray))),
          Text(value, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  _HealthCardScreen — البطاقة الصحية
// ════════════════════════════════════════════════════════
class _HealthCardScreen extends StatelessWidget {
  final MockUser user;
  final AppLang lang;
  const _HealthCardScreen({required this.user, required this.lang});

  @override
  Widget build(BuildContext context) {
    final none = tr(lang, ar: 'لا يوجد', en: 'None', ku: 'بوونی نییە');
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg, elevation: 0,
        title: Text(tr(lang, ar: 'البطاقة الصحية', en: 'Health Card', ku: 'کارتی تەندروستی'),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _InfoBox(children: [
          _InfoRow(label: tr(lang, ar: 'فصيلة الدم', en: 'Blood Type', ku: 'گروپی خوێن'), value: user.bloodType, icon: Icons.bloodtype_rounded),
          _InfoRow(label: tr(lang, ar: 'الأمراض المزمنة', en: 'Chronic Diseases', ku: 'نەخۆشیی درێژخایەن'),
              value: user.chronicDiseases.isEmpty ? none : user.chronicDiseases,
              icon: Icons.monitor_heart_rounded),
          _InfoRow(label: tr(lang, ar: 'الحساسية', en: 'Allergies', ku: 'هەستیاری'),
              value: user.allergies.isEmpty ? none : user.allergies,
              icon: Icons.warning_rounded),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ReportsLogScreen — سجل البلاغات
// ════════════════════════════════════════════════════════
class _ReportsLogScreen extends ConsumerWidget {
  final AppLang lang;
  const _ReportsLogScreen({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(familyProvider).reports;
    final showAr = lang != AppLang.en;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg, elevation: 0,
        title: Text(tr(lang, ar: 'سجل البلاغات', en: 'Reports Log', ku: 'تۆماری ڕاپۆرتەکان'),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: reports.isEmpty
          ? Center(
              child: Text(
                tr(lang, ar: 'لا يوجد بلاغات حتى الآن', en: 'No reports yet', ku: 'هیچ ڕاپۆرتێک نییە تا ئێستا'),
                style: GoogleFonts.cairo(color: AppColors.textGray),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (_, i) {
                final r = reports[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Row(children: [
                    Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.emergencyType, style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                        Text(showAr ? r.patient.nameAr : r.patient.nameEn,
                            style: GoogleFonts.cairo(fontSize: 11.5, color: AppColors.textGray)),
                      ]),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ComplaintsScreen — الاقتراحات والشكاوى
// ════════════════════════════════════════════════════════
class _ComplaintsScreen extends StatefulWidget {
  final AppLang lang;
  const _ComplaintsScreen({required this.lang});
  @override State<_ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<_ComplaintsScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg, elevation: 0,
        title: Text(tr(lang, ar: 'الاقتراحات والشكاوى', en: 'Feedback', ku: 'سکالا و پێشنیار'),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            tr(lang,
                ar: 'أرسل ملاحظاتك أو شكواك لنا',
                en: 'Send us your feedback or complaint',
                ku: 'سکالا یان پێشنیارەکەت بۆ ئێمە بنێرە'),
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textGray),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            maxLines: 6,
            style: GoogleFonts.cairo(fontSize: 13),
            decoration: InputDecoration(
              hintText: tr(lang,
                  ar: 'اكتب رسالتك هنا...',
                  en: 'Write your message here...',
                  ku: 'نامەکەت لێرە بنووسە...'),
              hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: AppColors.textHint),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    tr(lang,
                        ar: 'تم إرسال رسالتك بنجاح',
                        en: 'Your message has been sent',
                        ku: 'نامەکەت بە سەرکەوتویی نێردرا'),
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
                _ctrl.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: Text(tr(lang, ar: 'إرسال', en: 'Send', ku: 'ناردن'),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _PrivacyPolicyScreen — سياسة الخصوصية
// ════════════════════════════════════════════════════════
class _PrivacyPolicyScreen extends StatelessWidget {
  final AppLang lang;
  const _PrivacyPolicyScreen({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg, elevation: 0,
        title: Text(tr(lang, ar: 'سياسة الخصوصية', en: 'Privacy Policy', ku: 'سیاسەتی تایبەتمەندی'),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 12, offset: Offset(0, 3))],
          ),
          child: Text(
            tr(lang,
                ar: 'نحرص على حماية بياناتك الشخصية والطبية المسجّلة في التطبيق، ولا تتم مشاركتها إلا مع جهات الطوارئ المختصة عند إرسال نداء استغاثة فعلي. يمكنك حذف بياناتك أو تعديلها في أي وقت من صفحة الملف الشخصي.',
                en: 'We protect your personal and medical data registered in the app. It is only shared with emergency authorities when an actual SOS is sent. You may edit or delete your data at any time from your profile page.',
                ku: 'ئێمە زانیاری کەسی و پزیشکیت کە لە ئەپەکەدا تۆمارکراوە دەپارێزین، و تەنها لەگەڵ دەسەلاتەکانی فریاگوزاری بەکاردێت کاتێک بانگەوازی فریاگوزاری ڕاستەقینە دەنێردرێت. دەتوانیت لە هەر کاتێکدا زانیاریەکانت لە پەیجی پرۆفایلت بگۆڕیت یان بسڕیتەوە.'),
            style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark, height: 1.8),
          ),
        ),
      ),
    );
  }
}