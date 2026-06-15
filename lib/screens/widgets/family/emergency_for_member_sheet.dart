// ════════════════════════════════════════════════════════
//  screens/widgets/family/emergency_for_member_sheet.dart
//  شيت طلب الطوارئ لفرد العائلة
//  يرسل معلومات المريض + مقدّم البلاغ تلقائياً
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/family_member.dart';
import '../../../core/providers/family_provider.dart';
import '../../../core/theme/app_colors.dart';

// أنواع حالات الطوارئ
const List<Map<String, String>> _emergencyTypes = [
  {'icon': '🚑', 'ar': 'إسعاف طبي عام', 'en': 'General Medical'},
  {'icon': '💓', 'ar': 'نوبة قلبية', 'en': 'Heart Attack'},
  {'icon': '🫁', 'ar': 'صعوبة التنفس/ربو', 'en': 'Breathing/Asthma'},
  {'icon': '🩸', 'ar': 'نزيف حاد', 'en': 'Severe Bleeding'},
  {'icon': '🧠', 'ar': 'إغماء/غيبوبة', 'en': 'Unconscious'},
  {'icon': '💊', 'ar': 'تسمم/جرعة زائدة', 'en': 'Poisoning'},
  {'icon': '🦴', 'ar': 'كسر/إصابة', 'en': 'Fracture/Injury'},
  {'icon': '🔥', 'ar': 'حروق', 'en': 'Burns'},
  {'icon': '⚡', 'ar': 'صعقة كهربائية', 'en': 'Electric Shock'},
  {'icon': '🚨', 'ar': 'طارئ آخر', 'en': 'Other Emergency'},
];

// ════════════════════════════════════════════════════════
//  EmergencySheet
// ════════════════════════════════════════════════════════
class EmergencySheet extends StatefulWidget {
  final FamilyMember patient;
  final WidgetRef ref;
  final bool isAr;

  const EmergencySheet({
    super.key,
    required this.patient,
    required this.ref,
    required this.isAr,
  });

  @override
  State<EmergencySheet> createState() => _EmergencySheetState();
}

class _EmergencySheetState extends State<EmergencySheet> {
  int _selectedType = 0;
  bool _isSending = false;
  bool _isSent = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _sendEmergency() async {
    setState(() => _isSending = true);

    final familyState = widget.ref.read(familyProvider);
    final members = familyState.members;
    final reporter = members.isNotEmpty ? members.first : widget.patient;

    // إنشاء بلاغ جديد
    final report = EmergencyReport(
      reportId: DateTime.now().millisecondsSinceEpoch.toString(),
      time: DateTime.now(),
      patient: widget.patient,
      reporter: reporter,
      emergencyType: widget.isAr
          ? _emergencyTypes[_selectedType]['ar']!
          : _emergencyTypes[_selectedType]['en']!,
      description: _descriptionController.text.isEmpty
          ? (widget.isAr ? 'بحاجة مساعدة طارئة' : 'Needs emergency help')
          : _descriptionController.text,
      location: _locationController.text.isEmpty
          ? widget.patient.lastLocation
          : _locationController.text,
      status: ReportStatus.dispatched,
    );

    // إضافة البلاغ (بدون await لأن الدالة void)
    widget.ref.read(familyProvider.notifier).addEmergencyReport(report);

    setState(() {
      _isSending = false;
      _isSent = true;
    });

    // إغلاق الشيت بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: _isSent ? _buildSentView() : _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isAr ? '✓ تم إرسال البلاغ!' : '✓ Report Sent!',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isAr
                ? 'الإسعاف في الطريق إلى ${widget.patient.nameAr}'
                : 'Ambulance heading to ${widget.patient.nameEn}',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isAr ? '✓ تم إشعار جميع أفراد العائلة' : '✓ All family members notified',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final patient = widget.patient;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.danger,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.isAr ? '🚨 طلب إسعاف لفرد العائلة' : '🚨 Request Ambulance',
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // بطاقة المريض
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        patient.initials,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isAr ? patient.nameAr : patient.nameEn,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF791F1F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.relationLabel(widget.isAr)} · ${patient.age} ${widget.isAr ? "سنة" : "yrs"}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      patient.bloodLabel(),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (patient.emergencyNote != null ||
                  patient.chronicDiseases.isNotEmpty ||
                  patient.allergies.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (patient.emergencyNote != null)
                        _buildMedicalInfoTag('⚠️ ', patient.emergencyNote!),
                      if (patient.chronicDiseases.isNotEmpty)
                        _buildMedicalInfoTag('💊 ', patient.chronicDiseases.join(' · ')),
                      if (patient.allergies.isNotEmpty)
                        _buildMedicalInfoTag('🚫 ', patient.allergies.join(' · ')),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // عنوان قسم نوع الطارئ
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.isAr ? 'نوع الحالة الطارئة' : 'Emergency Type',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // شبكة أنواع الطوارئ
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _emergencyTypes.length,
          itemBuilder: (context, index) {
            final type = _emergencyTypes[index];
            final isSelected = _selectedType == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedType = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.danger.withValues(alpha: 0.1)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.danger : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(type['icon']!, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.isAr ? type['ar']! : type['en']!,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.danger : AppColors.textGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // حقل الملاحظة
        _buildTextField(
          controller: _descriptionController,
          hint: widget.isAr ? 'ملاحظة إضافية (اختياري)' : 'Additional note (optional)',
          icon: Icons.edit_note_rounded,
          maxLines: 2,
        ),
        const SizedBox(height: 12),

        // حقل الموقع
        _buildTextField(
          controller: _locationController,
          hint: widget.isAr
              ? 'الموقع: ${patient.lastLocation ?? "أدخل الموقع"}'
              : 'Location: ${patient.lastLocation ?? "Enter location"}',
          icon: Icons.location_on_rounded,
        ),
        const SizedBox(height: 24),

        // زر الإرسال
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendEmergency,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSending
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.isAr ? 'جاري الإرسال...' : 'Sending...',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_hospital_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        widget.isAr ? 'إرسال طلب الإسعاف الآن' : 'Send Ambulance Request',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            widget.isAr
                ? 'سيتلقى جميع أفراد العائلة إشعاراً فورياً'
                : 'All family members will be instantly notified',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: AppColors.textGray,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.cairo(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(
          fontSize: 12,
          color: AppColors.textHint,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primary, size: 18)
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMedicalInfoTag(String prefix, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '$prefix$text',
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: const Color(0xFF791F1F),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}