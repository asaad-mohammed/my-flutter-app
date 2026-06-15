import 'dart:async';
import 'dart:io';

class ConnectivityService {
  /// يتحقق من الاتصال الفعلي بالإنترنت (وليس فقط الاتصال بالشبكة)
  static Future<bool> hasRealInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}