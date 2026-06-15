// ════════════════════════════════════════════════════════
//  core/models/zone_model.dart
//  نموذج بيانات تحليل البيئة الصحية للمناطق
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────
//  HealthRiskLevel - مستوى الخطورة الصحية
// ────────────────────────────────────────────────────────
enum HealthRiskLevel {
  low,      // منخفض
  moderate, // متوسط
  high,     // مرتفع
  critical, // حرج / وباء
}

extension HealthRiskLevelExtension on HealthRiskLevel {
  String getLabel(bool isAr) {
    switch (this) {
      case HealthRiskLevel.low:
        return isAr ? 'منخفض' : 'Low';
      case HealthRiskLevel.moderate:
        return isAr ? 'متوسط' : 'Moderate';
      case HealthRiskLevel.high:
        return isAr ? 'مرتفع' : 'High';
      case HealthRiskLevel.critical:
        return isAr ? 'حرج / وباء' : 'Critical / Epidemic';
    }
  }

  Color getColor() {
    switch (this) {
      case HealthRiskLevel.low:
        return Colors.green;
      case HealthRiskLevel.moderate:
        return Colors.orange;
      case HealthRiskLevel.high:
        return Colors.deepOrange;
      case HealthRiskLevel.critical:
        return Colors.red;
    }
  }
}

// ────────────────────────────────────────────────────────
//  DiseaseTrend - اتجاه المرض (زيادة/انخفاض)
// ────────────────────────────────────────────────────────
enum DiseaseTrend {
  increasing,  // في ازدياد
  decreasing,  // في تناقص
  stable,      // مستقر
  outbreak,    // تفشي مفاجئ
}

extension DiseaseTrendExtension on DiseaseTrend {
  String getLabel(bool isAr) {
    switch (this) {
      case DiseaseTrend.increasing:
        return isAr ? 'في ازدياد ⬆️' : 'Increasing ⬆️';
      case DiseaseTrend.decreasing:
        return isAr ? 'في تناقص ⬇️' : 'Decreasing ⬇️';
      case DiseaseTrend.stable:
        return isAr ? 'مستقر ➡️' : 'Stable ➡️';
      case DiseaseTrend.outbreak:
        return isAr ? 'تفشي مفاجئ ⚠️' : 'Outbreak ⚠️';
    }
  }

  Color getColor() {
    switch (this) {
      case DiseaseTrend.increasing:
        return Colors.orange;
      case DiseaseTrend.decreasing:
        return Colors.green;
      case DiseaseTrend.stable:
        return Colors.blue;
      case DiseaseTrend.outbreak:
        return Colors.red;
    }
  }
}

// ────────────────────────────────────────────────────────
//  ZoneHealthData - بيانات منطقة جغرافية صحية
// ────────────────────────────────────────────────────────
class ZoneHealthData {
  final String zoneId;
  final String nameAr;
  final String nameEn;
  final double latitude;
  final double longitude;

  // مؤشرات صحية أساسية
  final int totalPopulation;        // عدد السكان
  final int activeCases;            // الحالات النشطة
  final int newCasesThisWeek;       // إصابات هذا الأسبوع
  final int recovered;              // المتعافون
  final int deaths;                 // الوفيات
  final int hospitalCapacity;       // سعة المستشفيات
  final int occupiedBeds;           // أسرة مشغولة

  // مؤشرات إضافية
  final double vaccinationRate;     // نسبة التطعيم (0-100)
  final double riskScore;           // درجة الخطورة (0-100)
  final HealthRiskLevel riskLevel;  // مستوى الخطورة
  final DiseaseTrend trend;         // اتجاه المرض

  // مؤشرات بيئية
  final double airQualityIndex;     // مؤشر جودة الهواء (0-500)
  final int humidity;               // الرطوبة (%)
  final double temperature;         // درجة الحرارة (مئوية)

  // توقعات الأسبوع القادم
  final int? predictedNewCases;
  final DateTime lastUpdated;

