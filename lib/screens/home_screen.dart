// ════════════════════════════════════════════════════════
//  screens/home_screen.dart
//  ✅ تبويبات: حسابي | ميزات | رئيسي | خريطة | الزون الصحي
//  ✅ شريط تنقل (5 عناصر)
//  ✅ زر SOS عائم
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/providers/app_providers.dart';
import 'widgets/rating_dialog.dart';
import 'tabs/emergency_tab.dart';
import 'tabs/features_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/zone_tab.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 2; // تغيير إلى 2 لأن الرئيسي الآن في المنتصف
  late AnimationController _fabCtrl;
  late Animation<double>   _fabScale;

  final List<Widget> _pages = [
    const ProfileTab(),   // 0 - حسابي
    const FeaturesTab(),  // 1 - الميزات
    const EmergencyTab(), // 2 - الرئيسي (الطوارئ)
    const MapTab(),       // 3 - الخريطة
    const ZoneTab(),      // 4 - الزون الصحي
  ];

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fabScale = CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fabCtrl.forward();
      final user = ref.read(sessionProvider);
      if (user != null && !user.isGuest) {
        final isAr = ref.read(languageProvider);
        RatingManager.checkAndShow(context, isAr);
      }
    });
  }

  @override
  void dispose() { _fabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr    = ref.watch(languageProvider);
    final user    = ref.watch(sessionProvider);
    final isGuest = user?.isGuest ?? false;

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      body: Column(children: [
        if (isGuest)
          _GuestBanner(
            isAr: isAr,
            onLogin: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        Expanded(child: IndexedStack(index: _tab, children: _pages)),
      ]),

      floatingActionButton: _tab != 2  // تغيير إلى 2 (الرئيسي)
          ? ScaleTransition(
              scale: _fabScale,
              child: _SosFAB(isAr: isAr, onTap: () {
                HapticFeedback.heavyImpact();
                setState(() => _tab = 2);  // العودة إلى تبويب الطوارئ
              }),
            )
          : null,

      bottomNavigationBar: _BottomNav(
        current: _tab,
        isAr: isAr,
        onTap: (i) {
          if (isGuest && i == 0) { _showGuestDialog(context, isAr); return; }
          HapticFeedback.selectionClick();
          setState(() => _tab = i);
        },
      ),
    );
  }

  void _showGuestDialog(BuildContext ctx, bool isAr) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAr ? 'ميزة محدودة' : 'Limited Feature',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        content: Text(
          isAr ? 'سجّل دخولك للوصول إلى ملفك الشخصي وجميع الميزات.'
               : 'Sign in to access your profile and all features.',
          style: GoogleFonts.cairo(color: AppColors.textGray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'لاحقاً' : 'Later', style: GoogleFonts.cairo())),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(isAr ? 'تسجيل الدخول' : 'Sign In',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  شريط التنقل السفلي — 5 عناصر
//  الترتيب: حسابي | ميزات | رئيسي | خريطة | الزون الصحي
// ════════════════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final int current;
  final bool isAr;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<_NavItem2> items = [
      _NavItem2(
        icon: Icons.person_outline_rounded, 
        activeIcon: Icons.person_rounded,
        labelAr: 'حسابي', 
        labelEn: 'Profile', 
        index: 0,
      ),
      _NavItem2(
        icon: Icons.star_outline_rounded, 
        activeIcon: Icons.star_rounded,
        labelAr: 'ميزات', 
        labelEn: 'Features', 
        index: 1,
        activeColor: const Color(0xFFFF6D00),
      ),
      _NavItem2(
        icon: Icons.home_outlined, 
        activeIcon: Icons.home_rounded,
        labelAr: 'رئيسي', 
        labelEn: 'Home', 
        index: 2, 
        isCenter: true,
      ),
      _NavItem2(
        icon: Icons.map_outlined, 
        activeIcon: Icons.map_rounded,
        labelAr: 'خريطة', 
        labelEn: 'Map', 
        index: 3,
        activeColor: const Color(0xFF1565C0),
      ),
      _NavItem2(
        icon: Icons.health_and_safety_outlined, 
        activeIcon: Icons.health_and_safety_rounded,
        labelAr: 'الزون', 
        labelEn: 'Zone', 
        index: 4,
        activeColor: const Color(0xFF7B1FA2),
      ),
    ];

    final displayItems = isAr ? items.reversed.toList() : items;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF0F9FF)],
          ),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0288D1).withOpacity(0.14),
                blurRadius: 24, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 10, offset: const Offset(0, 3)),
          ],
          border: Border.all(color: const Color(0xFF0288D1).withOpacity(0.10), width: 0.8),
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayItems.map((item) {
            final active = item.index == current;
            return Flexible(
              child: _NavItemWidget(
                data: item, active: active, isAr: isAr,
                onTap: () => onTap(item.index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem2 {
  final IconData icon, activeIcon;
  final String labelAr, labelEn;
  final int index;
  final bool isCenter;
  final Color? activeColor;
  const _NavItem2({
    required this.icon, required this.activeIcon,
    required this.labelAr, required this.labelEn, required this.index,
    this.isCenter = false, this.activeColor,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem2 data;
  final bool active, isAr;
  final VoidCallback onTap;
  const _NavItemWidget({required this.data, required this.active, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? (data.activeColor ?? AppColors.primary) : const Color(0xFF90A4AE);
    final label = isAr ? data.labelAr : data.labelEn;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? (data.isCenter ? color : color.withOpacity(0.12))
                  : Colors.transparent,
              boxShadow: active && data.isCenter
                  ? [BoxShadow(color: color.withOpacity(0.38), blurRadius: 14, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Icon(
              active ? data.activeIcon : data.icon,
              color: active && data.isCenter ? Colors.white : color,
              size: data.isCenter ? 26 : 23,
            ),
          ),
          const SizedBox(height: 1),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.cairo(
              fontSize: 9.5,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? color : const Color(0xFF90A4AE),
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  زر SOS عائم
// ════════════════════════════════════════════════════════
class _SosFAB extends StatefulWidget {
  final bool isAr; final VoidCallback onTap;
  const _SosFAB({required this.isAr, required this.onTap});
  @override State<_SosFAB> createState() => _SosFABState();
}

class _SosFABState extends State<_SosFAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _pulse,
    child: GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFC62828)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: const Color(0xFFE53935).withOpacity(0.45),
              blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
          Text('SOS', style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.w900,
              color: Colors.white, height: 1.1)),
        ]),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════
//  شريط تحذير الضيف
// ════════════════════════════════════════════════════════
class _GuestBanner extends StatelessWidget {
  final bool isAr; final VoidCallback onLogin;
  const _GuestBanner({required this.isAr, required this.onLogin});

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF01579B),
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text(
          isAr ? 'أنت تستخدم التطبيق كضيف — بعض الميزات غير متاحة'
               : 'Guest mode — some features are unavailable',
          style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70))),
        GestureDetector(
          onTap: onLogin,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Text(isAr ? 'دخول' : 'Login',
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary))),
        ),
      ]),
    )),
  );
}