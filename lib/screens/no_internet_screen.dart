import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetScreen({super.key, required this.onRetry});

  // روابط الاشتراك بالإنترنت عبر الرصيد
  static const _operators = [
    _IraqiOperator(
      name: 'آسيا سيل',
      nameEn: 'AsiaCell',
      icon: '📱',
      color: Color(0xFF006E3C),
      ussdCode: '*141#',
      appUrl: 'https://play.google.com/store/apps/details?id=com.asiacell.selfcare',
      websiteUrl: 'https://asiacell.com/packages',
      packages: [
        _Package(name: 'يومي 50 ميغا', price: '250 دينار', code: '*141*1#'),
        _Package(name: 'أسبوعي 1 غيغا', price: '1,500 دينار', code: '*141*2#'),
        _Package(name: 'شهري 5 غيغا', price: '5,000 دينار', code: '*141*3#'),
      ],
    ),
    _IraqiOperator(
      name: 'إيثر',
      nameEn: 'Earthlink / Korek',
      icon: '🌐',
      color: Color(0xFF0066CC),
      ussdCode: '*100#',
      appUrl: 'https://play.google.com/store/apps/details?id=com.korek.selfcare',
      websiteUrl: 'https://korektel.com/packages',
      packages: [
        _Package(name: 'يومي 100 ميغا', price: '500 دينار', code: '*100*1#'),
        _Package(name: 'أسبوعي 2 غيغا', price: '2,500 دينار', code: '*100*2#'),
        _Package(name: 'شهري 10 غيغا', price: '8,000 دينار', code: '*100*3#'),
      ],
    ),
    _IraqiOperator(
      name: 'كورك',
      nameEn: 'Korek Telecom',
      icon: '📶',
      color: Color(0xFFE3000F),
      ussdCode: '*888#',
      appUrl: 'https://play.google.com/store/apps/details?id=com.zain.iraq',
      websiteUrl: 'https://zain.com/iq/packages',
      packages: [
        _Package(name: 'يومي 200 ميغا', price: '750 دينار', code: '*888*1#'),
        _Package(name: 'أسبوعي 3 غيغا', price: '3,500 دينار', code: '*888*2#'),
        _Package(name: 'شهري 15 غيغا', price: '12,000 دينار', code: '*888*3#'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 52, color: Color(0xFFB0BEC5)),
                  const SizedBox(height: 12),
                  const Text(
                    'لا يوجد اتصال بالإنترنت',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اشترك بباقة إنترنت من خلال رصيدك',
                    style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // قائمة المشغلين
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _operators.length,
                itemBuilder: (context, index) =>
                    _OperatorCard(operator: _operators[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── بطاقة المشغل ───────────────────────────────────────
class _OperatorCard extends StatelessWidget {
  final _IraqiOperator operator;
  const _OperatorCard({required this.operator});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: operator.color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(operator.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operator.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: operator.color,
                        ),
                      ),
                      Text(
                        operator.nameEn,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),
                ),
                // زر الاشتراك السريع عبر USSD
                _ActionButton(
                  label: operator.ussdCode,
                  icon: Icons.dialpad_rounded,
                  color: operator.color,
                  onTap: () => _dialUssd(operator.ussdCode),
                ),
              ],
            ),
          ),

          // الباقات
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الباقات المتاحة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 8),
                ...operator.packages
                    .map((p) => _PackageTile(package: p, color: operator.color)),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'التطبيق',
                        icon: Icons.download_rounded,
                        color: operator.color,
                        onTap: () => _openUrl(operator.appUrl),
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'الموقع',
                        icon: Icons.language_rounded,
                        color: operator.color,
                        onTap: () => _openUrl(operator.websiteUrl),
                        outlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _dialUssd(String code) async {
    // إزالة # من الكود لأن بعض الأجهزة تحتاج encoding
    final encoded = Uri.encodeFull('tel:${code.replaceAll('#', '%23')}');
    final uri = Uri.parse(encoded);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _PackageTile extends StatelessWidget {
  final _Package package;
  final Color color;
  const _PackageTile({required this.package, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              package.name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
            ),
          ),
          Text(
            package.price,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _dialCode(package.code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'اشترك',
                style:
                    TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _dialCode(String code) async {
    final encoded = Uri.parse('tel:${Uri.encodeComponent(code)}');
    if (await canLaunchUrl(encoded)) {
      await launchUrl(encoded);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          border: Border.all(color: color, width: outlined ? 1 : 0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15, color: outlined ? color : Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: outlined ? color : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────
class _IraqiOperator {
  final String name, nameEn, icon, ussdCode, appUrl, websiteUrl;
  final Color color;
  final List<_Package> packages;
  const _IraqiOperator({
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.ussdCode,
    required this.appUrl,
    required this.websiteUrl,
    required this.packages,
  });
}

class _Package {
  final String name, price, code;
  const _Package({required this.name, required this.price, required this.code});
}