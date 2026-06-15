// ════════════════════════════════════════════════════════
//  widgets/family/add_member_sheet.dart
//  شيت إضافة فرد جديد للعائلة مع سجله الطبي
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/family_member.dart';
import '../../../core/providers/family_provider.dart';
import '../../../core/theme/app_colors.dart';

class AddMemberSheet extends StatefulWidget {
  final bool isAr;
  final WidgetRef ref;

  const AddMemberSheet({super.key, required this.isAr, required this.ref});

  @override
  State<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<AddMemberSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _idCtrl    = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl   = TextEditingController();
  final _noteCtrl  = TextEditingController();

  FamilyRelation _relation  = FamilyRelation.son;
  BloodType      _bloodType = BloodType.oPos;
  bool           _isMale    = true;
  int            _step      = 0;

  final List<String> _chronicDiseases = [];
  final List<String> _allergies       = [];
  final List<String> _currentMeds     = [];

  final _diseaseCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();
  final _medCtrl     = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nameCtrl, _idCtrl, _phoneCtrl, _ageCtrl, _noteCtrl,
        _diseaseCtrl, _allergyCtrl, _medCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final age = int.tryParse(_ageCtrl.text) ?? 0;
    final member = FamilyMember(
      id:             DateTime.now().millisecondsSinceEpoch.toString(),
      nationalId:     _idCtrl.text.trim(),
      nameAr:         _nameCtrl.text.trim(),
      nameEn:         _nameCtrl.text.trim(),
      age:            age,
      isMale:         _isMale,
      relation:       _relation,
      bloodType:      _bloodType,
      phone:          _phoneCtrl.text.trim(),
      chronicDiseases: List.from(_chronicDiseases),
      allergies:       List.from(_allergies),
      currentMeds:     List.from(_currentMeds),
      emergencyNote:   _noteCtrl.text.isEmpty ? null : _noteCtrl.text.trim(),
      status:          MemberStatus.safe,
    );
    widget.ref.read(familyProvider.notifier).addMember(member);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _step == 0
                        ? (widget.isAr ? 'بيانات الفرد' : 'Personal Info')
                        : (widget.isAr ? 'السجل الطبي' : 'Medical Profile'),
                    style: GoogleFonts.cairo(
                      fontSize: 17, fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Row(
                  children: [0, 1].map((i) => Container(
                    width: i == _step ? 20 : 8,
                    height: 6,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: i == _step ? AppColors.primary : const Color(0xFFE0E7F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: _formKey,
                child: _step == 0 ? _buildStep1() : _buildStep2(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() => Column(
    children: [
      _Field(
        controller: _nameCtrl,
        label: widget.isAr ? 'الاسم الكامل' : 'Full Name',
        icon: Icons.person_rounded,
        isAr: widget.isAr,
        validator: (v) => (v?.isEmpty ?? true) ? (widget.isAr ? 'مطلوب' : 'Required') : null,
      ),
      const SizedBox(height: 12),

      _Field(
        controller: _idCtrl,
        label: widget.isAr ? 'رقم الهوية الوطنية' : 'National ID',
        icon: Icons.badge_rounded,
        isAr: widget.isAr,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
        validator: (v) => (v?.isEmpty ?? true) ? (widget.isAr ? 'مطلوب' : 'Required') : null,
      ),
      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: _Field(
              controller: _ageCtrl,
              label: widget.isAr ? 'العمر' : 'Age',
              icon: Icons.cake_rounded,
              isAr: widget.isAr,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              validator: (v) {
                final age = int.tryParse(v ?? '');
                if (age == null || age <= 0 || age > 120) return widget.isAr ? 'غير صحيح' : 'Invalid';
                return null;
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _GenderToggle(
              isMale: _isMale, isAr: widget.isAr,
              onChange: (v) => setState(() => _isMale = v),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      _RelationDropdown(
        value: _relation, isAr: widget.isAr,
        onChange: (v) => setState(() => _relation = v),
      ),
      const SizedBox(height: 12),

      _BloodTypeSelector(
        value: _bloodType, isAr: widget.isAr,
        onChange: (v) => setState(() => _bloodType = v),
      ),
      const SizedBox(height: 12),

      _Field(
        controller: _phoneCtrl,
        label: widget.isAr ? 'رقم الهاتف (اختياري)' : 'Phone (Optional)',
        icon: Icons.phone_rounded,
        isAr: widget.isAr,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 20),

      _PrimaryBtn(
        label: widget.isAr ? 'التالي: السجل الطبي' : 'Next: Medical Profile',
        icon: Icons.arrow_forward_rounded,
        onTap: () {
          if (_formKey.currentState!.validate()) {
            setState(() => _step = 1);
          }
        },
      ),
    ],
  );

  // ✅ تم التصحيح: تغيير icon من IconData إلى String (emoji)
  Widget _buildStep2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _TagInput(
        label: widget.isAr ? 'أمراض مزمنة (إن وجد)' : 'Chronic Diseases (if any)',
        icon: '❤️', // ✅ تغيير من IconData إلى String
        color: AppColors.danger,
        isAr: widget.isAr,
        controller: _diseaseCtrl,
        tags: _chronicDiseases,
        onAdd: () {
          if (_diseaseCtrl.text.isNotEmpty) {
            setState(() {
              _chronicDiseases.add(_diseaseCtrl.text.trim());
              _diseaseCtrl.clear();
            });
          }
        },
        onRemove: (i) => setState(() => _chronicDiseases.removeAt(i)),
      ),
      const SizedBox(height: 14),

      _TagInput(
        label: widget.isAr ? 'حساسيات' : 'Allergies',
        icon: '⚠️', // ✅ تغيير من IconData إلى String
        color: AppColors.warning,
        isAr: widget.isAr,
        controller: _allergyCtrl,
        tags: _allergies,
        onAdd: () {
          if (_allergyCtrl.text.isNotEmpty) {
            setState(() {
              _allergies.add(_allergyCtrl.text.trim());
              _allergyCtrl.clear();
            });
          }
        },
        onRemove: (i) => setState(() => _allergies.removeAt(i)),
      ),
      const SizedBox(height: 14),

      _TagInput(
        label: widget.isAr ? 'أدوية دائمة' : 'Regular Medications',
        icon: '💊', // ✅ تغيير من IconData إلى String
        color: AppColors.primary,
        isAr: widget.isAr,
        controller: _medCtrl,
        tags: _currentMeds,
        onAdd: () {
          if (_medCtrl.text.isNotEmpty) {
            setState(() {
              _currentMeds.add(_medCtrl.text.trim());
              _medCtrl.clear();
            });
          }
        },
        onRemove: (i) => setState(() => _currentMeds.removeAt(i)),
      ),
      const SizedBox(height: 14),

      _Field(
        controller: _noteCtrl,
        label: widget.isAr ? 'ملاحظة طوارئ مهمة (اختياري)' : 'Important Emergency Note (Optional)',
        icon: Icons.info_rounded,
        isAr: widget.isAr,
        maxLines: 2,
      ),
      const SizedBox(height: 20),

      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _step = 0),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: Text(widget.isAr ? 'رجوع' : 'Back',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _PrimaryBtn(
              label: widget.isAr ? 'حفظ الفرد' : 'Save Member',
              icon: Icons.save_rounded,
              onTap: _submit,
            ),
          ),
        ],
      ),
    ],
  );
}

// باقي الـ Sub-Widgets تبقى كما هي مع تحديث withOpacity → withValues
// ... (سيتم عرض التحديثات أدناه)

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isAr;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const _Field({
    required this.controller, required this.label,
    this.icon, required this.isAr,
    this.keyboardType, this.inputFormatters,
    this.validator, this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    maxLines: maxLines,
    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
    style: GoogleFonts.cairo(fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.textGray),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textGray) : null,
      filled: true, fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger)),
    ),
  );
}

