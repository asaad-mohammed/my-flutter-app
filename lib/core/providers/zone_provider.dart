// lib/core/providers/zone_provider.dart
// ════════════════════════════════════════════════════════
//  نظام رصد الحالات المرضية والظواهر الصحية
// ════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// ─── أنواع الحالات المسجلة ─────────────────────────────
enum CaseType {
  drowning,      // غرق
  foodPoisoning, // تسمم غذائي
  flu,           // إنفلونزا
  heatStroke,    // ضربة شمس
  dengue,        // حمى الضنك
  accident,      // حادث
  other,         // أخرى
}

extension CaseTypeExtension on CaseType {
  String getLabel(bool isAr) {
    switch (this) {
      case CaseType.drowning:
        return isAr ? 'غرق' : 'Drowning';
      case CaseType.foodPoisoning:
        return isAr ? 'تسمم غذائي' : 'Food Poisoning';
      case CaseType.flu:
        return isAr ? 'إنفلونزا' : 'Flu';
      case CaseType.heatStroke:
        return isAr ? 'ضربة شمس' : 'Heat Stroke';
      case CaseType.dengue:
        return isAr ? 'حمى الضنك' : 'Dengue';
      case CaseType.accident:
        return isAr ? 'حادث' : 'Accident';
      case CaseType.other:
        return isAr ? 'أخرى' : 'Other';
    }
  }

  Color getColor() {
    switch (this) {
      case CaseType.drowning:
        return Colors.blue.shade800;
      case CaseType.foodPoisoning:
        return Colors.orange.shade700;
      case CaseType.flu:
        return Colors.purple.shade600;
      case CaseType.heatStroke:
        return Colors.red.shade700;
      case CaseType.dengue:
        return Colors.red.shade900;
      case CaseType.accident:
        return Colors.amber.shade800;
      case CaseType.other:
        return Colors.grey.shade600;
    }
  }

  IconData getIcon() {
    switch (this) {
      case CaseType.drowning:
        return Icons.water_drop_rounded;
      case CaseType.foodPoisoning:
        return Icons.restaurant_rounded;
      case CaseType.flu:
        return Icons.sick_rounded;
      case CaseType.heatStroke:
        return Icons.wb_sunny_rounded;
      case CaseType.dengue:
        return Icons.bug_report_rounded;
      case CaseType.accident:
        return Icons.car_crash_rounded;
      case CaseType.other:
        return Icons.help_outline_rounded;
    }
  }
}

// ─── مستوى الخطر ─────────────────────────────────────────
enum CaseRiskLevel {
  low,      // منخفض
  medium,   // متوسط
  high,     // مرتفع
  critical, // حرج
}

// ─── الحالة المرضية المبلّغ عنها ──────────────────────
class ReportedCase {
  final String id;
  final CaseType type;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final LatLng position;
  final String locationNameAr;
  final String locationNameEn;
  final DateTime reportedAt;
  final int affectedCount;      // عدد المصابين
  final CaseRiskLevel riskLevel;
  final bool isActive;          // هل الحالة لا تزال نشطة؟
  final String? imageUrl;
  final List<String> precautionsAr;
  final List<String> precautionsEn;

  ReportedCase({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.position,
    required this.locationNameAr,
    required this.locationNameEn,
    required this.reportedAt,
    required this.affectedCount,
    required this.riskLevel,
    required this.isActive,
    this.imageUrl,
    this.precautionsAr = const [],
    this.precautionsEn = const [],
  });

  // حساب شدة الخطر بناءً على عدد المصابين ونوع الحالة
  double get intensity {
    final base = affectedCount / 10;
    switch (riskLevel) {
      case CaseRiskLevel.low:
        return base * 0.5;
      case CaseRiskLevel.medium:
        return base * 1.0;
      case CaseRiskLevel.high:
        return base * 1.8;
      case CaseRiskLevel.critical:
        return base * 3.0;
    }
  }

  Color get color => type.getColor();
  IconData get icon => type.getIcon();

