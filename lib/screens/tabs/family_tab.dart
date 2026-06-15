// lib/screens/tabs/family_tab.dart
// ════════════════════════════════════════════════════════
//  tabs/family_tab.dart
//  تبويب العائلة - إدارة أفراد العائلة والسجل الطبي
//  ✅ بطاقة الهوية الرقمية
//  ✅ قائمة أفراد العائلة مع السجل الطبي
//  ✅ طلب إسعاف لأي فرد مع إرسال بياناته الطبية
//  ✅ وضع الأطفال المحمي
//  ✅ سجل البلاغات
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/family_member.dart';
import '../../core/data/mock_users.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/family/add_member_sheet.dart';
import '../widgets/family/emergency_for_member_sheet.dart';

// ════════════════════════════════════════════════════════
//  FamilyTab
// ════════════════════════════════════════════════════════
class FamilyTab extends ConsumerWidget {
  const FamilyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(languageProvider);
    final family = ref.watch(familyProvider);
    final members = family.members;
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Text(
              isAr ? 'عائلتي' : 'My Family',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                onPressed: () => _showAddMemberSheet(context, ref, isAr),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── تنبيه SOS نشط ──
                if (family.activeSOSMemberId != null) ...[
                  _ActiveSOSBanner(
                    member: members.firstWhere(
                      (m) => m.id == family.activeSOSMemberId,
                      orElse: () => members.first,
                    ),
                    isAr: isAr,
                    onResolve: () => ref.read(familyProvider.notifier).resolveEmergency(family.activeSOSMemberId!),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── بطاقة الهوية الرقمية (للمستخدمين المسجلين فقط) ──
                if (session != null && !session.isGuest) ...[
                  _RationCard(user: session, members: members, isAr: isAr),
                  const SizedBox(height: 18),
                ],

                // ── رأس قائمة العائلة ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'أفراد العائلة (${members.length})' : 'Family Members (${members.length})',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    _StatusSummary(members: members, isAr: isAr),
                  ],
                ),
                const SizedBox(height: 12),

                // ── قائمة الأفراد ──
                ...members.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FamilyMemberCard(
                    member: m,
                    isAr: isAr,
                    onSOS: () => _showEmergencySheet(context, ref, m, isAr),
                    onSafe: () => ref.read(familyProvider.notifier).updateStatus(m.id, MemberStatus.safe),
                    onProfile: () => _showMemberProfile(context, m, isAr),
                  ),
                )),

                // ── زر إضافة فرد ──
                _AddMemberButton(isAr: isAr, onTap: () => _showAddMemberSheet(context, ref, isAr)),
                const SizedBox(height: 20),

                // ── سجل البلاغات ──
                if (family.reports.isNotEmpty) ...[
                  Text(
                    isAr ? 'سجل البلاغات' : 'Report History',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...family.reports.take(5).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ReportCard(report: r, isAr: isAr),
                  )),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(BuildContext ctx, WidgetRef ref, bool isAr) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberSheet(isAr: isAr, ref: ref),
    );
  }

  void _showEmergencySheet(BuildContext ctx, WidgetRef ref, FamilyMember m, bool isAr) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmergencySheet(patient: m, ref: ref, isAr: isAr),
    );
  }

  void _showMemberProfile(BuildContext ctx, FamilyMember m, bool isAr) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => _MemberProfileScreen(member: m, isAr: isAr),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _RationCard - بطاقة الهوية الرقمية
// ════════════════════════════════════════════════════════
class _RationCard extends StatefulWidget {
  final MockUser user;
  final List<FamilyMember> members;
  final bool isAr;

  const _RationCard({
    required this.user,
    required this.members,
    required this.isAr,
  });

  @override
  State<_RationCard> createState() => _RationCardState();
}

class _RationCardState extends State<_RationCard> with SingleTickerProviderStateMixin {
  late AnimationController _shineCtrl;

