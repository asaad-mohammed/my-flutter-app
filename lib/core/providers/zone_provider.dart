// lib/core/providers/zone_provider.dart
// ════════════════════════════════════════════════════════
//  core/providers/zone_provider.dart
//  مزوّد بيانات تحليل البيئة الصحية
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// تعريفات إضافية للنماذج المستخدمة
enum DiseaseRisk { low, medium, high, critical }
enum TrendDir { rising, falling, stable }
enum ZoneStatus { safe, watch, warning, danger }

class TrackedDisease {
  final String id;
  final String nameAr;
  final String nameEn;
  final String emoji;
  final int casesCount;
  final int casesChange;
  final DiseaseRisk risk;
  final TrendDir trend;
  final Color color;
  final List<String> symptomsAr;
  final List<String> symptomsEn;
  final List<String> preventionAr;
  final List<String> preventionEn;

  const TrackedDisease({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.emoji,
    required this.casesCount,
    required this.casesChange,
    required this.risk,
    required this.trend,
    required this.color,
    required this.symptomsAr,
    required this.symptomsEn,
    required this.preventionAr,
    required this.preventionEn,
  });
}

class HealthZone {
  final String id;
  final String nameAr;
  final String nameEn;
  final String districtAr;
  final String districtEn;
  final double lat;
  final double lng;
  final double radiusKm;
  final ZoneStatus status;
  final int totalCases;
  final int activeCases;
  final int population;
  final double temperatureC;
  final double humidityPct;
  final double airQualityIndex;
  final List<TrackedDisease> diseases;
  final List<String> alertsAr;
  final List<String> alertsEn;
  final DateTime lastUpdated;
  final DiseaseRisk forecastRisk;
  final String forecastNoteAr;
  final String forecastNoteEn;

  const HealthZone({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.districtAr,
    required this.districtEn,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.status,
    required this.totalCases,
    required this.activeCases,
    required this.population,
    required this.temperatureC,
    required this.humidityPct,
    required this.airQualityIndex,
    required this.diseases,
    required this.alertsAr,
    required this.alertsEn,
    required this.lastUpdated,
    required this.forecastRisk,
    required this.forecastNoteAr,
    required this.forecastNoteEn,
  });

  double get activePercentage => population > 0 ? (activeCases / population) * 10000 : 0;

  String getStatusLabel(bool isAr) {
    switch (status) {
      case ZoneStatus.safe:
        return isAr ? 'آمن' : 'Safe';
      case ZoneStatus.watch:
        return isAr ? 'مراقبة' : 'Watch';
      case ZoneStatus.warning:
        return isAr ? 'تحذير' : 'Warning';
      case ZoneStatus.danger:
        return isAr ? 'خطر' : 'Danger';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case ZoneStatus.safe:
        return Colors.green;
      case ZoneStatus.watch:
        return Colors.orange;
      case ZoneStatus.warning:
        return Colors.deepOrange;
      case ZoneStatus.danger:
        return Colors.red;
    }
  }
}

class ZoneHealthReport {
  final String zoneId;
  final DateTime generatedAt;
  final int weeklyNewCases;
  final int weeklyRecovered;
  final double reproductionNumber;
  final String aiAnalysisAr;
  final String aiAnalysisEn;
  final List<String> recommendationsAr;
  final List<String> recommendationsEn;

  ZoneHealthReport({
    required this.zoneId,
    required this.generatedAt,
    required this.weeklyNewCases,
    required this.weeklyRecovered,
    required this.reproductionNumber,
    required this.aiAnalysisAr,
    required this.aiAnalysisEn,
    required this.recommendationsAr,
    required this.recommendationsEn,
  });
}

// بيانات الأمراض التجريبية
const _flu = TrackedDisease(
  id: 'flu',
  nameAr: 'الإنفلونزا الموسمية',
  nameEn: 'Seasonal Flu',
  emoji: '🤧',
  casesCount: 847,
  casesChange: 23,
  risk: DiseaseRisk.medium,
  trend: TrendDir.rising,
  color: Color(0xFFF57C00),
  symptomsAr: ['حمى مفاجئة', 'صداع شديد', 'آلام في الجسم', 'سعال جاف', 'إرهاق'],
  symptomsEn: ['Sudden fever', 'Severe headache', 'Body aches', 'Dry cough', 'Fatigue'],
  preventionAr: ['غسل اليدين باستمرار', 'تجنب الأماكن المكتظة', 'التطعيم السنوي', 'استخدام الكمامة'],
  preventionEn: ['Wash hands frequently', 'Avoid crowded places', 'Annual vaccination', 'Wear mask'],
);

