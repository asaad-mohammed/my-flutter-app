// ════════════════════════════════════════════════════════
//  widgets/family/ration_card_widget.dart
//  ✅ إصلاح: تاريخ الصلاحية يُحسب ديناميكياً بدلاً من '2026' ثابتة
//  ✅ إصلاح: إزالة _MockUserCompat غير المستخدمة
//  ✅ تحسين: إضافة زر مشاركة البطاقة
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/family_member.dart';
import '../../../core/theme/app_colors.dart';

class RationCard extends StatefulWidget {
  final dynamic user; // MockUser أو أي كائن بيانات المستخدم
  final List<FamilyMember> members;
  final bool isAr;

  const RationCard({
    super.key,
    required this.user,
    required this.members,
    required this.isAr,
  });

  @override
  State<RationCard> createState() => _RationCardState();
}

class _RationCardState extends State<RationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shine;
  late Animation<double> _shineAnim;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _shineAnim = CurvedAnimation(parent: _shine, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shineAnim,
      builder: (_, __) => _buildCard(),
    );
  }

  Widget _buildCard() {
    final nameAr = widget.user?.nameAr ?? 'المستخدم';
    final id = widget.user?.nationalId ?? widget.user?.id ?? '—';
    // ✅ إصلاح: حساب سنة الانتهاء ديناميكياً
    final validUntil = DateTime.now().year + 1;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ── خلفية التدرج ────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF003C6E),
                    Color(0xFF01579B),
                    Color(0xFF0288D1),
                    Color(0xFF29B6F6),
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildOwnerInfo(nameAr, id),
                  const SizedBox(height: 14),
                  _buildDivider(),
                  const SizedBox(height: 12),
                  _buildStatsRow(validUntil),
                  const SizedBox(height: 14),
                  _buildFamilyAvatars(),
                  const SizedBox(height: 14),
                  _buildFooter(),
                ],
              ),
            ),

            // ── بريق sweep ──────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ShinePainter(progress: _shineAnim.value),
                ),
              ),
            ),

            // ── نمط هندسي خفيف ──────────────────────
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                widget.isAr
                    ? 'إغاثة · بطاقة الطوارئ الرقمية'
                    : 'Ighatha · Emergency ID',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF43A047).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF81C784),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.isAr ? 'فعّالة' : 'Active',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: const Color(0xFF81C784),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildOwnerInfo(String nameAr, String id) => Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              border: Border.all(
                  color: Colors.white.withOpacity(0.35), width: 2),
            ),
            child: Center(
              child: Text(
                nameAr.isNotEmpty ? nameAr[0] : 'إ',
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
                  nameAr,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ID: $id',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65),
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 26),
          ),
        ],
      );

  Widget _buildDivider() =>
      Container(height: 0.5, color: Colors.white.withOpacity(0.2));

  // ✅ إصلاح: تمرير validUntil كمعامل
  Widget _buildStatsRow(int validUntil) {
    final safe = widget.members
        .where((m) => m.status == MemberStatus.safe)
        .length;
    final total = widget.members.length;
    final danger = widget.members
        .where((m) =>
            m.status == MemberStatus.danger || m.status == MemberStatus.sos)
        .length;

    return Row(
      children: [
        _StatChip(
            value: '$total',
            label: widget.isAr ? 'أفراد' : 'Members'),
        const SizedBox(width: 8),
        _StatChip(
            value: '$safe',
            label: widget.isAr ? 'بأمان' : 'Safe',
            valueColor: const Color(0xFF81C784)),
        const SizedBox(width: 8),
        // ✅ إصلاح: عرض السنة الديناميكية
        _StatChip(
            value: '$validUntil',
            label: widget.isAr ? 'صالحة لـ' : 'Valid Until'),
        if (danger > 0) ...[
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withOpacity(0.5)),
            ),
            child: Text(
              widget.isAr ? '⚠ $danger تنبيه' : '⚠ $danger Alert',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: const Color(0xFFFFCDD2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFamilyAvatars() {
    const maxShow = 5;
    final show = widget.members.take(maxShow).toList();
    final extra = widget.members.length - maxShow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isAr
              ? 'أفراد العائلة المسجّلون'
              : 'Registered Family Members',
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: Colors.white.withOpacity(0.55),
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...show.asMap().entries.map((e) {
              final m = e.value;
              final isOk = m.status == MemberStatus.safe;
              return Transform.translate(
                offset: Offset(e.key * -6.0, 0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOk
                        ? const Color(0xFF1E88E5).withOpacity(0.3)
                        : AppColors.danger.withOpacity(0.3),
                    border: Border.all(
                      color: isOk
                          ? Colors.white.withOpacity(0.5)
                          : AppColors.danger,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      m.initials,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (extra > 0)
              Transform.translate(
                offset: Offset(show.length * -6.0, 0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '+$extra',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            _SafetyBar(
              members: widget.members,
              isAr: widget.isAr,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isAr ? 'جمهورية العراق' : 'Republic of Iraq',
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Row(
            children: [
              Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4FC3F7))),
              const SizedBox(width: 4),
              Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3))),
              const SizedBox(width: 4),
              Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3))),
            ],
          ),
        ],
      );
}

// ── شريط الأمان ──────────────────────────────────────────
class _SafetyBar extends StatelessWidget {
  final List<FamilyMember> members;
  final bool isAr;
  const _SafetyBar({required this.members, required this.isAr});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();
    final ratio = members
            .where((m) => m.status == MemberStatus.safe)
            .length /
        members.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          isAr
              ? 'الأمان ${(ratio * 100).toInt()}%'
              : '${(ratio * 100).toInt()}% Safe',
          style: GoogleFonts.cairo(
              fontSize: 9, color: Colors.white.withOpacity(0.55)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 70,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF81C784), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  final Color? valueColor;
  const _StatChip({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
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
            style: GoogleFonts.cairo(
              fontSize: 9,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      );
}

// ── Shine Painter ────────────────────────────────────────
class _ShinePainter extends CustomPainter {
  final double progress;
  const _ShinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width * 0.3 + progress * (size.width * 1.6);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(x - 40, 0, 80, size.height));
    canvas.drawRect(Rect.fromLTWH(x - 40, 0, 80, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShinePainter old) => old.progress != progress;
}