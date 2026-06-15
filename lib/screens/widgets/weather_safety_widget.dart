// ════════════════════════════════════════════════════════
//  widgets/weather_safety_widget.dart
//  ✅ ميزة جديدة: تنبيهات الطقس المتعلقة بالسلامة
//  يُعرض في تبويب الطوارئ أو الرئيسي
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum WeatherAlert { clear, dust, rain, extreme, flood }

class WeatherSafetyCard extends StatefulWidget {
  final bool isAr;

  const WeatherSafetyCard({super.key, required this.isAr});

  @override
  State<WeatherSafetyCard> createState() => _WeatherSafetyCardState();
}

class _WeatherSafetyCardState extends State<WeatherSafetyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  // بيانات تجريبية — ستُستبدل بـ API حقيقي
  final WeatherAlert _currentAlert = WeatherAlert.dust;
  final double _temperature = 38.0;
  final String _location = 'البصرة';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse =
        Tween<double>(begin: 0.97, end: 1.03).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _alertData() {
    final isAr = widget.isAr;
    switch (_currentAlert) {
      case WeatherAlert.clear:
        return {
          'icon': '☀️',
          'title': isAr ? 'الطقس جيد' : 'Clear Weather',
          'desc': isAr ? 'لا توجد تحذيرات طقسية' : 'No weather alerts',
          'gradient': [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
          'urgent': false,
        };
      case WeatherAlert.dust:
        return {
          'icon': '🌪️',
          'title': isAr ? 'تحذير: عاصفة ترابية' : 'Warning: Dust Storm',
          'desc': isAr
              ? 'ابقَ في المنزل وأغلق النوافذ — رؤية محدودة'
              : 'Stay indoors, close windows — limited visibility',
          'gradient': [const Color(0xFFF57C00), const Color(0xFFFFB74D)],
          'urgent': true,
        };
      case WeatherAlert.rain:
        return {
          'icon': '🌧️',
          'title': isAr ? 'تحذير: أمطار غزيرة' : 'Warning: Heavy Rain',
          'desc': isAr
              ? 'تجنب الأودية والمناطق المنخفضة'
              : 'Avoid valleys and low-lying areas',
          'gradient': [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
          'urgent': false,
        };
      case WeatherAlert.flood:
        return {
          'icon': '🌊',
          'title': isAr ? 'خطر: فيضانات' : 'Danger: Flooding',
          'desc': isAr
              ? 'انتقل إلى مناطق مرتفعة فوراً'
              : 'Move to higher ground immediately',
          'gradient': [const Color(0xFFB71C1C), const Color(0xFFEF5350)],
          'urgent': true,
        };
      case WeatherAlert.extreme:
        return {
          'icon': '🌡️',
          'title': isAr ? 'حرارة شديدة' : 'Extreme Heat',
          'desc': isAr
              ? 'تجنب الخروج بين 12-4 عصراً — اشرب الماء'
              : 'Avoid outdoors 12-4pm — stay hydrated',
          'gradient': [const Color(0xFFE65100), const Color(0xFFFF7043)],
          'urgent': false,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _alertData();
    final isUrgent = data['urgent'] as bool;
    final gradient = data['gradient'] as List<Color>;

    return ScaleTransition(
      scale: isUrgent ? _pulse : const AlwaysStoppedAnimation(1.0),
      child: Container(
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            // أيقونة الطقس
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(data['icon'] as String,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data['desc'] as String,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4),
                  ),
                ],
              ),
            ),
            // درجة الحرارة
            Column(
              children: [
                Text(
                  '${_temperature.toInt()}°',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  _location,
                  style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ]),

          // شريط تنبيه عاجل
          if (isUrgent) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    widget.isAr
                        ? 'تنبيه عاجل — اتبع إرشادات الدفاع المدني'
                        : 'Urgent Alert — Follow civil defense guidelines',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}