  ZoneHealthData({
    required this.zoneId,
    required this.nameAr,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
    required this.totalPopulation,
    required this.activeCases,
    required this.newCasesThisWeek,
    required this.recovered,
    required this.deaths,
    required this.hospitalCapacity,
    required this.occupiedBeds,
    required this.vaccinationRate,
    required this.riskScore,
    required this.riskLevel,
    required this.trend,
    required this.airQualityIndex,
    required this.humidity,
    required this.temperature,
    this.predictedNewCases,
    required this.lastUpdated,
  });

  // ── مؤشرات محسوبة ─────────────────────────────────────
  
  // نسبة إشغال المستشفيات
  double get occupancyRate => 
      hospitalCapacity > 0 ? (occupiedBeds / hospitalCapacity) * 100 : 0;

  // معدل الوفيات
  double get mortalityRate => 
      totalPopulation > 0 ? (deaths / totalPopulation) * 10000 : 0;

  // معدل الشفاء
  double get recoveryRate => 
      activeCases + recovered > 0 ? (recovered / (activeCases + recovered)) * 100 : 0;

  // نسبة التغير في الإصابات مقارنة بالأسبوع الماضي
  int get weeklyChange => newCasesThisWeek - (newCasesThisWeek ~/ 1.2); // محاكاة

  // حالة المستشفى
  String get hospitalStatusLabel {
    if (occupancyRate < 60) return 'آمن';
    if (occupancyRate < 85) return 'ضغط متوسط';
    if (occupancyRate < 95) return 'ضغط عالي';
    return 'حرج - طاقة استيعابية منخفضة';
  }

  Color get hospitalStatusColor {
    if (occupancyRate < 60) return Colors.green;
    if (occupancyRate < 85) return Colors.orange;
    if (occupancyRate < 95) return Colors.deepOrange;
    return Colors.red;
  }

  // ── دوال مساعدة ──────────────────────────────────────
  