  @override
  void initState() {
    super.initState();
    _shineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final members = widget.members;
    final isAr = widget.isAr;
    final safeCount = members.where((m) => m.status == MemberStatus.safe).length;
    final dangerCount = members.where((m) => m.status == MemberStatus.danger || m.status == MemberStatus.sos).length;

    return AnimatedBuilder(
      animation: _shineCtrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0288D1).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // خلفية التدرج
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF003C6E), Color(0xFF01579B), Color(0xFF0288D1), Color(0xFF4FC3F7)],
                    stops: [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رأس البطاقة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'إغاثة · بطاقة الطوارئ الرقمية' : 'Ighatha · Emergency Digital ID',
                              style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: dangerCount > 0
                                ? AppColors.danger.withValues(alpha: 0.3)
                                : const Color(0xFF43A047).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dangerCount > 0
                                  ? AppColors.danger.withValues(alpha: 0.5)
                                  : const Color(0xFF43A047).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            dangerCount > 0
                                ? (isAr ? '⚠ $dangerCount تنبيه' : '⚠ $dangerCount Alert')
                                : (isAr ? 'فعّالة' : 'Active'),
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: dangerCount > 0 ? const Color(0xFFFFCDD2) : const Color(0xFF81C784),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // معلومات صاحب البطاقة
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              user.nameAr.isNotEmpty ? user.nameAr[0] : 'إ',
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nameAr,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'ID: ${user.id}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 26),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(height: 0.5, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),

                    // إحصائيات سريعة
                    Row(
                      children: [
                        _RationStat(value: '${members.length}', label: isAr ? 'أفراد' : 'Members'),
                        const SizedBox(width: 16),
                        _RationStat(value: '$safeCount', label: isAr ? 'بأمان' : 'Safe', valueColor: const Color(0xFF81C784)),
                        const SizedBox(width: 16),
                        _RationStat(value: '${DateTime.now().year + 1}', label: isAr ? 'صالحة لـ' : 'Valid Until'),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // أفاتارات أفراد العائلة
                    Row(
                      children: [
                        ...List.generate(members.length > 5 ? 5 : members.length, (index) {
                          final m = members[index];
                          final isOk = m.status == MemberStatus.safe;
                          return Transform.translate(
                            offset: Offset(index * -5.0, 0),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOk ? Colors.white.withValues(alpha: 0.18) : AppColors.danger.withValues(alpha: 0.4),
                                border: Border.all(
                                  color: isOk ? Colors.white.withValues(alpha: 0.5) : AppColors.danger,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  m.initials,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        const Spacer(),
                        Text(
                          isAr ? 'جمهورية العراق' : 'Republic of Iraq',
                          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // بريق متحرك
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ShinePainter(progress: _shineCtrl.value),
                  ),
                ),
              ),

              // دوائر زخرفية
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RationStat extends StatelessWidget {
  final String value, label;
  final Color? valueColor;

  const _RationStat({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
            height: 1,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}

class _ShinePainter extends CustomPainter {
  final double progress;
  const _ShinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width * 0.3 + progress * (size.width * 1.6);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.white.withValues(alpha: 0.05), Colors.transparent],
      ).createShader(Rect.fromLTWH(x - 40, 0, 80, size.height));
    canvas.drawRect(Rect.fromLTWH(x - 40, 0, 80, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShinePainter old) => old.progress != progress;
}

// ════════════════════════════════════════════════════════
//  _FamilyMemberCard - بطاقة فرد العائلة
// ════════════════════════════════════════════════════════
class _FamilyMemberCard extends StatefulWidget {
  final FamilyMember member;
  final bool isAr;
  final VoidCallback onSOS, onSafe, onProfile;

  const _FamilyMemberCard({
    required this.member,
    required this.isAr,
    required this.onSOS,
    required this.onSafe,
    required this.onProfile,
  });

  @override
  State<_FamilyMemberCard> createState() => _FamilyMemberCardState();
}

class _FamilyMemberCardState extends State<_FamilyMemberCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _rotation;

  static const List<Color> _avatarColors = [
    Color(0xFFB5D4F4), Color(0xFFC0DD97), Color(0xFFFFCDD2),
    Color(0xFFE1BEE7), Color(0xFFB2EBF2), Color(0xFFFFE082),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.member.status) {
      case MemberStatus.safe:
        return const Color(0xFF2E7D32);
      case MemberStatus.unknown:
        return const Color(0xFFF57F17);
      case MemberStatus.danger:
      case MemberStatus.sos:
        return AppColors.danger;
    }
  }

  String get _statusLabel {
    final isAr = widget.isAr;
    switch (widget.member.status) {
      case MemberStatus.safe:
        return isAr ? 'بأمان' : 'Safe';
      case MemberStatus.unknown:
        return isAr ? 'غير معروف' : 'Unknown';
      case MemberStatus.danger:
        return isAr ? 'خطر' : 'Danger';
      case MemberStatus.sos:
        return isAr ? '🆘 يستغيث!' : '🆘 SOS!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final isSOS = m.status == MemberStatus.sos || m.status == MemberStatus.danger;
    final avatarColor = _avatarColors[m.id.hashCode.abs() % _avatarColors.length];

    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
        _expanded ? _ctrl.forward() : _ctrl.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isSOS ? const Color(0xFFFCEBEB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSOS ? AppColors.danger.withValues(alpha: 0.45) : const Color(0xFFE8EDF4),
            width: isSOS ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSOS ? AppColors.danger.withValues(alpha: 0.1) : const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // أفاتار
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                      border: isSOS ? Border.all(color: AppColors.danger, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        m.initials,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A2332),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // معلومات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.isAr ? m.nameAr : m.nameEn,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSOS ? AppColors.danger : AppColors.textDark,
                              ),
                            ),
                            if (m.isChild) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9C4),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text('👶', style: TextStyle(fontSize: 9)),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${m.relationLabel(widget.isAr)} · ${m.age} ${widget.isAr ? "سنة" : "yrs"} · ${m.bloodLabel()}',
                          style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
                        ),
                        const SizedBox(height: 3),

                        // الحالة والموقع
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _statusColor)),
                            const SizedBox(width: 5),
                            Text(_statusLabel, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor)),
                            if (m.lastLocation != null) ...[
                              Text(' · ', style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray)),
                              Expanded(
                                child: Text(
                                  m.lastLocation!,
                                  style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // ملاحظة طبية
                        if (m.emergencyNote != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 11, color: Color(0xFFF57F17)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  m.emergencyNote!,
                                  style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFFF57F17), height: 1.3),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // أزرار التحكم
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          widget.onSOS();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.danger.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'SOS',
                            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      RotationTransition(
                        turns: _rotation,
                        child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGray, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // تفاصيل موسعة
            if (_expanded) _ExpandedDetails(member: m, isAr: widget.isAr, onProfile: widget.onProfile, onSafe: widget.onSafe),
          ],
        ),
      ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  final FamilyMember member;
  final bool isAr;
  final VoidCallback onProfile, onSafe;

  const _ExpandedDetails({
    required this.member,
    required this.isAr,
    required this.onProfile,
    required this.onSafe,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedical = member.chronicDiseases.isNotEmpty || member.allergies.isNotEmpty || member.currentMeds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          if (hasMedical)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (member.chronicDiseases.isNotEmpty)
                    _MedicalRow(
                      icon: Icons.monitor_heart_rounded,
                      color: AppColors.danger,
                      label: isAr ? 'أمراض مزمنة' : 'Chronic Diseases',
                      value: member.chronicDiseases.join(' · '),
                    ),
                  if (member.allergies.isNotEmpty)
                    _MedicalRow(
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      label: isAr ? 'حساسيات' : 'Allergies',
                      value: member.allergies.join(' · '),
                    ),
                  if (member.currentMeds.isNotEmpty)
                    _MedicalRow(
                      icon: Icons.medication_rounded,
                      color: AppColors.primary,
                      label: isAr ? 'أدوية' : 'Medications',
                      value: member.currentMeds.join(' · '),
                    ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onProfile,
                  icon: const Icon(Icons.person_rounded, size: 15),
                  label: Text(
                    isAr ? 'الملف الكامل' : 'Full Profile',
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                  ),
                ),
              ),
              if (member.status != MemberStatus.safe) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSafe,
                    icon: const Icon(Icons.check_circle_rounded, size: 15),
                    label: Text(
                      isAr ? 'بأمان الآن' : 'Mark Safe',
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size.zero,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicalRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;

  const _MedicalRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text('$label: ', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ActiveSOSBanner
// ════════════════════════════════════════════════════════
class _ActiveSOSBanner extends StatefulWidget {
  final FamilyMember member;
  final bool isAr;
  final VoidCallback onResolve;

  const _ActiveSOSBanner({
    required this.member,
    required this.isAr,
    required this.onResolve,
  });

  @override
  State<_ActiveSOSBanner> createState() => _ActiveSOSBannerState();
}

class _ActiveSOSBannerState extends State<_ActiveSOSBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFE53935)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.danger.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  widget.member.initials,
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚨 ${widget.isAr ? widget.member.nameAr : widget.member.nameEn} ${widget.isAr ? "بحاجة مساعدة!" : "needs help!"}',
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    widget.isAr ? 'الإسعاف في الطريق' : 'Ambulance on the way',
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onResolve,
              child: Text(
                widget.isAr ? 'بأمان' : 'Safe',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _StatusSummary
// ════════════════════════════════════════════════════════
class _StatusSummary extends StatelessWidget {
  final List<FamilyMember> members;
  final bool isAr;

  const _StatusSummary({required this.members, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final safe = members.where((m) => m.status == MemberStatus.safe).length;
    final danger = members.where((m) => m.status != MemberStatus.safe).length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusChip(count: safe, color: AppColors.success, icon: Icons.check_circle_rounded),
        if (danger > 0) ...[
          const SizedBox(width: 6),
          _StatusChip(count: danger, color: AppColors.danger, icon: Icons.warning_rounded),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final int count;
  final Color color;
  final IconData icon;

  const _StatusChip({required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text('$count', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _AddMemberButton
// ════════════════════════════════════════════════════════
class _AddMemberButton extends StatelessWidget {
  final bool isAr;
  final VoidCallback onTap;

  const _AddMemberButton({required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          borderRadius: BorderRadius.circular(14),
          color: AppColors.primary.withValues(alpha: 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              isAr ? 'إضافة فرد جديد للعائلة' : 'Add New Family Member',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ReportCard
// ════════════════════════════════════════════════════════
class _ReportCard extends StatelessWidget {
  final EmergencyReport report;
  final bool isAr;

  const _ReportCard({required this.report, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      ReportStatus.dispatched: AppColors.warning,
      ReportStatus.resolved: AppColors.success,
      ReportStatus.pending: AppColors.textGray,
      ReportStatus.cancelled: AppColors.textMuted,
    };
    final color = colorMap[report.status] ?? AppColors.textGray;

    final statusLabelMap = {
      ReportStatus.dispatched: isAr ? 'في الطريق' : 'Dispatched',
      ReportStatus.resolved: isAr ? 'تم الحل' : 'Resolved',
      ReportStatus.pending: isAr ? 'انتظار' : 'Pending',
      ReportStatus.cancelled: isAr ? 'ملغى' : 'Cancelled',
    };
    final statusLabel = statusLabelMap[report.status] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              report.status == ReportStatus.resolved ? Icons.check_circle_rounded : Icons.local_hospital_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${report.emergencyType} — ${isAr ? report.patient.nameAr : report.patient.nameEn}',
                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  '${report.time.hour}:${report.time.minute.toString().padLeft(2, '0')} · ${report.location ?? ''}',
                  style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(statusLabel, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _MemberProfileScreen - شاشة ملف الفرد
// ════════════════════════════════════════════════════════
class _MemberProfileScreen extends StatelessWidget {
  final FamilyMember member;
  final bool isAr;

  const _MemberProfileScreen({required this.member, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          isAr ? member.nameAr : member.nameEn,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Column(
          children: [
            // بطاقة الهوية
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF01579B), Color(0xFF0288D1), Color(0xFF4FC3F7)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0288D1).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            member.initials,
                            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? member.nameAr : member.nameEn,
                              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              '${member.relationLabel(isAr)} · ${member.age} ${isAr ? "سنة" : "yrs"}',
                              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          member.bloodLabel(),
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if (member.emergencyNote != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              member.emergencyNote!,
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // الملف الطبي
            if (member.chronicDiseases.isNotEmpty || member.allergies.isNotEmpty || member.currentMeds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.medical_information_rounded, color: AppColors.danger, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isAr ? 'الملف الطبي' : 'Medical Profile',
                          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAr ? 'يُرسل مع البلاغ' : 'Sent with report',
                            style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (member.chronicDiseases.isNotEmpty)
                      _MedicalSection(
                        icon: Icons.monitor_heart_rounded,
                        color: AppColors.danger,
                        title: isAr ? 'أمراض مزمنة' : 'Chronic Diseases',
                        items: member.chronicDiseases,
                      ),
                    if (member.allergies.isNotEmpty)
                      _MedicalSection(
                        icon: Icons.warning_rounded,
                        color: AppColors.warning,
                        title: isAr ? 'حساسيات' : 'Allergies',
                        items: member.allergies,
                      ),
                    if (member.currentMeds.isNotEmpty)
                      _MedicalSection(
                        icon: Icons.medication_rounded,
                        color: AppColors.primary,
                        title: isAr ? 'أدوية دائمة' : 'Regular Medications',
                        items: member.currentMeds,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // تحذير للأطفال
            if (member.isChild)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF9A825).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Text('👶', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'طفل — يمكنه الضغط على زر SOS 3 مرات لإرسال موقعه لأفراد العائلة'
                            : 'Child — pressing SOS 3× sends location to all family members',
                        style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF7B5800), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedicalSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> items;

  const _MedicalSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: items.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(s, style: GoogleFonts.cairo(fontSize: 12, color: color)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}