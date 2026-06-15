// ════════════════════════════════════════════════════════
//  screens/widgets/family/family_card_widget.dart
//  بطاقة فرد العائلة مع تفاصيل السجل الطبي
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/family_member.dart';
import '../../../core/theme/app_colors.dart';

// ════════════════════════════════════════════════════════
//  FamilyCardWidget
// ════════════════════════════════════════════════════════
class FamilyCardWidget extends StatefulWidget {
  final FamilyMember member;
  final bool isAr;
  final VoidCallback onSOS;
  final VoidCallback onSafe;
  final VoidCallback onProfile;

  const FamilyCardWidget({
    super.key,
    required this.member,
    required this.isAr,
    required this.onSOS,
    required this.onSafe,
    required this.onProfile,
  });

  @override
  State<FamilyCardWidget> createState() => _FamilyCardWidgetState();
}

class _FamilyCardWidgetState extends State<FamilyCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  // ألوان الحالة
  Color get _statusColor {
    switch (widget.member.status) {
      case MemberStatus.safe:
        return const Color(0xFF2E7D32);
      case MemberStatus.unknown:
        return const Color(0xFFF57F17);
      case MemberStatus.danger:
        return AppColors.danger;
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

  static const List<Color> _avatarColors = [
    Color(0xFFB5D4F4), Color(0xFFC0DD97), Color(0xFFFFCDD2),
    Color(0xFFE1BEE7), Color(0xFFB2EBF2), Color(0xFFFFE082),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final isSOS = member.status == MemberStatus.sos || member.status == MemberStatus.danger;
    final avatarColor = _avatarColors[member.id.hashCode.abs() % _avatarColors.length];

    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isSOS ? const Color(0xFFFCEBEB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSOS 
                ? AppColors.danger.withValues(alpha: 0.45) 
                : const Color(0xFFE8EDF4),
            width: isSOS ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSOS 
                  ? AppColors.danger.withValues(alpha: 0.1) 
                  : const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // الصف الرئيسي
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // أفاتار الفرد
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                      border: isSOS 
                          ? Border.all(color: AppColors.danger, width: 2) 
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        member.initials,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A2332),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // بيانات الفرد
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.isAr ? member.nameAr : member.nameEn,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSOS ? AppColors.danger : AppColors.textDark,
                              ),
                            ),
                            if (member.isChild) ...[
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
                          '${member.relationLabel(widget.isAr)} · ${member.age} ${widget.isAr ? "سنة" : "yrs"} · ${member.bloodLabel()}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 3),

                        // حالة الفرد
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _statusColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _statusLabel,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _statusColor,
                              ),
                            ),
                            if (member.lastLocation != null) ...[
                              Text(
                                ' · ',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: AppColors.textGray,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  member.lastLocation!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: AppColors.textGray,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // ملاحظة طبية مهمة
                        if (member.emergencyNote != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 11,
                                color: Color(0xFFF57F17),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  member.emergencyNote!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color: const Color(0xFFF57F17),
                                    height: 1.3,
                                  ),
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
                      // زر SOS
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
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // زر التوسيع
                      RotationTransition(
                        turns: _rotationAnimation,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textGray,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // تفاصيل موسعة
            if (_isExpanded) 
              _ExpandedDetailsWidget(
                member: member,
                isAr: widget.isAr,
                onProfile: widget.onProfile,
                onSafe: widget.onSafe,
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  ExpandedDetailsWidget - التفاصيل الموسعة
// ════════════════════════════════════════════════════════
class _ExpandedDetailsWidget extends StatelessWidget {
  final FamilyMember member;
  final bool isAr;
  final VoidCallback onProfile;
  final VoidCallback onSafe;

  const _ExpandedDetailsWidget({
    required this.member,
    required this.isAr,
    required this.onProfile,
    required this.onSafe,
  });

  @override
  Widget build(BuildContext context) {
    final hasMedicalInfo = member.chronicDiseases.isNotEmpty ||
        member.allergies.isNotEmpty ||
        member.currentMeds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          // معلومات طبية مختصرة
          if (hasMedicalInfo)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (member.chronicDiseases.isNotEmpty)
                    _MedicalInfoRow(
                      icon: Icons.monitor_heart_rounded,
                      color: AppColors.danger,
                      label: isAr ? 'أمراض مزمنة' : 'Chronic Diseases',
                      value: member.chronicDiseases.join(' · '),
                    ),
                  if (member.allergies.isNotEmpty)
                    _MedicalInfoRow(
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      label: isAr ? 'حساسيات' : 'Allergies',
                      value: member.allergies.join(' · '),
                    ),
                  if (member.currentMeds.isNotEmpty)
                    _MedicalInfoRow(
                      icon: Icons.medication_rounded,
                      color: AppColors.primary,
                      label: isAr ? 'أدوية' : 'Meds',
                      value: member.currentMeds.join(' · '),
                    ),
                ],
              ),
            ),

          // أزرار التحكم
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onProfile,
                  icon: const Icon(Icons.person_rounded, size: 15),
                  label: Text(
                    isAr ? 'الملف الكامل' : 'Full Profile',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

// ════════════════════════════════════════════════════════
//  MedicalInfoRow - صف المعلومات الطبية
// ════════════════════════════════════════════════════════
class _MedicalInfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _MedicalInfoRow({
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
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppColors.textGray,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}