import 'package:flutter/material.dart';
import '../core/services/geo_restriction_service.dart';

class GeoBlockedScreen extends StatelessWidget {
  final GeoBlockReason reason;
  const GeoBlockedScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final isVpn = reason == GeoBlockReason.vpnDetected;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.block_rounded,
                    size: 52, color: Color(0xFFC62828)),
              ),
              const SizedBox(height: 28),
              Text(
                isVpn ? 'تم الكشف عن VPN' : 'غير متاح في منطقتك',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isVpn
                    ? 'يبدو أنك تستخدم VPN أو Proxy.\nيرجى إيقاف تشغيله وإعادة المحاولة.'
                    : 'هذا التطبيق متاح للمستخدمين\nداخل العراق فقط 🇮🇶',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (isVpn)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFF8F00), width: 0.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: Color(0xFFE65100), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'أوقف تشغيل VPN من الإعدادات\nثم أعد فتح التطبيق',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}