  Map<String, dynamic> toJson() => {
    'zoneId': zoneId,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'latitude': latitude,
    'longitude': longitude,
    'totalPopulation': totalPopulation,
    'activeCases': activeCases,
    'newCasesThisWeek': newCasesThisWeek,
    'recovered': recovered,
    'deaths': deaths,
    'hospitalCapacity': hospitalCapacity,
    'occupiedBeds': occupiedBeds,
    'vaccinationRate': vaccinationRate,
    'riskScore': riskScore,
    'riskLevel': riskLevel.index,
    'trend': trend.index,
    'airQualityIndex': airQualityIndex,
    'humidity': humidity,
    'temperature': temperature,
    'predictedNewCases': predictedNewCases,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory ZoneHealthData.fromJson(Map<String, dynamic> json) {
    return ZoneHealthData(
      zoneId: json['zoneId'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      totalPopulation: json['totalPopulation'],
      activeCases: json['activeCases'],
      newCasesThisWeek: json['newCasesThisWeek'],
      recovered: json['recovered'],
      deaths: json['deaths'],
      hospitalCapacity: json['hospitalCapacity'],
      occupiedBeds: json['occupiedBeds'],
      vaccinationRate: json['vaccinationRate'].toDouble(),
      riskScore: json['riskScore'].toDouble(),
      riskLevel: HealthRiskLevel.values[json['riskLevel']],
      trend: DiseaseTrend.values[json['trend']],
      airQualityIndex: json['airQualityIndex'].toDouble(),
      humidity: json['humidity'],
      temperature: json['temperature'].toDouble(),
      predictedNewCases: json['predictedNewCases'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  // نسخة معدلة
  ZoneHealthData copyWith({
    int? activeCases,
    int? newCasesThisWeek,
    int? recovered,
    int? deaths,
    int? occupiedBeds,
    double? vaccinationRate,
    double? riskScore,
    HealthRiskLevel? riskLevel,
    DiseaseTrend? trend,
    double? airQualityIndex,
    int? humidity,
    double? temperature,
    int? predictedNewCases,
  }) {
    return ZoneHealthData(
      zoneId: zoneId,
      nameAr: nameAr,
      nameEn: nameEn,
      latitude: latitude,
      longitude: longitude,
      totalPopulation: totalPopulation,
      activeCases: activeCases ?? this.activeCases,
      newCasesThisWeek: newCasesThisWeek ?? this.newCasesThisWeek,
      recovered: recovered ?? this.recovered,
      deaths: deaths ?? this.deaths,
      hospitalCapacity: hospitalCapacity,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      vaccinationRate: vaccinationRate ?? this.vaccinationRate,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      trend: trend ?? this.trend,
      airQualityIndex: airQualityIndex ?? this.airQualityIndex,
      humidity: humidity ?? this.humidity,
      temperature: temperature ?? this.temperature,
      predictedNewCases: predictedNewCases ?? this.predictedNewCases,
      lastUpdated: DateTime.now(),
    );
  }
}

// ────────────────────────────────────────────────────────
//  ZoneRiskReport - تقرير شامل لمنطقة
// ────────────────────────────────────────────────────────
class ZoneRiskReport {
  final ZoneHealthData zone;
  final DateTime generatedAt;
  final String summaryAr;
  final String summaryEn;
  final List<String> recommendationsAr;
  final List<String> recommendationsEn;
  final bool requiresAlert;

  ZoneRiskReport({
    required this.zone,
    required this.generatedAt,
    required this.summaryAr,
    required this.summaryEn,
    required this.recommendationsAr,
    required this.recommendationsEn,
    this.requiresAlert = false,
  });

  String getSummary(bool isAr) => isAr ? summaryAr : summaryEn;

  List<String> getRecommendations(bool isAr) => 
      isAr ? recommendationsAr : recommendationsEn;

  factory ZoneRiskReport.fromZone(ZoneHealthData zone, bool isAr) {
    final riskLevel = zone.riskLevel;
    final isHighRisk = riskLevel == HealthRiskLevel.high || 
                       riskLevel == HealthRiskLevel.critical;
    
    final summaryAr = isHighRisk
        ? '⚠️ منطقة ${zone.nameAr} تشهد وضعاً صحياً ${riskLevel.getLabel(true)}. '
          'يوجد ${zone.activeCases} حالة نشطة مع زيادة ${zone.weeklyChange > 0 ? '+' : ''}${zone.weeklyChange} حالة هذا الأسبوع. '
          'نسبة إشغال المستشفيات ${zone.occupancyRate.toStringAsFixed(0)}%.'
        : '✅ منطقة ${zone.nameAr} مستقرة نسبياً. '
          'نسبة التطعيم ${zone.vaccinationRate.toStringAsFixed(0)}%، '
          'ومعدل الإشغال ${zone.occupancyRate.toStringAsFixed(0)}%.';

    final recommendationsAr = <String>[];
    if (zone.occupancyRate > 80) {
      recommendationsAr.add('زيادة الطاقة الاستيعابية للمستشفيات');
    }
    if (zone.vaccinationRate < 70) {
      recommendationsAr.add('تكثيف حملات التطعيم في المنطقة');
    }
    if (zone.trend == DiseaseTrend.increasing) {
      recommendationsAr.add('مراقبة الحالات الجديدة عن كثب');
    }
    if (zone.riskLevel == HealthRiskLevel.critical) {
      recommendationsAr.add('⚠️ إجراءات عاجلة: حظر تجمعات، تعقيم، فحوصات مكثفة');
    }
    if (recommendationsAr.isEmpty) {
      recommendationsAr.add('المتابعة الروتينية للوضع الصحي');
    }

    return ZoneRiskReport(
      zone: zone,
      generatedAt: DateTime.now(),
      summaryAr: summaryAr,
      summaryEn: '', 
      recommendationsAr: recommendationsAr,
      recommendationsEn: [],
      requiresAlert: isHighRisk,
    );
  }
}