const _gastro = TrackedDisease(
  id: 'gastro',
  nameAr: 'التهاب المعدة والأمعاء',
  nameEn: 'Gastroenteritis',
  emoji: '🦠',
  casesCount: 312,
  casesChange: -18,
  risk: DiseaseRisk.high,
  trend: TrendDir.falling,
  color: Color(0xFFB71C1C),
  symptomsAr: ['إسهال مائي', 'قيء', 'مغص بطني', 'حمى خفيفة', 'جفاف'],
  symptomsEn: ['Watery diarrhea', 'Vomiting', 'Abdominal cramps', 'Low fever', 'Dehydration'],
  preventionAr: ['شرب ماء معقم', 'غسل الخضروات جيداً', 'طبخ اللحوم جيداً', 'تجنب الطعام الشارعي'],
  preventionEn: ['Drink purified water', 'Wash vegetables thoroughly', 'Cook meat well', 'Avoid street food'],
);

const _dengue = TrackedDisease(
  id: 'dengue',
  nameAr: 'حمى الضنك',
  nameEn: 'Dengue Fever',
  emoji: '🦟',
  casesCount: 45,
  casesChange: 8,
  risk: DiseaseRisk.critical,
  trend: TrendDir.rising,
  color: Color(0xFFC62828),
  symptomsAr: ['حمى شديدة مفاجئة', 'صداع خلف العينين', 'طفح جلدي', 'ألم المفاصل الشديد'],
  symptomsEn: ['Sudden high fever', 'Pain behind eyes', 'Skin rash', 'Severe joint pain'],
  preventionAr: ['مكافحة البعوض', 'استخدام ناموسيات', 'إزالة مياه راكدة', 'طارد الحشرات'],
  preventionEn: ['Mosquito control', 'Use bed nets', 'Remove standing water', 'Use insect repellent'],
);

const _conjunctivitis = TrackedDisease(
  id: 'conj',
  nameAr: 'التهاب الملتحمة (العيون الحمراء)',
  nameEn: 'Conjunctivitis',
  emoji: '👁️',
  casesCount: 203,
  casesChange: 41,
  risk: DiseaseRisk.medium,
  trend: TrendDir.rising,
  color: Color(0xFFE53935),
  symptomsAr: ['احمرار العين', 'إفرازات صفراء', 'حكة وحرقان', 'تورم الجفن'],
  symptomsEn: ['Eye redness', 'Yellow discharge', 'Itching and burning', 'Eyelid swelling'],
  preventionAr: ['عدم لمس العيون', 'غسل اليدين', 'عدم مشاركة المناشف', 'تجنب المصابين'],
  preventionEn: ['Avoid touching eyes', 'Wash hands', 'No sharing towels', 'Avoid infected persons'],
);

const _heatExhaustion = TrackedDisease(
  id: 'heat',
  nameAr: 'الإجهاد الحراري / ضربة الشمس',
  nameEn: 'Heat Exhaustion',
  emoji: '🌡️',
  casesCount: 128,
  casesChange: 55,
  risk: DiseaseRisk.high,
  trend: TrendDir.rising,
  color: Color(0xFFF9A825),
  symptomsAr: ['دوار وإغماء', 'تعرق مفرط', 'غثيان', 'جلد أحمر وجاف', 'ارتفاع حرارة الجسم'],
  symptomsEn: ['Dizziness/fainting', 'Excessive sweating', 'Nausea', 'Red dry skin', 'High body temperature'],
  preventionAr: ['تجنب الخروج 12-4 مساءً', 'شرب ماء كافٍ', 'ملابس خفيفة فاتحة', 'البقاء في مكان بارد'],
  preventionEn: ['Avoid outdoors 12-4pm', 'Stay well hydrated', 'Wear light clothing', 'Stay in cool places'],
);

