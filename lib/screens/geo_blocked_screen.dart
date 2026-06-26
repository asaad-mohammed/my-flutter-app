import 'package:flutter/material.dart';
import '../core/services/geo_restriction_service.dart';

class GeoBlockedScreen extends StatelessWidget {
  final GeoBlockReason reason;
  const GeoBlockedScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final isVpn = reason == GeoBlockReason.vpnDetected;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── الأيقونة ─────────────────────────────────
              _BlockIcon(isVpn: isVpn),
              const SizedBox(height: 32),

              // ── العنوان ──────────────────────────────────
              Text(
                isVpn ? 'تم اكتشاف VPN' : 'التطبيق غير متاح\nفي منطقتك',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // ── الوصف ────────────────────────────────────
              Text(
                isVpn
                    ? 'يبدو أنك تستخدم VPN أو Proxy.\nهذا التطبيق لا يدعم الاتصال عبر VPN.'
                    : 'تطبيق إغاثة مخصص للمستخدمين\nداخل جمهورية العراق فقط.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // ── البطاقة التوجيهية ─────────────────────────
              if (isVpn) const _VpnInstructionCard(),
              if (!isVpn) const _IraqOnlyCard(),

              const Spacer(flex: 3),

              // ── معلومات إضافية في الأسفل ──────────────────
              const _FooterNote(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── أيقونة الحظر ───────────────────────────────────────
class _BlockIcon extends StatelessWidget {
  final bool isVpn;
  const _BlockIcon({required this.isVpn});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الدائرة الخارجية
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isVpn
                ? const Color(0xFFFFF3CD)
                : const Color(0xFFFFEBEE),
          ),
        ),
        // الدائرة الداخلية
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isVpn
                ? const Color(0xFFFFE08A)
                : const Color(0xFFFFCDD2),
          ),
          child: Icon(
            isVpn ? Icons.vpn_lock_rounded : Icons.public_off_rounded,
            size: 44,
            color: isVpn
                ? const Color(0xFFE65100)
                : const Color(0xFFC62828),
          ),
        ),
      ],
    );
  }
}

// ─── بطاقة تعليمات VPN ──────────────────────────────────
class _VpnInstructionCard extends StatelessWidget {
  const _VpnInstructionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tips_and_updates_rounded,
                    color: Color(0xFFE65100), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'كيف تحل المشكلة؟',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Step(number: '١', text: 'افتح إعدادات هاتفك'),
          _Step(number: '٢', text: 'ابحث عن "VPN" أو "الشبكة"'),
          _Step(number: '٣', text: 'أوقف تشغيل الـ VPN'),
          _Step(number: '٤', text: 'أعد فتح التطبيق', isLast: true),
        ],
      ),
    );
  }
}

// ─── خطوة واحدة ─────────────────────────────────────────
class _Step extends StatelessWidget {
  final String number;
  final String text;
  final bool isLast;
  const _Step({required this.number, required this.text, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة العراق فقط ───────────────────────────────────
class _IraqOnlyCard extends StatelessWidget {
  const _IraqOnlyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🇮🇶', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متاح في العراق فقط',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'هذا التطبيق مخصص للمواطنين\nالعراقيين داخل البلاد.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.5,
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

// ─── ملاحظة الأسفل ──────────────────────────────────────
class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'إذا كنت داخل العراق وتواجه هذه المشكلة\nتواصل مع الدعم الفني',
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF9CA3AF),
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }
}