// lib/screens/tabs/zone_tab.dart
// ════════════════════════════════════════════════════════
//  tabs/zone_tab.dart
//  تبويب تحليل البيئة الصحية - المناطق والمخاطر
//  ✅ عرض المناطق الصحية في العراق
//  ✅ تحليل الأمراض المنتشرة مع مؤشرات المخاطر
//  ✅ تقارير الذكاء الاصطناعي والتوصيات
//  ✅ مؤشرات بيئية
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
// استيراد zone_provider للأنواع فقط، مع إخفاء zoneProvider لتجنب التعارض
import '../../core/providers/zone_provider.dart' hide zoneProvider;

// ════════════════════════════════════════════════════════
//  ZoneTab
// ════════════════════════════════════════════════════════
class ZoneTab extends ConsumerStatefulWidget {
  const ZoneTab({super.key});

  @override
  ConsumerState<ZoneTab> createState() => _ZoneTabState();
}

class _ZoneTabState extends ConsumerState<ZoneTab> {
  bool _showFullReport = false;

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);
    final zoneState = ref.watch(zoneProvider);
    final zones = zoneState.zones;
    final selectedZone = zoneState.selectedZone;
    final isLoading = zoneState.isLoading;
    final isAnalyzing = zoneState.isAnalyzing;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── الهيدر ──
          SliverToBoxAdapter(
            child: _ZoneHeader(
              isAr: isAr,
              isLoading: isLoading,
              onRefresh: () => ref.read(zoneProvider.notifier).refreshZones(),
            ),
          ),

          // ── اختيار المنطقة ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _ZoneSelector(
                zones: zones,
                selectedId: selectedZone?.id,
                isAr: isAr,
                onSelect: (id) => ref.read(zoneProvider.notifier).selectZone(id),
              ),
            ),
          ),

          // ── بطاقة المنطقة المختارة ──
          if (selectedZone != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ZoneCard(
                  zone: selectedZone,
                  isAr: isAr,
                  onAnalyze: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(zoneProvider.notifier).analyzeZone(selectedZone.id);
                    setState(() => _showFullReport = true);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) setState(() => _showFullReport = false);
                    });
                  },
                  isAnalyzing: isAnalyzing,
                ),
              ),
            ),

          // ── الأمراض المنتشرة ──
          if (selectedZone != null && selectedZone.diseases.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _SectionTitle(
                  icon: Icons.sick_rounded,
                  label: isAr ? 'الأمراض المنتشرة' : 'Diseases Outbreak',
                  color: AppColors.danger,
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DiseasesList(
                diseases: selectedZone?.diseases ?? [],
                isAr: isAr,
              ),
            ),
          ),

          // ── المؤشرات البيئية ──
          if (selectedZone != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _SectionTitle(
                  icon: Icons.thermostat_rounded,
                  label: isAr ? 'المؤشرات البيئية' : 'Environmental Indicators',
                  color: AppColors.primary,
                ),
              ),
            ),

          if (selectedZone != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _EnvironmentalCard(zone: selectedZone, isAr: isAr),
              ),
            ),

          // ── تقرير الذكاء الاصطناعي ──
          if (selectedZone != null && zoneState.reportFor(selectedZone.id) != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _SectionTitle(
                  icon: Icons.psychology_rounded,
                  label: isAr ? 'تحليل الذكاء الاصطناعي' : 'AI Analysis',
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ),

          if (selectedZone != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AIReportCard(
                  report: zoneState.reportFor(selectedZone.id),
                  isAr: isAr,
                  isExpanded: _showFullReport,
                  onToggle: () => setState(() => _showFullReport = !_showFullReport),
                ),
              ),
            ),

          // ── التنبيهات ──
          if (selectedZone != null && selectedZone.alertsAr.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _SectionTitle(
                  icon: Icons.warning_amber_rounded,
                  label: isAr ? 'التنبيهات' : 'Alerts',
                  color: const Color(0xFFE65100),
                ),
              ),
            ),

          if (selectedZone != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AlertsList(
                  alerts: isAr ? selectedZone.alertsAr : selectedZone.alertsEn,
                  isAr: isAr,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ZoneHeader
// ════════════════════════════════════════════════════════
class _ZoneHeader extends StatelessWidget {
  final bool isAr;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _ZoneHeader({
    required this.isAr,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 18,
        right: 18,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'تحليل البيئة الصحية' : 'Health Zone Analysis',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isAr ? 'مراقبة الأمراض والمخاطر في المناطق' : 'Monitor diseases and risks by zone',
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ZoneSelector
// ════════════════════════════════════════════════════════
class _ZoneSelector extends StatelessWidget {
  final List<HealthZone> zones;
  final String? selectedId;
  final bool isAr;
  final ValueChanged<String> onSelect;

  const _ZoneSelector({
    required this.zones,
    required this.selectedId,
    required this.isAr,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: zones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final zone = zones[i];
          final isSelected = selectedId == zone.id;
          return GestureDetector(
            onTap: () => onSelect(zone.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? zone.getStatusColor() : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: zone.getStatusColor().withValues(alpha: isSelected ? 0 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? zone.getStatusColor() : Colors.black)
                        .withValues(alpha: isSelected ? 0.25 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: zone.getStatusColor(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isAr ? zone.nameAr : zone.nameEn,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${zone.activeCases} ${isAr ? 'حالة' : 'cases'}',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : zone.getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAr ? 'نشطة حالياً' : 'active now',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ZoneCard
// ════════════════════════════════════════════════════════
class _ZoneCard extends StatelessWidget {
  final HealthZone zone;
  final bool isAr;
  final VoidCallback onAnalyze;
  final bool isAnalyzing;

  const _ZoneCard({
    required this.zone,
    required this.isAr,
    required this.onAnalyze,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = zone.getStatusColor();
    final isHighRisk = zone.status == ZoneStatus.warning || zone.status == ZoneStatus.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHighRisk
              ? [statusColor.withValues(alpha: 0.12), Colors.white]
              : [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighRisk ? statusColor.withValues(alpha: 0.4) : const Color(0xFFE8EDF4),
          width: isHighRisk ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighRisk ? statusColor.withValues(alpha: 0.15) : const Color(0x0A000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    zone.status == ZoneStatus.safe ? '🛡️' : '⚠️',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? zone.nameAr : zone.nameEn,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isHighRisk ? statusColor : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${zone.districtAr} · ${zone.population} ${isAr ? 'نسمة' : 'people'}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  zone.getStatusLabel(isAr),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // إحصائيات سريعة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: isAr ? 'الحالات الكلية' : 'Total Cases',
                value: '${zone.totalCases}',
                color: AppColors.textDark,
              ),
              _StatItem(
                label: isAr ? 'حالات نشطة' : 'Active Cases',
                value: '${zone.activeCases}',
                color: AppColors.danger,
              ),
              _StatItem(
                label: isAr ? 'نسبة النشاط' : 'Activity Rate',
                value: '${zone.activePercentage.toStringAsFixed(1)}‱',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // زر التحليل
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isAnalyzing ? null : onAnalyze,
              icon: isAnalyzing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                isAnalyzing
                    ? (isAr ? 'جاري التحليل...' : 'Analyzing...')
                    : (isAr ? 'تحليل بالذكاء الاصطناعي' : 'AI Analysis'),
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  _DiseasesList
// ════════════════════════════════════════════════════════
class _DiseasesList extends StatelessWidget {
  final List<TrackedDisease> diseases;
  final bool isAr;

  const _DiseasesList({
    required this.diseases,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    if (diseases.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: diseases.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _DiseaseCard(disease: d, isAr: isAr),
      )).toList(),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  final TrackedDisease disease;
  final bool isAr;

  const _DiseaseCard({
    required this.disease,
    required this.isAr,
  });

  Color get _riskColor {
    switch (disease.risk) {
      case DiseaseRisk.low:
        return Colors.green;
      case DiseaseRisk.medium:
        return Colors.orange;
      case DiseaseRisk.high:
        return Colors.deepOrange;
      case DiseaseRisk.critical:
        return Colors.red;
    }
  }

  String get _riskLabel {
    switch (disease.risk) {
      case DiseaseRisk.low:
        return isAr ? 'منخفض' : 'Low';
      case DiseaseRisk.medium:
        return isAr ? 'متوسط' : 'Medium';
      case DiseaseRisk.high:
        return isAr ? 'مرتفع' : 'High';
      case DiseaseRisk.critical:
        return isAr ? 'حرج' : 'Critical';
    }
  }

  String get _trendIcon {
    switch (disease.trend) {
      case TrendDir.rising:
        return '📈';
      case TrendDir.falling:
        return '📉';
      case TrendDir.stable:
        return '➡️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: disease.color.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: disease.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(disease.emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? disease.nameAr : disease.nameEn,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${disease.casesCount} ${isAr ? 'حالة' : 'cases'}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: disease.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${disease.casesChange > 0 ? '+' : ''}${disease.casesChange}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: disease.casesChange > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_trendIcon, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      _riskLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _riskColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // الأعراض
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (isAr ? disease.symptomsAr : disease.symptomsEn).map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                s,
                style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // الإجراءات الوقائية
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (isAr ? disease.preventionAr : disease.preventionEn).map((p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: disease.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: disease.color.withValues(alpha: 0.2)),
              ),
              child: Text(
                p,
                style: GoogleFonts.cairo(fontSize: 10, color: disease.color),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _EnvironmentalCard
// ════════════════════════════════════════════════════════
class _EnvironmentalCard extends StatelessWidget {
  final HealthZone zone;
  final bool isAr;

  const _EnvironmentalCard({
    required this.zone,
    required this.isAr,
  });

  Color _getAirQualityColor(double aqi) {
    if (aqi < 50) return Colors.green;
    if (aqi < 100) return Colors.lightGreen;
    if (aqi < 150) return Colors.yellow.shade700;
    if (aqi < 200) return Colors.orange;
    return Colors.red;
  }

  String _getAirQualityLabel(double aqi) {
    if (aqi < 50) return isAr ? 'جيد' : 'Good';
    if (aqi < 100) return isAr ? 'مقبول' : 'Moderate';
    if (aqi < 150) return isAr ? 'غير صحي للحساسين' : 'Unhealthy for Sensitive';
    if (aqi < 200) return isAr ? 'غير صحي' : 'Unhealthy';
    return isAr ? 'خطير' : 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    final airQualityColor = _getAirQualityColor(zone.airQualityIndex);
    final airQualityLabel = _getAirQualityLabel(zone.airQualityIndex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // المؤشرات الرئيسية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EnvItem(
                icon: Icons.thermostat_rounded,
                label: isAr ? 'درجة الحرارة' : 'Temperature',
                value: '${zone.temperatureC.toStringAsFixed(0)}°C',
                color: const Color(0xFFE65100),
              ),
              _EnvItem(
                icon: Icons.water_drop_rounded,
                label: isAr ? 'الرطوبة' : 'Humidity',
                value: '${zone.humidityPct.toStringAsFixed(0)}%',
                color: const Color(0xFF0288D1),
              ),
              _EnvItem(
                icon: Icons.air_rounded,
                label: isAr ? 'جودة الهواء' : 'Air Quality',
                value: zone.airQualityIndex.toStringAsFixed(0),
                color: airQualityColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // شريط جودة الهواء
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: airQualityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: airQualityColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.air_rounded, color: airQualityColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'جودة الهواء: ' : 'Air Quality: ',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: zone.airQualityIndex / 500,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(airQualityColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  airQualityLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: airQualityColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // التنبؤ
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr ? zone.forecastNoteAr : zone.forecastNoteEn,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
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

class _EnvItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _EnvItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textGray),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  _AIReportCard
// ════════════════════════════════════════════════════════
class _AIReportCard extends StatelessWidget {
  final ZoneHealthReport? report;
  final bool isAr;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AIReportCard({
    required this.report,
    required this.isAr,
    required this.isExpanded,
    required this.onToggle,
  });

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return isAr ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return isAr ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours} hours ago';
    return isAr ? 'منذ ${diff.inDays} يوم' : '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    if (report == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isExpanded ? 16 : 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEDE7F6), Color(0xFFF3E5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCE93D8), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF6A1B9A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'تحليل الذكاء الاصطناعي' : 'AI Analysis Report',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A148C),
                      ),
                    ),
                    Text(
                      'R₀ = ${report!.reproductionNumber.toStringAsFixed(1)} · ${isAr ? 'تم التحليل' : 'Analyzed'} ${_formatTime(report!.generatedAt)}',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAr ? report!.aiAnalysisAr : report!.aiAnalysisEn,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isAr ? 'التوصيات' : 'Recommendations',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            const SizedBox(height: 8),
            ...(isAr ? report!.recommendationsAr : report!.recommendationsEn).map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _AlertsList
// ════════════════════════════════════════════════════════
class _AlertsList extends StatelessWidget {
  final List<String> alerts;
  final bool isAr;

  const _AlertsList({
    required this.alerts,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: alerts.map((alert) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _SectionTitle
// ════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}