import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoRestrictionService {
  /// يتحقق من أن المستخدم داخل العراق وليس مستخدماً VPN
  static Future<GeoCheckResult> checkAccess() async {
    try {
      // نجرب عدة مصادر للتحقق من الموقع
      final result = await _checkWithMultipleSources();
      return result;
    } catch (e) {
      // إذا فشل الاتصال، افترض أنه خارج العراق أو بدون إنترنت
      return GeoCheckResult(
        isAllowed: false,
        reason: GeoBlockReason.noInternet,
      );
    }
  }

  static Future<GeoCheckResult> _checkWithMultipleSources() async {
    // المصدر الأول: ipapi.co
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final country = data['country_code'] as String? ?? '';
        final isVpn = data['threat'] != null &&
            (data['threat']['is_vpn'] == true ||
                data['threat']['is_proxy'] == true ||
                data['threat']['is_tor'] == true);

        if (country != 'IQ') {
          return GeoCheckResult(
            isAllowed: false,
            reason: GeoBlockReason.outsideIraq,
          );
        }
        if (isVpn) {
          return GeoCheckResult(
            isAllowed: false,
            reason: GeoBlockReason.vpnDetected,
          );
        }
        return GeoCheckResult(isAllowed: true, reason: null);
      }
    } catch (_) {}

    // المصدر الثاني: ip-api.com (احتياطي)
    try {
      final response = await http
          .get(Uri.parse(
              'http://ip-api.com/json/?fields=status,countryCode,proxy,hosting'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final country = data['countryCode'] as String? ?? '';
        final isProxy = data['proxy'] == true || data['hosting'] == true;

        if (country != 'IQ') {
          return GeoCheckResult(
            isAllowed: false,
            reason: GeoBlockReason.outsideIraq,
          );
        }
        if (isProxy) {
          return GeoCheckResult(
            isAllowed: false,
            reason: GeoBlockReason.vpnDetected,
          );
        }
        return GeoCheckResult(isAllowed: true, reason: null);
      }
    } catch (_) {}

    // إذا فشلت كل المصادر
    throw Exception('Failed to check location');
  }
}

enum GeoBlockReason { outsideIraq, vpnDetected, noInternet }

class GeoCheckResult {
  final bool isAllowed;
  final GeoBlockReason? reason;

  GeoCheckResult({required this.isAllowed, required this.reason});
}