  String getRiskLabel(bool isAr) {
    switch (riskLevel) {
      case CaseRiskLevel.low:
        return isAr ? 'منخفض' : 'Low';
      case CaseRiskLevel.medium:
        return isAr ? 'متوسط' : 'Medium';
      case CaseRiskLevel.high:
        return isAr ? 'مرتفع' : 'High';
      case CaseRiskLevel.critical:
        return isAr ? 'حرج' : 'Critical';
    }
  }

  Color getRiskColor() {
    switch (riskLevel) {
      case CaseRiskLevel.low:
        return Colors.green;
      case CaseRiskLevel.medium:
        return Colors.orange;
      case CaseRiskLevel.high:
        return Colors.deepOrange;
      case CaseRiskLevel.critical:
        return Colors.red;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'titleAr': titleAr,
    'titleEn': titleEn,
    'descriptionAr': descriptionAr,
    'descriptionEn': descriptionEn,
    'latitude': position.latitude,
    'longitude': position.longitude,
    'locationNameAr': locationNameAr,
    'locationNameEn': locationNameEn,
    'reportedAt': reportedAt.toIso8601String(),
    'affectedCount': affectedCount,
    'riskLevel': riskLevel.index,
    'isActive': isActive,
    'precautionsAr': precautionsAr,
    'precautionsEn': precautionsEn,
  };

  factory ReportedCase.fromJson(Map<String, dynamic> json) {
    return ReportedCase(
      id: json['id'],
      type: CaseType.values[json['type']],
      titleAr: json['titleAr'],
      titleEn: json['titleEn'],
      descriptionAr: json['descriptionAr'],
      descriptionEn: json['descriptionEn'],
      position: LatLng(json['latitude'], json['longitude']),
      locationNameAr: json['locationNameAr'],
      locationNameEn: json['locationNameEn'],
      reportedAt: DateTime.parse(json['reportedAt']),
      affectedCount: json['affectedCount'],
      riskLevel: CaseRiskLevel.values[json['riskLevel']],
      isActive: json['isActive'],
      precautionsAr: List<String>.from(json['precautionsAr']),
      precautionsEn: List<String>.from(json['precautionsEn']),
    );
  }
}

// ─── المنطقة الصحية مع الحالات المبلّغة ──────────────
class HealthZoneWithCases {
  final String id;
  final String nameAr;
  final String nameEn;
  final String districtAr;
  final String districtEn;
  final LatLng center;
  final double radiusKm;
  final List<ReportedCase> activeCases;
  final DateTime lastUpdated;

  HealthZoneWithCases({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.districtAr,
    required this.districtEn,
    required this.center,
    required this.radiusKm,
    required this.activeCases,
    required this.lastUpdated,
  });

  int get totalActiveCases => activeCases.length;
  int get totalAffected => activeCases.fold(0, (sum, c) => sum + c.affectedCount);

  // الحالات الأكثر خطورة
  List<ReportedCase> get criticalCases =>
      activeCases.where((c) => c.riskLevel == CaseRiskLevel.critical).toList();

  // مؤشر الخطر الإجمالي للمنطقة
  double get overallRiskScore {
    if (activeCases.isEmpty) return 0;
    final scores = activeCases.map((c) {
      final riskMultiplier = switch (c.riskLevel) {
        CaseRiskLevel.low => 1,
        CaseRiskLevel.medium => 2,
        CaseRiskLevel.high => 3,
        CaseRiskLevel.critical => 5,
      };
      return c.affectedCount * riskMultiplier;
    });
    return scores.reduce((a, b) => a + b) / 100;
  }

  // مستوى الخطر الكلي
  CaseRiskLevel get overallRisk {
    final score = overallRiskScore;
    if (score < 1) return CaseRiskLevel.low;
    if (score < 3) return CaseRiskLevel.medium;
    if (score < 6) return CaseRiskLevel.high;
    return CaseRiskLevel.critical;
  }

  Color getRiskColor() {
    switch (overallRisk) {
      case CaseRiskLevel.low:
        return Colors.green;
      case CaseRiskLevel.medium:
        return Colors.orange;
      case CaseRiskLevel.high:
        return Colors.deepOrange;
      case CaseRiskLevel.critical:
        return Colors.red;
    }
  }

