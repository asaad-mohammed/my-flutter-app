import 'dart:async';
import 'dart:io';

class ConnectivityService {
  // عدة نطاقات موثوقة للتحقق — بعض الشبكات العراقية قد تحجب أو
  // تكون بطيئة مع نطاق واحد بعينه (مثل google.com)، لذلك نجرب أكثر من نطاق
  // ونكتفي بنجاح واحد فقط لاعتبار الاتصال موجوداً.
  static const List<String> _probeHosts = [
    'google.com',
    'cloudflare.com',
    'one.one.one.one', // 1.1.1.1 عبر DNS، نادراً ما يُحجب
  ];

  /// يتحقق من الاتصال الفعلي بالإنترنت (وليس فقط الاتصال بالشبكة المحلية)
  /// يجرب عدة نطاقات بالتوازي ويرجع فوراً بمجرد نجاح أي واحد منها،
  /// دون انتظار اكتمال محاولات النطاقات الأخرى (لتقليل وقت الانتظار).
  static Future<bool> hasRealInternetAccess() async {
    final completer = Completer<bool>();
    var remaining = _probeHosts.length;

    for (final host in _probeHosts) {
      _probeHost(host).then((ok) {
        if (completer.isCompleted) return;
        if (ok) {
          completer.complete(true);
        } else {
          remaining--;
          if (remaining == 0) {
            completer.complete(false);
          }
        }
      });
    }

    return completer.future;
  }

  static Future<bool> _probeHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}