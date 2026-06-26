// ════════════════════════════════════════════════════════
//  screens/welcome_screen.dart
// ════════════════════════════════════════════════════════
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/app_strings.dart';
import '../core/providers/app_providers.dart';
import 'login_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _waveController;
  late AnimationController _particlesController;
  late AnimationController _pulseController;
  late AnimationController _imageController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _scaleLogo;
  late Animation<double> _waveAnimation;
  late Animation<double> _particlesAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _imageFloatAnimation;
  late Animation<double> _heroImageScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _runSequence();
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    _scaleLogo = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );

    _particlesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particlesController,
        curve: Curves.linear,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _imageFloatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: Curves.easeInOut,
      ),
    );

    _heroImageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
  }

  Future<void> _runSequence() async {
    await _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _waveController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _toggleLanguage() {
    final isAr = ref.read(languageProvider);
    ref.read(languageProvider.notifier).set(!isAr);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);
    final s = AppStrings.of(isAr);
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            _AnimatedGradientBackground(
              waveAnimation: _waveAnimation,
              particlesAnimation: _particlesAnimation,
              size: size,
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(
                    children: [
                      // الشريط العلوي
                      _ModernTopBar(
                        isAr: isAr,
                        onLangTap: _toggleLanguage,
                      ),

                      // المحتوى الرئيسي في المنتصف
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // الصورة الرئيسية الكبيرة (Hero Image)
                                AnimatedBuilder(
                                  animation: Listenable.merge([
                                    _imageFloatAnimation,
                                    _pulseAnimation,
                                    _heroImageScale,
                                  ]),
                                  builder: (_, __) {
                                    return Transform.translate(
                                      offset: Offset(0, _imageFloatAnimation.value),
                                      child: Transform.scale(
                                        scale: _heroImageScale.value * _pulseAnimation.value,
                                        child: Container(
                                          width: size.width * 0.85,
                                          height: size.height * 0.35,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF0288D1).withValues(alpha: 0.3),
                                                blurRadius: 30,
                                                spreadRadius: 5,
                                                offset: const Offset(0, 15),
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                                offset: const Offset(0, -5),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(24),
                                            child: Image.asset(
                                              'images/a.png',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (_, __, ___) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xFF0288D1),
                                                      const Color(0xFF4FC3F7),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(24),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported_rounded,
                                                    color: Colors.white,
                                                    size: 50,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // الشعار النصي
                                ScaleTransition(
                                  scale: _scaleLogo,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isAr ? s.appName : s.appNameEn,
                                        style: GoogleFonts.cairo(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          isAr ? 'نظام إدارة الطوارئ والإغاثة' : 'Emergency & Relief Management',
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: const Color(0xFFB3E5FC),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // الإحصائيات
                                _ModernStatsRow(isAr: isAr),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // البطاقة السفلية
                      _ModernBottomCard(
                        s: s,
                        isAr: isAr,
                        onLogin: _goToLogin,
                        onContact: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  خلفية متدرجة متحركة مع موجات
// ════════════════════════════════════════════════════════
class _AnimatedGradientBackground extends StatelessWidget {
  final Animation<double> waveAnimation;
  final Animation<double> particlesAnimation;
  final Size size;

  const _AnimatedGradientBackground({
    required this.waveAnimation,
    required this.particlesAnimation,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveAnimation,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF003C6E),
                Color(0xFF0288D1),
                Color(0xFF4FC3F7),
                Color(0xFFB3E5FC),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              CustomPaint(
                painter: _WavePainter(progress: waveAnimation.value),
                size: size,
              ),
              CustomPaint(
                painter: _ParticlesPainter(progress: particlesAnimation.value),
                size: size,
              ),
              ..._buildDecorCircles(size),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorCircles(Size size) {
    return [
      Positioned(
        top: -size.width * 0.15,
        right: -size.width * 0.1,
        child: _GlowCircle(
          size: size.width * 0.5,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      Positioned(
        bottom: size.height * 0.3,
        left: -size.width * 0.2,
        child: _GlowCircle(
          size: size.width * 0.6,
          color: const Color(0xFF4FC3F7).withValues(alpha: 0.06),
        ),
      ),
      Positioned(
        top: size.height * 0.2,
        left: size.width * 0.1,
        child: _GlowCircle(
          size: size.width * 0.3,
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
    ];
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.12;
    final startY = size.height * 0.5;

    path.moveTo(0, startY);
    for (double x = 0; x <= size.width; x++) {
      final y = startY +
          waveHeight * (0.5 + math.sin(x / size.width * math.pi * 2 + progress * math.pi * 2) * 0.5);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  _ParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23 + progress * 100) % size.height;
      final radius = 2.0 + (i % 4).toDouble();
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.3,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  الشريط العلوي
// ════════════════════════════════════════════════════════
class _ModernTopBar extends StatelessWidget {
  final bool isAr;
  final VoidCallback onLangTap;
  const _ModernTopBar({required this.isAr, required this.onLangTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: onLangTap,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'English' : 'عربي',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  صف الإحصائيات
// ════════════════════════════════════════════════════════
class _ModernStatsRow extends StatelessWidget {
  final bool isAr;
  const _ModernStatsRow({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _ModernStatCard(
              value: isAr ? '٢٤/٧' : '24/7',
              label: isAr ? 'استجابة فورية' : 'Instant Response',
              icon: Icons.flash_on_rounded,
              color: const Color(0xFFFFD54F),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ModernStatCard(
              value: isAr ? '+٥٠٠' : '+500',
              label: isAr ? 'متطوع ميداني' : 'Field Volunteer',
              icon: Icons.people_rounded,
              color: const Color(0xFF4FC3F7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ModernStatCard(
              value: isAr ? '١٨' : '18',
              label: isAr ? 'محافظة' : 'Governorate',
              icon: Icons.location_on_rounded,
              color: const Color(0xFF81C784),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _ModernStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 9,
              color: const Color(0xFFB3E5FC),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  البطاقة السفلية
// ════════════════════════════════════════════════════════
class _ModernBottomCard extends StatelessWidget {
  final AppStrings s;
  final bool isAr;
  final VoidCallback onLogin, onContact;

  const _ModernBottomCard({
    required this.s,
    required this.isAr,
    required this.onLogin,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFF),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          ..._buildFeatures(),

          const SizedBox(height: 16),

          _GradientActionButton(
            label: s.login,
            icon: Icons.arrow_forward_rounded,
            onTap: onLogin,
          ),

          const SizedBox(height: 12),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textMuted),
              children: [
                TextSpan(text: s.legalPre),
                TextSpan(
                  text: s.privacyPolicy,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: s.legalMid),
                TextSpan(
                  text: s.terms,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          TextButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.headset_mic_rounded, size: 14),
            label: Text(
              s.contactUs,
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatures() {
    final features = isAr
        ? [
            FeatureItem(
              icon: Icons.emergency_rounded,
              label: 'اتصال طوارئ فوري',
              color: Colors.redAccent,
            ),
            FeatureItem(
              icon: Icons.location_on_rounded,
              label: 'مشاركة الموقع الجغرافي',
              color: const Color(0xFF4CAF50),
            ),
            FeatureItem(
              icon: Icons.people_rounded,
              label: 'شبكة متطوعين ميدانيين',
              color: const Color(0xFF2196F3),
            ),
          ]
        : [
            FeatureItem(
              icon: Icons.emergency_rounded,
              label: 'Instant emergency call',
              color: Colors.redAccent,
            ),
            FeatureItem(
              icon: Icons.location_on_rounded,
              label: 'Real-time GPS sharing',
              color: const Color(0xFF4CAF50),
            ),
            FeatureItem(
              icon: Icons.people_rounded,
              label: 'Field volunteer network',
              color: const Color(0xFF2196F3),
            ),
          ];

    return features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: feature,
        )).toList();
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Icon(Icons.check_circle_rounded, color: color, size: 16),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  زر متدرج مع أنيميشن
// ════════════════════════════════════════════════════════
class _GradientActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<_GradientActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, const Color(0xFF00ACC1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(widget.icon, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}