class _GenderToggle extends StatelessWidget {
  final bool isMale, isAr;
  final ValueChanged<bool> onChange;
  const _GenderToggle({required this.isMale, required this.isAr, required this.onChange});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F9FF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFCFDAE8)),
    ),
    child: Row(
      children: [
        Expanded(child: _GBtn(label: isAr ? 'ذكر' : 'Male', active: isMale, onTap: () => onChange(true))),
        Expanded(child: _GBtn(label: isAr ? 'أنثى' : 'Female', active: !isMale, onTap: () => onChange(false))),
      ],
    ),
  );
}

class _GBtn extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _GBtn({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold,
          color: active ? Colors.white : AppColors.textGray)),
    ),
  );
}

class _RelationDropdown extends StatelessWidget {
  final FamilyRelation value; final bool isAr;
  final ValueChanged<FamilyRelation> onChange;
  const _RelationDropdown({required this.value, required this.isAr, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final items = FamilyRelation.values.map((r) {
      final dummy = FamilyMember(id:'', nationalId:'', nameAr:'', nameEn:'',
          age:0, isMale:true, relation:r, bloodType:BloodType.oPos, phone:'');
      return DropdownMenuItem<FamilyRelation>(
        value: r,
        child: Text(dummy.relationLabel(isAr),
          style: GoogleFonts.cairo(fontSize: 13)),
      );
    }).toList();

    return DropdownButtonFormField<FamilyRelation>(
      value: value,
      items: items,
      onChanged: (v) => v != null ? onChange(v) : null,
      decoration: InputDecoration(
        labelText: isAr ? 'صلة القرابة' : 'Relation',
        prefixIcon: const Icon(Icons.family_restroom_rounded, size: 18, color: AppColors.textGray),
        filled: true, fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

class _BloodTypeSelector extends StatelessWidget {
  final BloodType value; final bool isAr;
  final ValueChanged<BloodType> onChange;
  const _BloodTypeSelector({required this.value, required this.isAr, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const labels = {
      BloodType.aPos: 'A+', BloodType.aNeg: 'A−',
      BloodType.bPos: 'B+', BloodType.bNeg: 'B−',
      BloodType.abPos: 'AB+', BloodType.abNeg: 'AB−',
      BloodType.oPos: 'O+', BloodType.oNeg: 'O−',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isAr ? 'فصيلة الدم' : 'Blood Type',
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGray)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: BloodType.values.map((b) {
            final sel = b == value;
            return GestureDetector(
              onTap: () => onChange(b),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 50, height: 38,
                decoration: BoxDecoration(
                  color: sel ? AppColors.danger : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? AppColors.danger : const Color(0xFFE2E8F0),
                    width: sel ? 2 : 0.5,
                  ),
                ),
                child: Center(
                  child: Text(labels[b]!,
                    style: GoogleFonts.cairo(
                      fontSize: 13, fontWeight: FontWeight.bold,
                      color: sel ? Colors.white : AppColors.textGray,
                    )),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ✅ تم التصحيح: تغيير نوع icon من dynamic إلى String
class _TagInput extends StatelessWidget {
  final String label;
  final String icon; // ✅ تغيير من dynamic إلى String
  final Color color;
  final bool isAr;
  final TextEditingController controller;
  final List<String> tags;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _TagInput({
    required this.label,
    required this.icon, // ✅ الآن String
    required this.color,
    required this.isAr,
    required this.controller,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.cairo(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.cairo(fontSize: 13),
              onSubmitted: (_) => onAdd(),
              decoration: InputDecoration(
                hintText: isAr ? 'أضف وأضغط +' : 'Add and press +',
                hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.textHint),
                filled: true, fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: color.withValues(alpha: 0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: color.withValues(alpha: 0.2))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: color, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      if (tags.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: tags.asMap().entries.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.value, style: GoogleFonts.cairo(fontSize: 12, color: color)),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => onRemove(e.key),
                  child: Icon(Icons.close_rounded, size: 14, color: color),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    ],
  );
}

class _PrimaryBtn extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
  );
}