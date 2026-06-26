import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/geo_restriction_service.dart';
import 'geo_blocked_screen.dart';
import 'no_internet_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isChecking = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // الأنيميشن يُشغَّل فقط للعرض المرئي، ولا يُستخدم بعد الآن كمحفّز
    // لبدء الفحوصات — الفحوصات تبدأ فوراً في initState (انظر أدناه).
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward();

    // بدء الفحوصات فوراً عند فتح الشاشة، بالتوازي مع الأنيميشن، بدل
    // انتظار اكتمال الأنيميشن أولاً. بهذا لو كان الاتصال سريعاً يمكن
    // الانتقال لشاشة WelcomeScreen مباشرة دون انتظار الأنيميشن الكامل.
    _runChecksAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runChecksAndNavigate() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      // 1️⃣ هل يوجد إنترنت؟
      final hasInternet = await ConnectivityService.hasRealInternetAccess()
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
      if (!mounted) return;

      if (!hasInternet) {
        _navigateTo(const NoInternetScreen());
        return;
      }

      // 2️⃣ هل المستخدم في العراق وبدون VPN؟
      final geoResult = await GeoRestrictionService.checkAccess().timeout(
        const Duration(seconds: 20),
        onTimeout: () => GeoCheckResult(isAllowed: true, reason: null),
      );
      if (!mounted) return;

      if (!geoResult.isAllowed) {
        _navigateTo(GeoBlockedScreen(reason: geoResult.reason!));
        return;
      }

      // ✅ كل شيء سليم → الصفحة الرئيسية
      _navigateTo(const WelcomeScreen());
    } finally {
      _isChecking = false;
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted || _navigated) return;
    _navigated = true; // حماية من استدعاء التنقل مرتين
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/dr_robot.png', width: 200, height: 200),
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
              child: Lottie.asset(
                "lib/assets/arb.json",
                width: 200,
                height: 200,
                controller: _controller,
                repeat: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}