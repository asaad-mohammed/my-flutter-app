// ════════════════════════════════════════════════════════
// core/widgets/access_guard.dart
// ويدجت غلاف يراقب الإنترنت و VPN/الموقع باستمرار طوال استخدام
// التطبيق (بعد شاشة الـ Splash)، ويظهر حوار تنبيه فوق الشاشة
// الحالية دون فقدان مكان المستخدم، ويختفي تلقائياً عند حل المشكلة.
// ════════════════════════════════════════════════════════
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/geo_restriction_service.dart';

/// لفّ أي شاشة (مثلاً HomeScreen) بهذا الويدجت لتفعيل المراقبة
/// المستمرة للإنترنت و VPN/الموقع طوال بقاء المستخدم فيها.
class AccessGuard extends StatefulWidget {
  final Widget child;

  /// مدة الفحص الدوري في الخلفية
  final Duration interval;

  const AccessGuard({
    super.key,
    required this.child,
    this.interval = const Duration(seconds: 30),
  });

  @override
  State<AccessGuard> createState() => AccessGuardState();
}

class AccessGuardState extends State<AccessGuard>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _dialogShowing = false;
  bool _checkInFlight = false;
  _BlockKind? _currentBlock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // فحص فوري عند رجوع المستخدم للتطبيق (مثلاً بعد تفعيل VPN من
    // الإعدادات والرجوع للتطبيق)
    if (state == AppLifecycleState.resumed) {
      checkNow();
    }
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(widget.interval, (_) => checkNow());
  }

  /// يمكن استدعاؤها يدوياً من أي مكان في التطبيق (مثلاً عند فتح صفحة
  /// مهمة أو الضغط على زر SOS) للحصول على فحص فوري غير دوري.
  Future<void> checkNow() async {
    if (_checkInFlight) return;
    _checkInFlight = true;
    try {
      final hasInternet =
          await ConnectivityService.hasRealInternetAccess().timeout(
        const Duration(seconds: 8),
        onTimeout: () => false,
      );

      if (!hasInternet) {
        _showBlock(_BlockKind.noInternet);
        return;
      }

      final geoResult = await GeoRestrictionService.checkAccess().timeout(
        const Duration(seconds: 12),
        onTimeout: () => GeoCheckResult(isAllowed: true, reason: null),
      );

      if (!geoResult.isAllowed) {
        if (geoResult.reason == GeoBlockReason.vpnDetected) {
          _showBlock(_BlockKind.vpn);
        } else {
          _showBlock(_BlockKind.outsideIraq);
        }
        return;
      }

      // كل شيء سليم → أغلق الحوار إذا كان معروضاً
      _hideBlockIfNeeded();
    } finally {
      _checkInFlight = false;
    }
  }

  void _showBlock(_BlockKind kind) {
    if (!mounted) return;

    if (_dialogShowing) {
      if (_currentBlock == kind) return; // نفس السبب، لا تكرر فتح حوار
      // السبب تغيّر (مثلاً من "لا إنترنت" إلى "VPN") — أغلق القديم
      // وافتح حواراً جديداً بالسبب الصحيح.
      Navigator.of(context, rootNavigator: true).pop();
    }

    _currentBlock = kind;
    _dialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AccessBlockedDialog(
        kind: kind,
        onRetry: () async {
          await checkNow();
        },
      ),
    ).then((_) {
      _dialogShowing = false;
      _currentBlock = null;
    });
  }

  void _hideBlockIfNeeded() {
    if (_dialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

enum _BlockKind { noInternet, vpn, outsideIraq }

// ─── حوار التنبيه الذي يغطي الشاشة الحالية ──────────────────
class _AccessBlockedDialog extends StatefulWidget {
  final _BlockKind kind;
  final Future<void> Function() onRetry;
  const _AccessBlockedDialog({required this.kind, required this.onRetry});

  @override
  State<_AccessBlockedDialog> createState() => _AccessBlockedDialogState();
}

class _AccessBlockedDialogState extends State<_AccessBlockedDialog> {
  bool _retrying = false;

  Future<void> _handleRetry() async {
    setState(() => _retrying = true);
    await widget.onRetry();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final config = _dialogConfig(widget.kind);

    return PopScope(
      canPop: false, // منع إغلاقه بزر الرجوع
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: config.bgColor,
                ),
                child: Icon(config.icon, size: 36, color: config.iconColor),
              ),
              const SizedBox(height: 18),
              Text(
                config.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                config.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _retrying ? null : _handleRetry,
                  icon: _retrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(_retrying ? 'جاري التحقق...' : 'حاول مجدداً'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _DialogConfig _dialogConfig(_BlockKind kind) {
    switch (kind) {
      case _BlockKind.noInternet:
        return _DialogConfig(
          icon: Icons.wifi_off_rounded,
          iconColor: const Color(0xFF1565C0),
          bgColor: const Color(0xFFE3F2FD),
          title: 'انقطع الاتصال بالإنترنت',
          message: 'تحقق من اتصالك بالإنترنت ثم اضغط "حاول مجدداً" للاستمرار من حيث توقفت.',
        );
      case _BlockKind.vpn:
        return _DialogConfig(
          icon: Icons.vpn_lock_rounded,
          iconColor: const Color(0xFFE65100),
          bgColor: const Color(0xFFFFF3CD),
          title: 'تم اكتشاف VPN',
          message: 'يرجى إيقاف تشغيل VPN أو Proxy من إعدادات هاتفك، ثم اضغط "حاول مجدداً".',
        );
      case _BlockKind.outsideIraq:
        return _DialogConfig(
          icon: Icons.public_off_rounded,
          iconColor: const Color(0xFFC62828),
          bgColor: const Color(0xFFFFEBEE),
          title: 'التطبيق غير متاح في منطقتك',
          message: 'هذا التطبيق مخصص للاستخدام داخل جمهورية العراق فقط.',
        );
    }
  }
}

class _DialogConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String message;
  _DialogConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.message,
  });
}