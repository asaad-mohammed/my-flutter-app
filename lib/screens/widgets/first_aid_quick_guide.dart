// ════════════════════════════════════════════════════════
//  widgets/first_aid_quick_guide.dart
//  ✅ ميزة جديدة: دليل الإسعافات الأولية السريع
//  بطاقات تفاعلية مع خطوات مصورة
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class FirstAidGuideCard extends StatefulWidget {
  final bool isAr;
  final String title, icon;
  final List<String> steps;
  final Color color;
  final bool isUrgent;

  const FirstAidGuideCard({
    super.key,
    required this.isAr,
    required this.title,
    required this.icon,
    required this.steps,
    required this.color,
    this.isUrgent = false,
  });

  @override
  State<FirstAidGuideCard> createState() => _FirstAidGuideCardState();
}

class _FirstAidGuideCardState extends State<FirstAidGuideCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isUrgent
              ? widget.color.withOpacity(0.3)
              : const Color(0xFFE8EDF4),
          width: widget.isUrgent ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── رأس البطاقة ──
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
              _expanded ? _ctrl.forward() : _ctrl.reverse();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(widget.icon,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        widget.isAr
                            ? '${widget.steps.length} خطوات'
                            : '${widget.steps.length} steps',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
                if (widget.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.isAr ? 'عاجل' : 'Urgent',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _rotate,
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textGray, size: 22),
                ),
              ]),
            ),
          ),

          // ── الخطوات ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSteps(),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps() => Container(
        padding:
            const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Column(
          children: [
            Container(height: 1, color: const Color(0xFFEEF2F7)),
            const SizedBox(height: 12),
            ...widget.steps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: AppColors.textDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════
//  FirstAidGuideList — قائمة أدلة الإسعافات الأولية
// ════════════════════════════════════════════════════════
class FirstAidGuideList extends StatelessWidget {
  final bool isAr;
  const FirstAidGuideList({super.key, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final guides = _getGuides(isAr);
    return Column(
      children: guides
          .map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FirstAidGuideCard(
                  isAr: isAr,
                  title: g['title'] as String,
                  icon: g['icon'] as String,
                  steps: g['steps'] as List<String>,
                  color: g['color'] as Color,
                  isUrgent: (g['urgent'] as bool?) ?? false,
                ),
              ))
          .toList(),
    );
  }

  List<Map<String, dynamic>> _getGuides(bool isAr) {
    return [
      {
        'title': isAr ? 'إنعاش القلب والرئة (CPR)' : 'CPR - Cardiac Arrest',
        'icon': '💗',
        'color': const Color(0xFFE53935),
        'urgent': true,
        'steps': isAr
            ? [
                'تأكد من سلامة المكان واستجابة المريض',
                'اتصل بالإسعاف فوراً (122)',
                'ضع كفيك على مركز الصدر',
                'اضغط بعمق 5 سم بمعدل 100-120/دقيقة',
                'أعطِ نفسَيْن اصطناعيين كل 30 ضغطة',
                'استمر حتى وصول الإسعاف',
              ]
            : [
                'Check scene safety and victim response',
                'Call emergency services immediately (122)',
                'Place both hands on center of chest',
                'Push down 2 inches at 100-120 per minute',
                'Give 2 rescue breaths every 30 compressions',
                'Continue until help arrives',
              ],
      },
      {
        'title': isAr ? 'الاختناق - عائق في الحلق' : 'Choking',
        'icon': '🫁',
        'color': const Color(0xFFE65100),
        'urgent': true,
        'steps': isAr
            ? [
                'اسأل الشخص إذا كان يختنق',
                'شجعه على السعال بقوة',
                'أعطِه 5 ضربات قوية على الظهر',
                'طبق 5 ضغطات عبدية (مناورة هيملش)',
                'كرر الضربات والضغطات حتى يخرج العائق',
                'إذا فقد الوعي ابدأ CPR',
              ]
            : [
                'Ask if the person is choking',
                'Encourage them to cough forcefully',
                'Give 5 sharp back blows',
                'Apply 5 abdominal thrusts (Heimlich)',
                'Alternate blows and thrusts until resolved',
                'If unconscious, begin CPR',
              ],
      },
      {
        'title': isAr ? 'النزيف الحاد' : 'Severe Bleeding',
        'icon': '🩸',
        'color': const Color(0xFFC62828),
        'steps': isAr
            ? [
                'ارتدِ قفازات إن وُجدت',
                'اضغط على الجرح بقماش نظيف بقوة',
                'حافظ على الضغط المستمر 10-15 دقيقة',
                'لا ترفع القماش لفحص الجرح',
                'إذا نفذ الدم أضف المزيد بدون رفع الأول',
                'ارفع العضو المصاب فوق مستوى القلب',
              ]
            : [
                'Wear gloves if available',
                'Apply firm pressure with clean cloth',
                'Maintain constant pressure 10-15 minutes',
                'Do not remove cloth to inspect wound',
                'If soaked through, add more cloth on top',
                'Elevate injured limb above heart level',
              ],
      },
      {
        'title': isAr ? 'الحروق' : 'Burns',
        'icon': '🔥',
        'color': const Color(0xFFFF6F00),
        'steps': isAr
            ? [
                'أبعد المصاب عن مصدر الحرق',
                'برّد الحرق بماء بارد 10-20 دقيقة',
                'لا تستخدم الثلج أو الزيت أو المعجون',
                'أزل المجوهرات والملابس بعيداً عن الحرق',
                'غطِّ الحرق بضمادة معقمة أو طازجة',
                'اطلب إسعافاً للحروق الكبيرة أو العميقة',
              ]
            : [
                'Remove person from burn source',
                'Cool burn with cold water 10-20 minutes',
                'Do NOT use ice, oil or toothpaste',
                'Remove jewelry and clothing near burn',
                'Cover with sterile or clean bandage',
                'Seek medical help for large or deep burns',
              ],
      },
      {
        'title': isAr ? 'ضربة الشمس / الإغماء' : 'Heat Stroke / Fainting',
        'icon': '🌡️',
        'color': const Color(0xFFF9A825),
        'steps': isAr
            ? [
                'أنقل الشخص إلى مكان بارد ومظلل',
                'أخلع الملابس الزائدة',
                'ضع ثلجاً أو ماء بارداً على الرقبة والإبطين',
                'أعطِه ماء بارداً إذا كان واعياً',
                'رفع قدميه 30 سم إذا أُغمي عليه',
                'اتصل بالإسعاف إذا لم يتحسن',
              ]
            : [
                'Move to cool, shaded area',
                'Remove excess clothing',
                'Apply ice or cold water to neck and armpits',
                'Give cool water if conscious',
                'Raise legs 12 inches if fainted',
                'Call ambulance if no improvement',
              ],
      },
    ];
  }
}