// مناطق البصرة الصحية
final List<HealthZone> _mockZones = [
  HealthZone(
    id: 'basra_center',
    nameAr: 'مركز البصرة',
    nameEn: 'Basra Center',
    districtAr: 'البصرة',
    districtEn: 'Basra',
    lat: 30.5085,
    lng: 47.7804,
    radiusKm: 5.0,
    status: ZoneStatus.warning,
    totalCases: 1247,
    activeCases: 312,
    population: 285000,
    temperatureC: 44.0,
    humidityPct: 62.0,
    airQualityIndex: 185.0,
    diseases: [_flu, _gastro, _heatExhaustion],
    alertsAr: [
      'ارتفاع حالات الإنفلونزا بنسبة 23% هذا الأسبوع',
      'مياه الشرب: يُنصح بغلي الماء قبل الاستخدام',
      'حرارة شديدة متوقعة — تجنب الخروج بين 12-4 مساءً',
    ],
    alertsEn: [
      'Flu cases up 23% this week',
      'Water advisory: boil water before use',
      'Extreme heat expected — avoid outdoors 12-4pm',
    ],
    lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
    forecastRisk: DiseaseRisk.high,
    forecastNoteAr: 'متوقع ارتفاع إضافي في الأسبوع القادم بسبب موجة الحر',
    forecastNoteEn: 'Expected further rise next week due to heat wave',
  ),
  HealthZone(
    id: 'basra_north',
    nameAr: 'شمال البصرة',
    nameEn: 'North Basra',
    districtAr: 'البصرة',
    districtEn: 'Basra',
    lat: 30.6200,
    lng: 47.8000,
    radiusKm: 6.0,
    status: ZoneStatus.danger,
    totalCases: 523,
    activeCases: 178,
    population: 195000,
    temperatureC: 45.0,
    humidityPct: 58.0,
    airQualityIndex: 220.0,
    diseases: [_dengue, _flu, _conjunctivitis],
    alertsAr: [
      '🚨 تحذير: رصد حالات حمى الضنك — تجنب مناطق المياه الراكدة',
      'التهاب الملتحمة في تصاعد — تجنب الأماكن المكتظة',
      'جودة الهواء سيئة — استخدم كمامة عند الخروج',
    ],
    alertsEn: [
      '🚨 Alert: Dengue cases detected — avoid stagnant water areas',
      'Conjunctivitis rising — avoid crowded areas',
      'Poor air quality — wear mask outdoors',
    ],
    lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    forecastRisk: DiseaseRisk.critical,
    forecastNoteAr: 'وضع حرج — يستوجب التدخل الصحي العاجل ومكافحة البعوض',
    forecastNoteEn: 'Critical situation — requires urgent health intervention and mosquito control',
  ),
  HealthZone(
    id: 'basra_south',
    nameAr: 'جنوب البصرة',
    nameEn: 'South Basra',
    districtAr: 'البصرة',
    districtEn: 'Basra',
    lat: 30.3900,
    lng: 47.7200,
    radiusKm: 7.0,
    status: ZoneStatus.watch,
    totalCases: 189,
    activeCases: 54,
    population: 142000,
    temperatureC: 42.0,
    humidityPct: 68.0,
    airQualityIndex: 145.0,
    diseases: [_gastro, _heatExhaustion],
    alertsAr: [
      'التهاب المعدة في انخفاض — استمر بإجراءات الوقاية',
      'اشرب الماء المعبّأ أو المغلي فقط',
    ],
    alertsEn: [
      'Gastro cases declining — continue prevention measures',
      'Drink only bottled or boiled water',
    ],
    lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
    forecastRisk: DiseaseRisk.medium,
    forecastNoteAr: 'الوضع تحت السيطرة مع مراقبة مستمرة',
    forecastNoteEn: 'Situation under control with ongoing monitoring',
  ),
  HealthZone(
    id: 'basra_west',
    nameAr: 'غرب البصرة',
    nameEn: 'West Basra',
    districtAr: 'البصرة',
    districtEn: 'Basra',
    lat: 30.5000,
    lng: 47.6500,
    radiusKm: 5.5,
    status: ZoneStatus.safe,
    totalCases: 67,
    activeCases: 12,
    population: 98000,
    temperatureC: 41.0,
    humidityPct: 55.0,
    airQualityIndex: 95.0,
    diseases: [_flu],
    alertsAr: ['الوضع الصحي مستقر — استمر بالوقاية الاعتيادية'],
    alertsEn: ['Health situation stable — continue routine prevention'],
    lastUpdated: DateTime.now().subtract(const Duration(hours: 8)),
    forecastRisk: DiseaseRisk.low,
    forecastNoteAr: 'لا توقعات سلبية للأسبوع القادم',
    forecastNoteEn: 'No negative forecasts for next week',
  ),
];