  String getRiskLabel(bool isAr) {
    switch (overallRisk) {
      case CaseRiskLevel.low:
        return isAr ? 'آمن' : 'Safe';
      case CaseRiskLevel.medium:
        return isAr ? 'مراقبة' : 'Watch';
      case CaseRiskLevel.high:
        return isAr ? 'تحذير' : 'Warning';
      case CaseRiskLevel.critical:
        return isAr ? 'خطر' : 'Danger';
    }
  }
}

// ─── البيانات التجريبية ──────────────────────────────────

// استخدام دالة Distance لحساب المسافات
final Distance _distance = const Distance();

// مواقع افتراضية في البصرة
const _basraLocations = {
  'سوق القيصرية': LatLng(30.5200, 47.7850),
  'شط العرب': LatLng(30.5100, 47.7900),
  'حي الزيتون': LatLng(30.4980, 47.7750),
  'ميناء المعقل': LatLng(30.5300, 47.7800),
  'الجامعة': LatLng(30.5150, 47.7700),
};

// حالات تجريبية
final List<ReportedCase> _mockCases = [
  ReportedCase(
    id: 'case_1',
    type: CaseType.drowning,
    titleAr: 'حالة غرق في شط العرب',
    titleEn: 'Drowning incident in Shatt Al-Arab',
    descriptionAr: 'تم الإبلاغ عن حالة غرق لطفل بالقرب من ضفاف شط العرب. يرجى الحذر عند الاقتراب من المياه.',
    descriptionEn: 'A child drowning incident reported near Shatt Al-Arab banks. Please exercise caution near water.',
    position: _basraLocations['شط العرب']!,
    locationNameAr: 'شط العرب - البصرة',
    locationNameEn: 'Shatt Al-Arab - Basra',
    reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
    affectedCount: 1,
    riskLevel: CaseRiskLevel.critical,
    isActive: true,
    precautionsAr: ['تجنب السباحة في المناطق غير المخصصة', 'إبقاء الأطفال بعيداً عن المياه'],
    precautionsEn: ['Avoid swimming in unauthorized areas', 'Keep children away from water'],
  ),
  ReportedCase(
    id: 'case_2',
    type: CaseType.foodPoisoning,
    titleAr: 'تسمم غذائي في مطعم السياح',
    titleEn: 'Food poisoning at Al-Siyah Restaurant',
    descriptionAr: 'تم تسجيل 8 حالات تسمم غذائي بعد تناول وجبات من مطعم السياح في سوق القيصرية.',
    descriptionEn: '8 food poisoning cases recorded after meals at Al-Siyah Restaurant in Al-Qaisariya Market.',
    position: _basraLocations['سوق القيصرية']!,
    locationNameAr: 'سوق القيصرية - البصرة',
    locationNameEn: 'Al-Qaisariya Market - Basra',
    reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
    affectedCount: 8,
    riskLevel: CaseRiskLevel.high,
    isActive: true,
    precautionsAr: ['تجنب تناول الطعام من المطعم', 'شرب المياه المعبأة', 'مراجعة الطبيب في حال ظهور أعراض'],
    precautionsEn: ['Avoid eating from the restaurant', 'Drink bottled water', 'See a doctor if symptoms appear'],
  ),
  ReportedCase(
    id: 'case_3',
    type: CaseType.heatStroke,
    titleAr: 'ضربة شمس في ميناء المعقل',
    titleEn: 'Heat stroke at Al-Maqal Port',
    descriptionAr: 'تم نقل 5 عمال إلى المستشفى إثر تعرضهم لضربة شمس أثناء العمل في ميناء المعقل تحت حرارة 48°م.',
    descriptionEn: '5 workers hospitalized due to heat stroke while working at Al-Maqal Port under 48°C heat.',
    position: _basraLocations['ميناء المعقل']!,
    locationNameAr: 'ميناء المعقل - البصرة',
    locationNameEn: 'Al-Maqal Port - Basra',
    reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    affectedCount: 5,
    riskLevel: CaseRiskLevel.high,
    isActive: true,
    precautionsAr: ['تجنب العمل تحت الشمس المباشرة 12-4م', 'شرب الماء بكثرة', 'ارتداء ملابس فاتحة'],
    precautionsEn: ['Avoid direct sun work 12-4pm', 'Drink plenty of water', 'Wear light clothing'],
  ),
  ReportedCase(
    id: 'case_4',
    type: CaseType.dengue,
    titleAr: 'حالة حمى ضنك مشتبهة في حي الزيتون',
    titleEn: 'Suspected dengue case in Al-Zaytoon district',
    descriptionAr: 'تم الإبلاغ عن حالة مشتبهة بحمى الضنك في حي الزيتون. تم أخذ العينات للفحص المخبري.',
    descriptionEn: 'Suspected dengue case reported in Al-Zaytoon district. Samples sent for lab testing.',
    position: _basraLocations['حي الزيتون']!,
    locationNameAr: 'حي الزيتون - البصرة',
    locationNameEn: 'Al-Zaytoon district - Basra',
    reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
    affectedCount: 1,
    riskLevel: CaseRiskLevel.critical,
    isActive: true,
    precautionsAr: ['مكافحة البعوض', 'إزالة المياه الراكدة', 'استخدام الناموسيات'],
    precautionsEn: ['Mosquito control', 'Remove stagnant water', 'Use bed nets'],
  ),
  ReportedCase(
    id: 'case_5',
    type: CaseType.accident,
    titleAr: 'حادث سير في الجامعة',
    titleEn: 'Car accident near University',
    descriptionAr: 'حادث تصادم بين سيارتين بالقرب من بوابة جامعة البصرة، تم نقل 3 مصابين للمستشفى.',
    descriptionEn: 'Two-car collision near Basra University gate, 3 injured transferred to hospital.',
    position: _basraLocations['الجامعة']!,
    locationNameAr: 'جامعة البصرة',
    locationNameEn: 'Basra University',
    reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
    affectedCount: 3,
    riskLevel: CaseRiskLevel.medium,
    isActive: true,
    precautionsAr: ['القيادة بحذر في المنطقة', 'الالتزام بالسرعة المحددة'],
    precautionsEn: ['Drive cautiously in the area', 'Observe speed limits'],
  ),
];

// مناطق البصرة مع الحالات
final List<HealthZoneWithCases> _mockZonesWithCases = [
  HealthZoneWithCases(
    id: 'basra_center',
    nameAr: 'مركز البصرة',
    nameEn: 'Basra Center',
    districtAr: 'البصرة',
    districtEn: 'Basra',
    center: LatLng(30.5085, 47.7804),
    radiusKm: 5.0,
    activeCases: _mockCases.where((c) => c.isActive).toList(),
    lastUpdated: DateTime.now(),
  ),
  // يمكن إضافة مناطق أخرى مع حالات مختلفة
];

// ─── ZoneState ────────────────────────────────────────────
class ZoneState {
  final List<HealthZoneWithCases> zones;
  final List<ReportedCase> allCases;
  final String? selectedZoneId;
  final bool isLoading;
  final bool isReporting;

