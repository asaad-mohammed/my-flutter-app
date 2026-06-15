// ════════════════════════════════════════════════════════
//  screens/login_screen.dart
// ════════════════════════════════════════════════════════
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/providers/app_providers.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {  
  late AnimationController _mainController;
  late AnimationController _waveController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _scaleLogo;
  late Animation<double> _waveAnimation;

  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _showPass = false;
  bool _isResident = true;
  bool _guestLoading = false;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000),
    );
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _fadeIn = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );
    
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleLogo = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );
    
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _waveController.dispose();
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _guestLoading = false);
    final success = await ref.read(authProvider.notifier).login(
      id: _idCtrl.text,
      password: _passCtrl.text,
      isResident: _isResident,
    );
    if (success && mounted) _goHome();
  }

  Future<void> _loginAsGuest() async {
    FocusScope.of(context).unfocus();
    setState(() => _guestLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ref.read(sessionProvider.notifier).loginAsGuest();
    _goHome();
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _fillDemo() {
    setState(() {
      _idCtrl.text = _isResident ? '199512345678' : 'V1234567';
      _passCtrl.text = '1';
    });
    ref.read(authProvider.notifier).resetError();
  }

  void _showResetDialog() {
    final isAr = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF5F9FF)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAr ? 'استعادة كلمة المرور' : 'Reset Password',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'سيتم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني'
                    : 'A reset link will be sent to your email',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(isAr ? 'إلغاء' : 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isAr ? 'إرسال' : 'Send',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);
    final auth = ref.watch(authProvider);
    final loading = auth.status == AuthStatus.loading;
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            _AnimatedBackground(size: size),
            _AnimatedWaves(waveAnimation: _waveAnimation, size: size),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.05),
                        
                        ScaleTransition(
                          scale: _scaleLogo,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFE3F2FD)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.medical_services_rounded,
                                size: 50,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Text(
                          isAr ? 'مرحباً بك في إغاثة' : 'Welcome to Ighatha',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? 'حماية فورية · استجابة سريعة' : 'Instant Protection · Fast Response',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        _ModernGuestCard(
                          isAr: isAr,
                          isLoading: _guestLoading,
                          onTap: _loginAsGuest,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _ElegantDivider(isAr: isAr),
                        
                        const SizedBox(height: 24),
                        
                        _GlassCard(
                          child: Column(
                            children: [
                              _ModernUserTypeTab(
                                isResident: _isResident,
                                residentLabel: isAr ? 'مواطن / مقيم' : 'Resident',
                                visitorLabel: isAr ? 'زائر' : 'Visitor',
                                onChange: (v) {
                                  setState(() {
                                    _isResident = v;
                                    _idCtrl.clear();
                                    _passCtrl.clear();
                                  });
                                  ref.read(authProvider.notifier).resetError();
                                },
                              ),
                              
                              const SizedBox(height: 24),
                              
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _ModernTextField(
                                      controller: _idCtrl,
                                      label: _isResident
                                          ? (isAr ? 'رقم الهوية' : 'National ID')
                                          : (isAr ? 'رقم الجواز' : 'Passport'),
                                      prefixIcon: Icons.badge_outlined,
                                      keyboardType: _isResident ? TextInputType.number : TextInputType.text,
                                      inputFormatters: _isResident
                                          ? [FilteringTextInputFormatter.digitsOnly]
                                          : null,
                                      validator: (v) => (v?.isEmpty ?? true)
                                          ? (isAr ? 'مطلوب' : 'Required')
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _ModernTextField(
                                      controller: _passCtrl,
                                      label: isAr ? 'كلمة المرور' : 'Password',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: !_showPass,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showPass
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: AppColors.textGray,
                                        ),
                                        onPressed: () => setState(() => _showPass = !_showPass),
                                      ),
                                      validator: (v) => (v?.isEmpty ?? true)
                                          ? (isAr ? 'مطلوب' : 'Required')
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              
                              if (auth.status == AuthStatus.error && auth.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                _ModernErrorBanner(message: auth.errorMessage!),
                              ],
                              
                              const SizedBox(height: 16),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _HelpLink(
                                    label: isAr ? 'نسيت كلمة المرور؟' : 'Forgot password?',
                                    onTap: _showResetDialog,
                                  ),
                                  _HelpLink(
                                    label: isAr ? 'ملء تجريبي' : 'Fill Demo',
                                    onTap: _fillDemo,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              _GradientButton(
                                label: isAr ? 'تسجيل الدخول' : 'Sign In',
                                isLoading: loading,
                                onTap: _submit,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAr ? 'ليس لديك حساب؟' : "Don't have an account?",
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                isAr ? 'إنشاء حساب' : 'Create account',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
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
//  خلفية متحركة
// ════════════════════════════════════════════════════════
class _AnimatedBackground extends StatelessWidget {
  final Size size;
  const _AnimatedBackground({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF01477A),
            Color(0xFF0288D1),
            Color(0xFF00ACC1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  موجات زخرفية متحركة
// ════════════════════════════════════════════════════════
class _AnimatedWaves extends StatelessWidget {
  final Animation<double> waveAnimation;
  final Size size;
  const _AnimatedWaves({required this.waveAnimation, required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: waveAnimation,
        builder: (_, __) {
          return CustomPaint(
            painter: _WavePainter(progress: waveAnimation.value),
            size: size,
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final waveHeight = size.height * 0.15;
    final startY = size.height * 0.3;
    
    path.moveTo(0, startY);
    for (double x = 0; x <= size.width; x++) {
      final y = startY + 
          waveHeight * (progress * 0.5 + 0.5) * 
          (1 + math.sin(x / size.width * math.pi)) * 0.5;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _WavePainter && oldDelegate.progress != progress;
  }
}

// ════════════════════════════════════════════════════════
//  بطاقة زجاجية (Glassmorphism)
// ════════════════════════════════════════════════════════
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ════════════════════════════════════════════════════════
//  بطاقة الدخول كضيف (مطورة)
// ════════════════════════════════════════════════════════
class _ModernGuestCard extends StatefulWidget {
  final bool isAr, isLoading;
  final VoidCallback onTap;
  const _ModernGuestCard({
    required this.isAr,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_ModernGuestCard> createState() => _ModernGuestCardState();
}

class _ModernGuestCardState extends State<_ModernGuestCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHovered
                ? const [Color(0xFF00ACC1), Color(0xFF0288D1)]
                : const [Color(0xFF0288D1), Color(0xFF00B0FF)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0288D1).withValues(alpha: 0.4),
              blurRadius: _isHovered ? 25 : 15,
              offset: Offset(0, _isHovered ? 8 : 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: widget.isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person_pin_circle_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isAr ? 'دخول سريع كضيف' : 'Instant Guest Access',
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isAr
                              ? 'استعرض التطبيق بدون تسجيل'
                              : 'Explore app without registration',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isLoading)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isAr
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  فاصل أنيق
// ════════════════════════════════════════════════════════
class _ElegantDivider extends StatelessWidget {
  final bool isAr;
  const _ElegantDivider({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  تبويب المستخدم الحديث
// ════════════════════════════════════════════════════════
class _ModernUserTypeTab extends StatelessWidget {
  final bool isResident;
  final String residentLabel, visitorLabel;
  final ValueChanged<bool> onChange;

  const _ModernUserTypeTab({
    required this.isResident,
    required this.residentLabel,
    required this.visitorLabel,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AnimatedTab(
              label: residentLabel,
              isActive: isResident,
              onTap: () => onChange(true),
            ),
          ),
          Expanded(
            child: _AnimatedTab(
              label: visitorLabel,
              isActive: !isResident,
              onTap: () => onChange(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textGray,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  حقل نصي حديث
// ════════════════════════════════════════════════════════
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _ModernTextField({
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.textGray),
        floatingLabelStyle: GoogleFonts.cairo(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textGray, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: AppColors.primary, width: 2),
        errorBorder: _border(color: Colors.redAccent),
        focusedErrorBorder: _border(color: Colors.redAccent, width: 2),
      ),
    );
  }

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color ?? const Color(0xFFE2E8F0),
        width: width,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  رابط مساعدة
// ════════════════════════════════════════════════════════
class _HelpLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _HelpLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  زر متدرج
// ════════════════════════════════════════════════════════
class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF00ACC1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  رسالة خطأ حديثة
// ════════════════════════════════════════════════════════
class _ModernErrorBanner extends StatelessWidget {
  final String message;
  const _ModernErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}