final List<ZoneHealthReport> _mockReports = [
  ZoneHealthReport(
    zoneId: 'basra_north',
    generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    weeklyNewCases: 178,
    weeklyRecovered: 43,
    reproductionNumber: 1.8,
    aiAnalysisAr:
        'الوضع الوبائي في شمال البصرة يُظهر نمطاً مقلقاً. رقم التكاثر الأساسي R=1.8 يعني أن كل حالة تُعدي 1.8 شخص في المتوسط، مما يستدعي تدخلاً عاجلاً. تزامن حمى الضنك مع ارتفاع الحرارة وتجمّع المياه الراكدة يُنذر بتفاقم الوضع.',
    aiAnalysisEn:
        'The epidemiological situation in North Basra shows a concerning pattern. Reproduction number R=1.8 means each case infects 1.8 people on average, requiring urgent intervention. The combination of dengue with high temperatures and stagnant water signals potential worsening.',
    recommendationsAr: [
      'رش مبيدات البعوض فوراً في المناطق المتضررة',
      'إغلاق مصادر المياه الراكدة',
      'نشر فرق طبية متنقلة في المناطق المصابة',
      'إلزام المواطنين بارتداء الكمامة في الأماكن العامة',
      'فتح مراكز طبية مؤقتة للفحص المجاني',
    ],
    recommendationsEn: [
      'Immediately spray insecticides in affected areas',
      'Eliminate all sources of stagnant water',
      'Deploy mobile medical teams in affected areas',
      'Mandate masks in public spaces',
      'Open temporary medical centers for free screening',
    ],
  ),
];

// ════════════════════════════════════════════════════════
//  ZoneState
// ════════════════════════════════════════════════════════
class ZoneState {
  final List<HealthZone> zones;
  final List<ZoneHealthReport> reports;
  final String? selectedZoneId;
  final bool isLoading;
  final bool isAnalyzing;

  const ZoneState({
    this.zones = const [],
    this.reports = const [],
    this.selectedZoneId,
    this.isLoading = false,
    this.isAnalyzing = false,
  });

  HealthZone? get selectedZone =>
      selectedZoneId != null
          ? zones.firstWhere((z) => z.id == selectedZoneId, orElse: () => zones.first)
          : null;

  ZoneHealthReport? reportFor(String zoneId) {
    try {
      return reports.firstWhere((r) => r.zoneId == zoneId);
    } catch (_) {
      return null;
    }
  }

  ZoneState copyWith({
    List<HealthZone>? zones,
    List<ZoneHealthReport>? reports,
    String? selectedZoneId,
    bool? isLoading,
    bool? isAnalyzing,
  }) =>
      ZoneState(
        zones: zones ?? this.zones,
        reports: reports ?? this.reports,
        selectedZoneId: selectedZoneId ?? this.selectedZoneId,
        isLoading: isLoading ?? this.isLoading,
        isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      );
}

// ════════════════════════════════════════════════════════
//  ZoneNotifier
// ════════════════════════════════════════════════════════
class ZoneNotifier extends Notifier<ZoneState> {
  @override
  ZoneState build() => ZoneState(
        zones: _mockZones,
        reports: _mockReports,
        selectedZoneId: _mockZones.first.id,
      );

  void selectZone(String id) => state = state.copyWith(selectedZoneId: id);

  Future<void> refreshZones() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isLoading: false);
  }

  Future<ZoneHealthReport?> analyzeZone(String zoneId) async {
    state = state.copyWith(isAnalyzing: true);
    await Future.delayed(const Duration(seconds: 3));

    final report = _mockReports.firstWhere(
      (r) => r.zoneId == zoneId,
      orElse: () => ZoneHealthReport(
        zoneId: zoneId,
        generatedAt: DateTime.now(),
        weeklyNewCases: 45,
        weeklyRecovered: 28,
        reproductionNumber: 0.9,
        aiAnalysisAr: 'الوضع الصحي مستقر. لا توجد مؤشرات على تفشي وبائي وشيك.',
        aiAnalysisEn: 'Health situation stable. No indicators of imminent epidemic.',
        recommendationsAr: ['الاستمرار بالمراقبة الدورية', 'تعزيز حملات التوعية الصحية'],
        recommendationsEn: ['Continue periodic monitoring', 'Strengthen health awareness campaigns'],
      ),
    );

    final updatedReports = [...state.reports];
    updatedReports.removeWhere((r) => r.zoneId == zoneId);
    updatedReports.add(report);

    state = state.copyWith(isAnalyzing: false, reports: updatedReports);
    return report;
  }
}

final zoneProvider = NotifierProvider<ZoneNotifier, ZoneState>(ZoneNotifier.new);