  const ZoneState({
    this.zones = const [],
    this.allCases = const [],
    this.selectedZoneId,
    this.isLoading = false,
    this.isReporting = false,
  });

  HealthZoneWithCases? get selectedZone {
    if (selectedZoneId == null) return zones.isNotEmpty ? zones.first : null;
    try {
      return zones.firstWhere((z) => z.id == selectedZoneId);
    } catch (_) {
      return zones.isNotEmpty ? zones.first : null;
    }
  }

  List<ReportedCase> get activeCases => allCases.where((c) => c.isActive).toList();

  ZoneState copyWith({
    List<HealthZoneWithCases>? zones,
    List<ReportedCase>? allCases,
    String? selectedZoneId,
    bool? isLoading,
    bool? isReporting,
  }) =>
      ZoneState(
        zones: zones ?? this.zones,
        allCases: allCases ?? this.allCases,
        selectedZoneId: selectedZoneId ?? this.selectedZoneId,
        isLoading: isLoading ?? this.isLoading,
        isReporting: isReporting ?? this.isReporting,
      );
}

// ─── ZoneNotifier ─────────────────────────────────────────
class ZoneNotifier extends Notifier<ZoneState> {
  @override
  ZoneState build() => ZoneState(
        zones: _mockZonesWithCases,
        allCases: _mockCases,
        selectedZoneId: _mockZonesWithCases.first.id,
      );

