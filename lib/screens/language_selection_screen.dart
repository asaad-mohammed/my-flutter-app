
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_strings.dart';
import '../core/providers/app_providers.dart';
import '../core/theme/app_colors.dart';
import 'welcome_screen.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fade = CurvedAnimation(parent: _mainCtrl, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutBack));

    _mainCtrl.forward();
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    super.dispose();
  }

  void _onLanguagePicked(bool isAr) {
    ref.read(languageProvider.notifier).set(isAr);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);
    final s = AppStrings.of(isAr);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Stack(
        children: [
          _buildAnimatedBackground(size),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                FadeTransition(
                  opacity: _fade,
                  child: _buildHeaderIcon(),
                ),
                const SizedBox(height: 32),
                _buildTextContent(s, isAr),
                const Spacer(),
                SlideTransition(
                  position: _slide,
                  child: _LanguagePanel(
                    currentIsAr: isAr,
                    onSelect: _onLanguagePicked,
                    title: s.selectLang,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return Positioned(
      top: -size.height * 0.15,
      right: -size.width * 0.2,
      child: Container(
        width: size.width * 0.8,
        height: size.width * 0.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.08),
              AppColors.primary.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.gpp_maybe_rounded,
                size: 65, color: AppColors.primary),
            _PulseCircle(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(AppStrings s, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            s.appName,
            style: GoogleFonts.cairo(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'نحن هنا لنحمي عالمك' : 'Protecting your world',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAr
                ? 'اختر لغتك المفضلة لبدء استخدام خدماتنا الأمنية'
                : 'Select your preferred language for safety services',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textGray.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _LanguagePanel
// ════════════════════════════════════════════════════════
class _LanguagePanel extends StatelessWidget {
  final bool currentIsAr;
  final Function(bool) onSelect;
  final String title;

  const _LanguagePanel({
    required this.currentIsAr,
    required this.onSelect,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(44)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 28),
          _LanguageTile(
            label: 'العربية',
            subLabel: 'التطبيق باللغة الأم',
            icon: 'Ar',
            isSelected: currentIsAr,
            onTap: () => onSelect(true),
          ),
          const SizedBox(height: 16),
          _LanguageTile(
            label: 'English',
            subLabel: 'Global safety standard',
            icon: 'En',
            isSelected: !currentIsAr,
            onTap: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _LanguageTile
// ════════════════════════════════════════════════════════
class _LanguageTile extends StatelessWidget {
  final String label, subLabel, icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            _buildIconBox(),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textGray,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1E88E5)])
            : LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade100]),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        icon,
        style: GoogleFonts.montserrat(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _PulseCircle
// ════════════════════════════════════════════════════════
class _PulseCircle extends StatefulWidget {
  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.4).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: Tween(begin: 0.3, end: 0.0).animate(_ctrl),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}