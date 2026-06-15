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
  bool _animationDone = false;
  bool _checksStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// يُشغَّل بعد انتهاء الأنيميشن — يجري الفحوصات ثم ينتقل
  Future<void> _runChecksAndNavigate() async {
    if (_checksStarted) return;
    _checksStarted = true;

    // 1️⃣ هل يوجد إنترنت؟
    final hasInternet = await ConnectivityService.hasRealInternetAccess();
    if (!hasInternet) {
      _navigateTo(NoInternetScreen(onRetry: _onRetryAfterInternet));
      return;
    }

    // 2️⃣ هل المستخدم في العراق وبدون VPN؟
    final geoResult = await GeoRestrictionService.checkAccess();
    if (!geoResult.isAllowed) {
      _navigateTo(GeoBlockedScreen(reason: geoResult.reason!));
      return;
    }

    // ✅ كل شيء سليم → الصفحة الرئيسية
    _navigateTo(const WelcomeScreen());
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// عند الضغط على "إعادة المحاولة" في شاشة لا إنترنت
  void _onRetryAfterInternet() {
    setState(() => _checksStarted = false);
    _runChecksAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.network(
                  "https://lottie.host/8da744ac-26aa-466c-8ec9-2a41a4fcf684/VQpCVwo8yN.json",
                  controller: _controller,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                    _controller.forward().then((_) {
                      _animationDone = true;
                      _runChecksAndNavigate(); // ← نقطة الانطلاق
                    });
                  },
                ),
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.blue,
                    BlendMode.srcIn,
                  ),
                  child: Lottie.asset(
                    "lib/assets/arb.json",
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}