  void selectZone(String id) => state = state.copyWith(selectedZoneId: id);

  Future<void> refreshZones() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }

  // ── الإبلاغ عن حالة جديدة ──────────────────────────────
  Future<ReportedCase> reportCase({
    required CaseType type,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required LatLng position,
    required String locationNameAr,
    required String locationNameEn,
    required int affectedCount,
    required CaseRiskLevel riskLevel,
    List<String> precautionsAr = const [],
    List<String> precautionsEn = const [],
  }) async {
    state = state.copyWith(isReporting: true);
    await Future.delayed(const Duration(seconds: 1)); // محاكاة إرسال للخادم

    final newCase = ReportedCase(
      id: 'case_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      position: position,
      locationNameAr: locationNameAr,
      locationNameEn: locationNameEn,
      reportedAt: DateTime.now(),
      affectedCount: affectedCount,
      riskLevel: riskLevel,
      isActive: true,
      precautionsAr: precautionsAr,
      precautionsEn: precautionsEn,
    );

    // إضافة الحالة إلى القائمة
    final updatedCases = [...state.allCases, newCase];

    // تحديث المناطق - استخدام _distance للمسافات
    final updatedZones = state.zones.map((zone) {
      // حساب المسافة بين مركز المنطقة وموقع الحالة
      final distanceInMeters = _distance.as(
        LengthUnit.Meter,
        zone.center,
        position,
      );
      final distanceInKm = distanceInMeters / 1000;
      
      // إذا كانت الحالة ضمن نطاق المنطقة
      if (distanceInKm <= zone.radiusKm) {
        return HealthZoneWithCases(
          id: zone.id,
          nameAr: zone.nameAr,
          nameEn: zone.nameEn,
          districtAr: zone.districtAr,
          districtEn: zone.districtEn,
          center: zone.center,
          radiusKm: zone.radiusKm,
          activeCases: [...zone.activeCases, newCase],
          lastUpdated: DateTime.now(),
        );
      }
      return zone;
    }).toList();

    state = state.copyWith(
      allCases: updatedCases,
      zones: updatedZones,
      isReporting: false,
    );

    return newCase;
  }

  // ── حل حالة (إغلاقها) ──────────────────────────────────
  void resolveCase(String caseId) {
    final updatedCases = state.allCases.map((c) {
      if (c.id == caseId) {
        return ReportedCase(
          id: c.id,
          type: c.type,
          titleAr: c.titleAr,
          titleEn: c.titleEn,
          descriptionAr: c.descriptionAr,
          descriptionEn: c.descriptionEn,
          position: c.position,
          locationNameAr: c.locationNameAr,
          locationNameEn: c.locationNameEn,
          reportedAt: c.reportedAt,
          affectedCount: c.affectedCount,
          riskLevel: c.riskLevel,
          isActive: false,
          precautionsAr: c.precautionsAr,
          precautionsEn: c.precautionsEn,
        );
      }
      return c;
    }).toList();

    // تحديث المناطق (إزالة الحالة المغلقة)
    final updatedZones = state.zones.map((zone) {
      final activeInZone = updatedCases.where((c) {
        if (!c.isActive) return false;
        final distanceInMeters = _distance.as(
          LengthUnit.Meter,
          zone.center,
          c.position,
        );
        final distanceInKm = distanceInMeters / 1000;
        return distanceInKm <= zone.radiusKm;
      }).toList();
      
      return HealthZoneWithCases(
        id: zone.id,
        nameAr: zone.nameAr,
        nameEn: zone.nameEn,
        districtAr: zone.districtAr,
        districtEn: zone.districtEn,
        center: zone.center,
        radiusKm: zone.radiusKm,
        activeCases: activeInZone,
        lastUpdated: DateTime.now(),
      );
    }).toList();

    state = state.copyWith(
      allCases: updatedCases,
      zones: updatedZones,
    );
  }
}

final zoneProvider = NotifierProvider<ZoneNotifier, ZoneState>(ZoneNotifier.new);