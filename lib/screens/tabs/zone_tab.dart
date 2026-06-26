// lib/screens/tabs/zone_tab.dart
// ════════════════════════════════════════════════════════
//  تبويب الزون الصحي - نظام رصد الحالات المرضية
//  ✅ عرض الحالات المبلّغة في المنطقة
//  ✅ خريطة حرارية توضح كثافة الحالات
//  ✅ زر للإبلاغ عن حالة جديدة
//  ✅ تحذيرات للمستخدمين عند دخول منطقة خطر
// ════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
// استيراد zone_provider مع إخفاء zoneProvider لتجنب التعارض
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
  late final MapController _mapController;
  ReportedCase? _selectedCase;
  bool _showReportDialog = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);
    final zoneState = ref.watch(zoneProvider);
    final selectedZone = zoneState.selectedZone;
    final isLoading = zoneState.isLoading;

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
                zones: zoneState.zones,
                selectedId: selectedZone?.id,
                isAr: isAr,
                onSelect: (id) => ref.read(zoneProvider.notifier).selectZone(id),
              ),
            ),
          ),

          // ── بطاقة المخاطر للمنطقة ──
          if (selectedZone != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _RiskCard(
                  zone: selectedZone!,
                  isAr: isAr,
                  onReport: () => setState(() => _showReportDialog = true),
                ),
              ),
            ),

          // ── الخريطة الحرارية ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SectionTitle(
                icon: Icons.map_rounded,
                label: isAr ? 'خريطة الحالات المبلّغة' : 'Reported Cases Map',
                color: AppColors.primary,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _Heatmap(
                  mapController: _mapController,
                  cases: selectedZone?.activeCases ?? [],
                  selectedCase: _selectedCase,
                  onCaseTap: (c) => setState(() => _selectedCase = c),
                  isAr: isAr,
                ),
              ),
            ),
          ),

          // ── قائمة الحالات النشطة ──
          if (selectedZone != null && selectedZone.activeCases.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _SectionTitle(
                  icon: Icons.warning_amber_rounded,
                  label: isAr
                      ? 'الحالات النشطة (${selectedZone.activeCases.length})'
                      : 'Active Cases (${selectedZone.activeCases.length})',
                  color: Colors.red,
                ),
              ),
            ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cases = selectedZone?.activeCases ?? [];
                if (index >= cases.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _CaseCard(
                    caseData: cases[index],
                    isAr: isAr,
                    onTap: () => setState(() => _selectedCase = cases[index]),
                    onResolve: () {
                      ref.read(zoneProvider.notifier).resolveCase(cases[index].id);
                    },
                  ),
                );
              },
              childCount: selectedZone?.activeCases.length ?? 0,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: _showReportDialog
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _showReportDialog = true),
              icon: const Icon(Icons.add_alert_rounded),
              label: Text(isAr ? 'إبلاغ عن حالة' : 'Report Case'),
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
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
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'مركز رصد الحالات' : 'Case Monitoring Center',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isAr ? 'تتبع الحالات المرضية والظواهر الصحية' : 'Track diseases and health incidents',
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
  final List<HealthZoneWithCases> zones;
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
          final riskColor = zone.getRiskColor();

          return GestureDetector(
            onTap: () => onSelect(zone.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? riskColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: riskColor.withValues(alpha: isSelected ? 0 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? riskColor : Colors.black)
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
                          color: riskColor,
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
                    '${zone.totalActiveCases} ${isAr ? 'حالة' : 'cases'}',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : riskColor,
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
//  _RiskCard - بطاقة المخاطر مع زر الإبلاغ
// ════════════════════════════════════════════════════════
class _RiskCard extends StatelessWidget {
  final HealthZoneWithCases zone;
  final bool isAr;
  final VoidCallback onReport;

  const _RiskCard({
    required this.zone,
    required this.isAr,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = zone.getRiskColor();
    final isDanger = zone.overallRisk == CaseRiskLevel.high ||
        zone.overallRisk == CaseRiskLevel.critical;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDanger
              ? [riskColor.withValues(alpha: 0.12), Colors.white]
              : [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDanger ? riskColor.withValues(alpha: 0.4) : const Color(0xFFE8EDF4),
          width: isDanger ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDanger ? riskColor.withValues(alpha: 0.15) : const Color(0x0A000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    isDanger ? Icons.warning_rounded : Icons.check_circle_rounded,
                    color: riskColor,
                    size: 28,
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
                        color: isDanger ? riskColor : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${zone.totalAffected} ${isAr ? 'مصاب' : 'affected'} · '
                      '${zone.totalActiveCases} ${isAr ? 'حالة نشطة' : 'active cases'}',
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
                  color: riskColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  zone.getRiskLabel(isAr),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // إحصاءات سريعة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: isAr ? 'حالات حرجة' : 'Critical',
                value: '${zone.criticalCases.length}',
                color: Colors.red,
              ),
              _StatItem(
                label: isAr ? 'إجمالي المصابين' : 'Total Affected',
                value: '${zone.totalAffected}',
                color: AppColors.textDark,
              ),
              _StatItem(
                label: isAr ? 'المصابين/حالة' : 'Avg per case',
                value: (zone.totalActiveCases > 0)
                    ? '${(zone.totalAffected / zone.totalActiveCases).toStringAsFixed(1)}'
                    : '0',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // زر الإبلاغ
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReport,
                  icon: const Icon(Icons.add_alert_rounded, size: 18),
                  label: Text(
                    isAr ? 'الإبلاغ عن حالة جديدة' : 'Report New Case',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
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
//  _Heatmap - الخريطة الحرارية
// ════════════════════════════════════════════════════════
class _Heatmap extends StatelessWidget {
  final MapController mapController;
  final List<ReportedCase> cases;
  final ReportedCase? selectedCase;
  final Function(ReportedCase) onCaseTap;
  final bool isAr;

  const _Heatmap({
    required this.mapController,
    required this.cases,
    required this.selectedCase,
    required this.onCaseTap,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10)],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_rounded, size: 48, color: AppColors.textGray),
              const SizedBox(height: 8),
              Text(
                isAr ? 'لا توجد حالات نشطة' : 'No active cases',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAr ? 'كن أول من يبلّغ عن حالة' : 'Be the first to report',
                style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      );
    }

    // حساب المركز لتجميع النقاط
    final center = cases.fold<LatLng>(
      LatLng(0, 0),
      (sum, c) => LatLng(sum.latitude + c.position.latitude, sum.longitude + c.position.longitude),
    );
    final avgCenter = LatLng(
      center.latitude / cases.length,
      center.longitude / cases.length,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: avgCenter,
          initialZoom: 12,
          minZoom: 4,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ighatha.app',
            maxZoom: 19,
          ),

          // ── دوائر الحرارة (Heatmap) ──
          CircleLayer(
            circles: cases.map((c) {
              final intensity = c.intensity.clamp(0.5, 5.0);
              final radius = 300 * intensity;
              final opacity = (intensity / 5).clamp(0.1, 0.6);

              return CircleMarker(
                point: c.position,
                radius: radius,
                useRadiusInMeter: true,
                color: c.color.withValues(alpha: opacity * 0.4),
                borderColor: c.color.withValues(alpha: opacity * 0.8),
                borderStrokeWidth: 1.5,
              );
            }).toList(),
          ),

          // ── علامات الحالات ──
          MarkerLayer(
            markers: cases.map((c) {
              final isSelected = selectedCase?.id == c.id;
              return Marker(
                point: c.position,
                width: isSelected ? 50 : 40,
                height: isSelected ? 50 : 40,
                child: GestureDetector(
                  onTap: () => onCaseTap(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 50 : 40,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.color.withValues(alpha: isSelected ? 0.6 : 0.3),
                          blurRadius: isSelected ? 20 : 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(c.icon, color: Colors.white, size: isSelected ? 22 : 18),
                        if (c.riskLevel == CaseRiskLevel.critical)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '!',
                                  style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (c.affectedCount > 1)
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x22000000), blurRadius: 3),
                                ],
                              ),
                              child: Text(
                                '${c.affectedCount}',
                                style: GoogleFonts.cairo(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: c.color,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _CaseCard - بطاقة الحالة
// ════════════════════════════════════════════════════════
class _CaseCard extends StatelessWidget {
  final ReportedCase caseData;
  final bool isAr;
  final VoidCallback onTap;
  final VoidCallback onResolve;

  const _CaseCard({
    required this.caseData,
    required this.isAr,
    required this.onTap,
    required this.onResolve,
  });

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return isAr ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m';
    if (diff.inHours < 24) return isAr ? 'منذ ${diff.inHours} س' : '${diff.inHours}h';
    return isAr ? 'منذ ${diff.inDays} ي' : '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: caseData.color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: caseData.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(caseData.icon, color: caseData.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? caseData.titleAr : caseData.titleEn,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isAr ? caseData.locationNameAr : caseData.locationNameEn,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: AppColors.textGray,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: caseData.getRiskColor().withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          caseData.getRiskLabel(isAr),
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: caseData.getRiskColor(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(caseData.reportedAt),
                        style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: caseData.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${caseData.affectedCount}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: caseData.color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onResolve,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAr ? 'حل' : 'Resolve',
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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