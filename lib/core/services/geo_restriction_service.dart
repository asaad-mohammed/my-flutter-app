import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoRestrictionService {
  /// يتحقق من أن المستخدم داخل العراق وليس مستخدماً VPN حقيقياً.
  ///
  /// ملاحظات مهمة حول التصحيح:
  /// 1) لا نعتمد على حقل "hosting" لتحديد VPN، لأن شبكات الجوال العراقية
  ///    (آسيا سيل/زين/كورك) تستخدم CGNAT وتتشارك مدى IP مع مزودي سحابة،
  ///    مما يجعل ip-api.com/ipapi.co يضعان علامة "hosting=true" خطأ.
  /// 2) نعتمد VPN/Proxy فقط إذا أكّد المصدر ذلك صراحة عبر "proxy" أو
  ///    "is_vpn" أو "is_tor" — وليس "hosting" وحدها.
  /// 3) إذا فشلت كل مصادر الشبكة (انقطاع الخدمة، rate limit، إلخ) فإننا
  ///    لا نحظر المستخدم تلقائياً بل نسمح بالدخول (fail-open) مع تسجيل
  ///    الخطأ، لأن حظر مستخدم حقيقي بسبب خطأ في خدمة خارجية ثالثة هو
  ///    تجربة استخدام سيئة جداً. يمكن تغيير هذا السلوك حسب الحاجة.
  static Future<GeoCheckResult> checkAccess() async {
    try {
      final result = await _checkWithMultipleSources();
      return result;
    } catch (e) {
      // فشلت كل المصادر الخارجية (وليس بالضرورة لا يوجد إنترنت،
      // فهذا الفحص يحدث بعد التأكد من وجود إنترنت في الشاشة السابقة).
      // الأفضل هنا هو السماح بالدخول مؤقتاً بدل حظر مستخدم عراقي حقيقي.
      // print('GeoRestrictionService: all sources failed -> fail-open. $e');
      return GeoCheckResult(isAllowed: true, reason: null);
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

        // إذا أعاد المصدر رسالة خطأ (مثل rate limit) تجاهله وجرّب التالي
        if (data['error'] == true) {
          throw Exception('ipapi.co error: ${data['reason']}');
        }

        final country = (data['country_code'] as String? ?? '').toUpperCase();
        if (country.isEmpty) {
          throw Exception('ipapi.co returned empty country');
        }

        // كشف VPN/Proxy حقيقي فقط — تجاهل حقل hosting المضلل
        final threat = data['threat'];
        final isVpn = threat != null &&
            (threat['is_vpn'] == true ||
                threat['is_proxy'] == true ||
                threat['is_tor'] == true);

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
    } catch (_) {
      // نتابع للمصدر التالي
    }

    // المصدر الثاني: ip-api.com (احتياطي)
    try {
      final response = await http
          .get(Uri.parse(
              'http://ip-api.com/json/?fields=status,countryCode,proxy,mobile,message'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] != 'success') {
          throw Exception('ip-api.com error: ${data['message']}');
        }

        final country = (data['countryCode'] as String? ?? '').toUpperCase();
        if (country.isEmpty) {
          throw Exception('ip-api.com returned empty country');
        }

        // proxy=true فقط يُعتمد لكشف VPN/Proxy. لا نستخدم hosting لأنه
        // يعطي نتائج كاذبة كثيرة على شبكات الجوال العراقية.
        // إذا كان mobile=true فهذا يدعم أنه اتصال جوال حقيقي (ليس VPN).
        final isMobile = data['mobile'] == true;
        final isProxy = data['proxy'] == true && !isMobile;

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
    } catch (_) {
      // نتابع
    }

    // المصدر الثالث: ipwho.is (احتياطي إضافي، مجاني وبدون مفتاح API)
    try {
      final response = await http
          .get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == false) {
          throw Exception('ipwho.is error: ${data['message']}');
        }

        final country = (data['country_code'] as String? ?? '').toUpperCase();
        if (country.isEmpty) {
          throw Exception('ipwho.is returned empty country');
        }

        final connection = data['connection'];
        final isMobile = connection != null && connection['type'] == 'mobile';
        // ipwho.is لا يوفر كشف proxy مباشر في الخطة المجانية، فنعتمد
        // فقط على الدولة من هذا المصدر كحَكَم نهائي للموقع.
        if (country != 'IQ') {
          return GeoCheckResult(
            isAllowed: false,
            reason: GeoBlockReason.outsideIraq,
          );
        }
        return GeoCheckResult(isAllowed: true, reason: null);
      }
    } catch (_) {
      // نتابع
    }

    // إذا فشلت كل المصادر الثلاثة، نرمي استثناءً يُعالَج بـ fail-open
    // في checkAccess() أعلاه.
    throw Exception('Failed to check location: all sources unavailable');
  }
}

enum GeoBlockReason { outsideIraq, vpnDetected, noInternet }

class GeoCheckResult {
  final bool isAllowed;
  final GeoBlockReason? reason;

  GeoCheckResult({required this.isAllowed, required this.reason});
}