// ════════════════════════════════════════════════════════
//  tabs/first_aid_tab.dart
//  تبويب دليل الإسعافات الأولية
//  ✅ صور SVG توضيحية مدمجة (لا تحتاج assets خارجية)
//  ✅ خطوات تفصيلية مُرقّمة
//  ✅ شريط بحث
//  ✅ تصنيفات ملوّنة
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';

// ════════════════════════════════════════════════════════
//  نموذج خطوة الإسعاف
// ════════════════════════════════════════════════════════
class _Step {
  final String ar, en;
  final IconData icon;
  const _Step({required this.ar, required this.en, required this.icon});
}

// ════════════════════════════════════════════════════════
//  نموذج حالة طارئة
// ════════════════════════════════════════════════════════
class _Case {
  final String titleAr, titleEn, descAr, descEn, categoryAr, categoryEn;
  final Color color;
  final IconData icon;
  final List<_Step> steps;
  final _IllustrationType illustration;

  const _Case({
    required this.titleAr, required this.titleEn,
    required this.descAr,  required this.descEn,
    required this.categoryAr, required this.categoryEn,
    required this.color, required this.icon,
    required this.steps, required this.illustration,
  });
}

enum _IllustrationType { cpr, bleeding, burn, choking, fracture, fainting, snake, drowning }

// ════════════════════════════════════════════════════════
//  بيانات الحالات الطارئة
// ════════════════════════════════════════════════════════
const List<_Case> _cases = [
  _Case(
    titleAr: 'الإنعاش القلبي الرئوي (CPR)',
    titleEn: 'Cardiopulmonary Resuscitation (CPR)',
    descAr: 'تقنية إنقاذ الحياة عند توقف القلب والتنفس',
    descEn: 'Life-saving technique when heart and breathing stop',
    categoryAr: 'توقف القلب', categoryEn: 'Cardiac Arrest',
    color: Color(0xFFE53935), icon: Icons.favorite_rounded,
    illustration: _IllustrationType.cpr,
    steps: [
      _Step(ar:'تأكد من سلامة المكان ومن أن الضحية لا تستجيب',en:'Ensure scene safety and check responsiveness',icon:Icons.safety_check_rounded),
      _Step(ar:'اتصل بالإسعاف على 911 فوراً',en:'Call 911 immediately',icon:Icons.phone_rounded),
      _Step(ar:'ضع يديك على منتصف الصدر وابدأ ضغطات قوية (100-120 ضغطة/دقيقة)',en:'Place hands on center of chest, push hard (100-120/min)',icon:Icons.compress_rounded),
      _Step(ar:'اضغط بعمق 5-6 سم مع السماح للصدر بالارتداد الكامل',en:'Push 5-6 cm deep, allow full chest recoil',icon:Icons.height_rounded),
      _Step(ar:'بعد 30 ضغطة: أعطِ نفسَين صناعيَّين (إن كنت مُدرَّباً)',en:'After 30 compressions: give 2 rescue breaths (if trained)',icon:Icons.air_rounded),
      _Step(ar:'استمر حتى وصول المسعفين أو استعادة النبض',en:'Continue until paramedics arrive or pulse returns',icon:Icons.loop_rounded),
    ],
  ),
  _Case(
    titleAr: 'النزيف الشديد',
    titleEn: 'Severe Bleeding',
    descAr: 'وقف النزيف الخارجي الغزير وحماية حياة المصاب',
    descEn: 'Stop heavy external bleeding and protect victim\'s life',
    categoryAr: 'نزيف', categoryEn: 'Bleeding',
    color: Color(0xFFC62828), icon: Icons.bloodtype_rounded,
    illustration: _IllustrationType.bleeding,
    steps: [
      _Step(ar:'ارتدِ قفازات إن أمكن لحماية نفسك',en:'Wear gloves if available to protect yourself',icon:Icons.back_hand_rounded),
      _Step(ar:'اضغط على الجرح بقماش نظيف أو ضمادة بشكل مستمر',en:'Apply continuous pressure with clean cloth or bandage',icon:Icons.compress_rounded),
      _Step(ar:'لا تزل الضمادة حتى لو ابتلّت — أضف طبقة فوقها',en:'Don\'t remove bandage if soaked — add another layer',icon:Icons.layers_rounded),
      _Step(ar:'ارفع الطرف المصاب فوق مستوى القلب إن أمكن',en:'Elevate injured limb above heart level if possible',icon:Icons.arrow_upward_rounded),
      _Step(ar:'استخدم رباطاً ضاغطاً فوق الجرح 5 سم إن استمر النزيف',en:'Apply tourniquet 5cm above wound if bleeding continues',icon:Icons.healing_rounded),
      _Step(ar:'اتصل بالإسعاف فوراً واحتفظ بهدوء المصاب',en:'Call ambulance immediately and keep victim calm',icon:Icons.phone_rounded),
    ],
  ),
  _Case(
    titleAr: 'الحروق',
    titleEn: 'Burns',
    descAr: 'معالجة الحروق الحرارية والكيميائية بشكل صحيح',
    descEn: 'Treat thermal and chemical burns correctly',
    categoryAr: 'حرق', categoryEn: 'Burn',
    color: Color(0xFFE65100), icon: Icons.local_fire_department_rounded,
    illustration: _IllustrationType.burn,
    steps: [
      _Step(ar:'ابعد المصاب فوراً عن مصدر الحرارة أو المادة الكيميائية',en:'Remove victim from heat source or chemical immediately',icon:Icons.exit_to_app_rounded),
      _Step(ar:'بَرِّد الحرق بماء بارد (ليس متجمداً) لمدة 20 دقيقة',en:'Cool burn with cold (not ice) water for 20 minutes',icon:Icons.water_drop_rounded),
      _Step(ar:'لا تستخدم جليداً أو زبداً أو معجون أسنان',en:'Do NOT use ice, butter, or toothpaste',icon:Icons.do_not_disturb_rounded),
      _Step(ar:'غطِّ الحرق بضمادة معقمة أو قماش نظيف',en:'Cover burn with sterile dressing or clean cloth',icon:Icons.medical_services_rounded),
      _Step(ar:'في الحروق الكيميائية: اشطف بكميات كبيرة من الماء',en:'For chemical burns: flush with large amounts of water',icon:Icons.shower_rounded),
      _Step(ar:'اطلب الإسعاف إذا تجاوز الحرق راحة اليد أو كان في الوجه',en:'Call ambulance if burn exceeds palm size or involves face',icon:Icons.phone_rounded),
    ],
  ),
  _Case(
    titleAr: 'الاختناق',
    titleEn: 'Choking',
    descAr: 'إخراج جسم غريب من مجرى الهواء بسرعة',
    descEn: 'Remove foreign object from airway quickly',
    categoryAr: 'اختناق', categoryEn: 'Choking',
    color: Color(0xFF6A1B9A), icon: Icons.air_rounded,
    illustration: _IllustrationType.choking,
    steps: [
      _Step(ar:'اسأل: "هل تختنق؟" — إذا كان يسعل قوياً شجّعه على الاستمرار',en:'Ask: "Are you choking?" — if coughing strongly, encourage it',icon:Icons.help_rounded),
      _Step(ar:'اطلب منه الإمالة للأمام وأعطه 5 ضربات قوية بين لوحَي الكتف',en:'Lean them forward, give 5 firm back blows between shoulder blades',icon:Icons.back_hand_rounded),
      _Step(ar:'إن لم يُجدِ: قف خلفه وضع يديك أسفل الصدر (مناورة هيمليك)',en:'If no result: stand behind, place hands below chest (Heimlich maneuver)',icon:Icons.person_rounded),
      _Step(ar:'اضغط للداخل والأعلى بقوة 5 مرات متتالية',en:'Pull inward and upward firmly 5 times',icon:Icons.compress_rounded),
      _Step(ar:'بادل بين 5 ضربات ظهرية و5 ضغطات بطنية حتى تحرر الجسم',en:'Alternate 5 back blows and 5 abdominal thrusts until cleared',icon:Icons.loop_rounded),
      _Step(ar:'إذا فقد الوعي: ابدأ الإنعاش القلبي وادعُ الإسعاف',en:'If unconscious: start CPR and call ambulance',icon:Icons.emergency_rounded),
    ],
  ),
  _Case(
    titleAr: 'الكسور',
    titleEn: 'Fractures',
    descAr: 'تثبيت الكسور وتقليل الألم قبل وصول المسعفين',
    descEn: 'Immobilize fractures and reduce pain before paramedics arrive',
    categoryAr: 'كسور', categoryEn: 'Fracture',
    color: Color(0xFF1565C0), icon: Icons.accessibility_new_rounded,
    illustration: _IllustrationType.fracture,
    steps: [
      _Step(ar:'لا تحرّك المصاب إذا اشتبهت بإصابة في العمود الفقري',en:'Don\'t move victim if spinal injury is suspected',icon:Icons.do_not_disturb_rounded),
      _Step(ar:'ثبّت الكسر بجبيرة مؤقتة (عصا + قماش) دون تقويم',en:'Splint fracture (stick + cloth) without straightening',icon:Icons.healing_rounded),
      _Step(ar:'ضع كيس ثلج ملفوفاً بقماش لتخفيف التورم',en:'Apply ice bag wrapped in cloth to reduce swelling',icon:Icons.ac_unit_rounded),
      _Step(ar:'ارفع الطرف المصاب فوق مستوى القلب إن أمكن',en:'Elevate injured limb above heart level if possible',icon:Icons.arrow_upward_rounded),
      _Step(ar:'راقب علامات ضعف الدورة الدموية (تنميل، برود، شحوب)',en:'Watch for circulation loss signs (numbness, coldness, pallor)',icon:Icons.visibility_rounded),
      _Step(ar:'اتصل بالإسعاف لنقل المصاب بشكل آمن',en:'Call ambulance for safe transport',icon:Icons.phone_rounded),
    ],
  ),
  _Case(
    titleAr: 'الإغماء والفقدان الوعي',
    titleEn: 'Fainting & Loss of Consciousness',
    descAr: 'التعامل مع الشخص الفاقد الوعي أو على وشك الإغماء',
    descEn: 'Handling unconscious person or someone about to faint',
    categoryAr: 'إغماء', categoryEn: 'Fainting',
    color: Color(0xFF00838F), icon: Icons.person_off_rounded,
    illustration: _IllustrationType.fainting,
    steps: [
      _Step(ar:'أجلسه أو أضجعه على الفور لمنع السقوط والإصابة',en:'Sit or lay them down immediately to prevent fall injury',icon:Icons.airline_seat_flat_rounded),
      _Step(ar:'ارفع قدميه 30 سم فوق مستوى الجسم لتحسين تدفق الدم',en:'Raise legs 30cm above body level to improve blood flow',icon:Icons.arrow_upward_rounded),
      _Step(ar:'فكّ أي ملابس ضيقة حول الرقبة والصدر',en:'Loosen any tight clothing around neck and chest',icon:Icons.checkroom_rounded),
      _Step(ar:'تحقق من التنفس والنبض باستمرار',en:'Continuously check breathing and pulse',icon:Icons.monitor_heart_rounded),
      _Step(ar:'إذا لم يستعد وعيه خلال دقيقتين: ابدأ الإنعاش',en:'If no recovery within 2 minutes: start CPR',icon:Icons.loop_rounded),
      _Step(ar:'ضعه بوضع الإفاقة (جانبياً) إن كان يتقيأ',en:'Place in recovery position (on side) if vomiting',icon:Icons.rotate_right_rounded),
    ],
  ),
  _Case(
    titleAr: 'لدغة الثعبان والحشرات',
    titleEn: 'Snake & Insect Bites',
    descAr: 'الإسعاف الفوري للسعات والعضات السامة',
    descEn: 'Immediate first aid for venomous bites and stings',
    categoryAr: 'لدغات', categoryEn: 'Bites',
    color: Color(0xFF2E7D32), icon: Icons.pest_control_rounded,
    illustration: _IllustrationType.snake,
    steps: [
      _Step(ar:'ابتعد عن الحيوان وحافظ على هدوء المصاب تماماً',en:'Move away from animal, keep victim completely calm',icon:Icons.move_down_rounded),
      _Step(ar:'لا تضغط على مكان اللدغة ولا تقطعه ولا تمصّه',en:'Do NOT cut, squeeze, or suck the bite site',icon:Icons.do_not_disturb_rounded),
      _Step(ar:'ثبّت الطرف المصاب أسفل مستوى القلب',en:'Immobilize limb below heart level',icon:Icons.arrow_downward_rounded),
      _Step(ar:'انزع المجوهرات والساعات قرب مكان اللدغة',en:'Remove jewelry and watches near bite site',icon:Icons.watch_off_rounded),
      _Step(ar:'لا تعطِ مضادات الهيستامين بدون وصفة طبية للثعابين',en:'Do NOT give antihistamines without prescription for snakes',icon:Icons.medication_rounded),
      _Step(ar:'اتصل بالإسعاف أو المستشفى فوراً مع وصف الحيوان',en:'Call ambulance or hospital immediately, describe the animal',icon:Icons.phone_rounded),
    ],
  ),
  _Case(
    titleAr: 'الغرق والإنقاذ المائي',
    titleEn: 'Drowning & Water Rescue',
    descAr: 'إنقاذ الغريق وإسعافه على أرض صلبة',
    descEn: 'Rescue drowning victim and provide first aid on solid ground',
    categoryAr: 'غرق', categoryEn: 'Drowning',
    color: Color(0xFF0277BD), icon: Icons.pool_rounded,
    illustration: _IllustrationType.drowning,
    steps: [
      _Step(ar:'لا تقفز في الماء إلا إن كنت مدرّباً — استخدم حبلاً أو عوامة',en:'Don\'t jump in water unless trained — use rope or float',icon:Icons.safety_check_rounded),
      _Step(ar:'اسحب الضحية للأرض بأسرع وقت ممكن',en:'Pull victim to solid ground as quickly as possible',icon:Icons.move_up_rounded),
      _Step(ar:'تحقق من الاستجابة والتنفس فور الإخراج من الماء',en:'Check responsiveness and breathing immediately upon removal',icon:Icons.monitor_heart_rounded),
      _Step(ar:'ابدأ الإنعاش القلبي الرئوي فوراً إذا لم يكن يتنفس',en:'Start CPR immediately if not breathing',icon:Icons.favorite_rounded),
      _Step(ar:'لا تضيع الوقت في إخراج الماء من رئتيه',en:'Do NOT waste time trying to empty water from lungs',icon:Icons.timer_off_rounded),
      _Step(ar:'غطِّه بملابس دافئة لمنع انخفاض الحرارة',en:'Cover with warm clothing to prevent hypothermia',icon:Icons.thermostat_rounded),
    ],
  ),
];

// ════════════════════════════════════════════════════════
//  FirstAidTab
// ════════════════════════════════════════════════════════
class FirstAidTab extends ConsumerStatefulWidget {
  const FirstAidTab({super.key});
  @override
  ConsumerState<FirstAidTab> createState() => _FirstAidTabState();
}

class _FirstAidTabState extends ConsumerState<FirstAidTab> {
  String _search = '';
  String? _activeCategory;

  List<_Case> get _filtered {
    var list = _cases;
    if (_activeCategory != null) {
      list = list.where((c) => c.categoryAr == _activeCategory).toList();
    }
    if (_search.isNotEmpty) {
      list = list.where((c) =>
        c.titleAr.contains(_search) ||
        c.titleEn.toLowerCase().contains(_search.toLowerCase()) ||
        c.descAr.contains(_search)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── هيدر ──
            SliverToBoxAdapter(child: _buildHeader(isAr)),

            // ── شريط البحث ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _SearchBar(
                  isAr: isAr,
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
            ),

            // ── تصنيفات ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: _CategoryFilter(
                  isAr: isAr,
                  active: _activeCategory,
                  onSelect: (c) => setState(() =>
                    _activeCategory = _activeCategory == c ? null : c),
                ),
              ),
            ),

            // ── عدد النتائج ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  isAr
                    ? '${_filtered.length} حالة طارئة'
                    : '${_filtered.length} emergency cases',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // ── قائمة الحالات ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CaseCard(
                        caseData: _filtered[i], isAr: isAr),
                  ),
                  childCount: _filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr) => Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16, right: 16, bottom: 16,
    ),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFEF5350)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Row(children: [
      Container(width:42,height:42,
        decoration:BoxDecoration(color:Colors.white.withOpacity(.2),
          borderRadius:BorderRadius.circular(12)),
        child:const Icon(Icons.medical_services_rounded,
          color:Colors.white,size:22)),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,
        children:[
          Text(isAr?'دليل الإسعافات الأولية':'First Aid Guide',
            style:GoogleFonts.cairo(fontSize:18,fontWeight:FontWeight.w900,
              color:Colors.white)),
          Text(isAr?'تعلّم كيف تنقذ حياة في لحظات حرجة'
            :'Learn to save lives in critical moments',
            style:GoogleFonts.cairo(fontSize:11,color:Colors.white70)),
        ])),
      Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),
        decoration:BoxDecoration(color:Colors.white.withOpacity(.2),
          borderRadius:BorderRadius.circular(16)),
        child:Text('${_cases.length}',style:GoogleFonts.cairo(
          fontSize:16,fontWeight:FontWeight.w900,color:Colors.white))),
    ]),
  );
}

// ════════════════════════════════════════════════════════
//  _SearchBar
// ════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final bool isAr;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.isAr, required this.onChanged});

  @override
  Widget build(BuildContext c) => Container(
    height: 46,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color:Color(0x0F000000),blurRadius:8,offset:Offset(0,2))],
    ),
    child: TextField(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      onChanged: onChanged,
      style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: isAr ? 'ابحث عن حالة طارئة...' : 'Search emergency case...',
        hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.textHint),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textGray, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════
//  _CategoryFilter
// ════════════════════════════════════════════════════════
class _CategoryFilter extends StatelessWidget {
  final bool isAr;
  final String? active;
  final ValueChanged<String> onSelect;
  const _CategoryFilter({required this.isAr, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext c) {
    final cats = _cases.map((c) => (ar: c.categoryAr, en: c.categoryEn, col: c.color)).toSet().toList();
    return SizedBox(height: 40, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cats.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final cat = cats[i];
        final isSel = active == cat.ar;
        return GestureDetector(
          onTap: () => onSelect(cat.ar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSel ? cat.col : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cat.col.withOpacity(0.4)),
              boxShadow: [BoxShadow(
                color: isSel ? cat.col.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: 6, offset: const Offset(0,2))],
            ),
            child: Text(isAr ? cat.ar : cat.en,
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                color: isSel ? Colors.white : AppColors.textDark)),
          ),
        );
      },
    ));
  }
}

// ════════════════════════════════════════════════════════
//  _CaseCard — بطاقة الحالة القابلة للتوسع
// ════════════════════════════════════════════════════════
class _CaseCard extends StatefulWidget {
  final _Case caseData;
  final bool isAr;
  const _CaseCard({required this.caseData, required this.isAr});
  @override State<_CaseCard> createState() => _CaseCardState();
}

class _CaseCardState extends State<_CaseCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 350));
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext c) {
    final d = widget.caseData;
    final isAr = widget.isAr;
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color:Color(0x0E000000),blurRadius:12,offset:Offset(0,3))],
        ),
        child: Column(children: [
          // ── رأس البطاقة ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [d.color, d.color.withOpacity(0.75)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(20),
                bottom: _expanded
                    ? Radius.zero
                    : const Radius.circular(20),
              ),
            ),
            child: Row(children: [
              // رسم توضيحي SVG صغير
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomPaint(
                    painter: _IllustrationPainter(
                        type: d.illustration, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isAr ? d.titleAr : d.titleEn,
                    style: GoogleFonts.cairo(fontSize: 14,
                        fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(isAr ? d.descAr : d.descEn,
                    style: GoogleFonts.cairo(fontSize: 11,
                        color: Colors.white70, height: 1.3)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal:8,vertical:3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(isAr ? d.categoryAr : d.categoryEn,
                        style: GoogleFonts.cairo(fontSize:10,
                            color:Colors.white,fontWeight:FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text('${d.steps.length} ${isAr?"خطوة":"steps"}',
                      style: GoogleFonts.cairo(fontSize:10,color:Colors.white70)),
                  ]),
                ],
              )),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.expand_more_rounded,
                      color: Colors.white, size: 18)),
              ),
            ]),
          ),

          // ── المحتوى الموسّع ──
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(children: [
                // الرسم التوضيحي الكبير
                Container(
                  height: 160,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: d.color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: d.color.withOpacity(0.15)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: _IllustrationPainter(
                          type: d.illustration, color: d.color, large: true),
                    ),
                  ),
                ),

                // الخطوات
                ...d.steps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رقم الخطوة
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: d.color,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text('${i+1}',
                            style: GoogleFonts.cairo(
                              fontSize: 13, fontWeight: FontWeight.w900,
                              color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        // أيقونة الخطوة
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: d.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(step.icon, color: d.color, size: 16),
                        ),
                        const SizedBox(width: 10),
                        // نص الخطوة
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              isAr ? step.ar : step.en,
                              style: GoogleFonts.cairo(
                                fontSize: 13, color: AppColors.textDark,
                                height: 1.45,
                                fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // زر اتصال الطوارئ
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: Text(
                      isAr ? 'اتصل بالطوارئ 911' : 'Call Emergency 911',
                      style: GoogleFonts.cairo(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: d.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _IllustrationPainter — رسم SVG توضيحي مخصص
// ════════════════════════════════════════════════════════
class _IllustrationPainter extends CustomPainter {
  final _IllustrationType type;
  final Color color;
  final bool large;

  const _IllustrationPainter(
      {required this.type, required this.color, this.large = false});

  @override
  void paint(Canvas canvas, Size size) {
    final c = color;
    final w = size.width;
    final h = size.height;
    final p = Paint()..color = c..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    switch (type) {
      case _IllustrationType.cpr:
        _drawCpr(canvas, w, h, p, c);
        break;
      case _IllustrationType.bleeding:
        _drawBleeding(canvas, w, h, p, c);
        break;
      case _IllustrationType.burn:
        _drawBurn(canvas, w, h, p, c);
        break;
      case _IllustrationType.choking:
        _drawChoking(canvas, w, h, p, c);
        break;
      case _IllustrationType.fracture:
        _drawFracture(canvas, w, h, p, c);
        break;
      case _IllustrationType.fainting:
        _drawFainting(canvas, w, h, p, c);
        break;
      case _IllustrationType.snake:
        _drawSnake(canvas, w, h, p, c);
        break;
      case _IllustrationType.drowning:
        _drawDrowning(canvas, w, h, p, c);
        break;
    }
  }

  void _drawCpr(Canvas canvas, double w, double h, Paint p, Color c) {
    // شخص مستلقٍ
    p..color = c.withOpacity(0.15)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.1,h*.55,w*.8,h*.2), const Radius.circular(8)), p);
    p..color = c..style = PaintingStyle.stroke..strokeWidth = large?3:2;
    // جسم
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.1,h*.55,w*.8,h*.2), const Radius.circular(8)), p);
    // رأس
    p..style = PaintingStyle.fill..color = c.withOpacity(0.2);
    canvas.drawCircle(Offset(w*.85,h*.5), w*.1, p);
    p..style = PaintingStyle.stroke..color = c;
    canvas.drawCircle(Offset(w*.85,h*.5), w*.1, p);
    // يدان تضغطان
    final handPath = Path()
      ..moveTo(w*.35,h*.35)..lineTo(w*.35,h*.55)
      ..moveTo(w*.5,h*.3)..lineTo(w*.5,h*.55);
    canvas.drawPath(handPath, p..strokeWidth = large?4:2.5);
    // موجات ضغط
    for (int i=0; i<3; i++) {
      p.color = c.withOpacity(0.3 - i*0.08);
      canvas.drawArc(Rect.fromCenter(
        center:Offset(w*.42,h*.45), width:w*(0.15+i*.12), height:h*(0.12+i*.1)),
        0, math.pi*2, false, p..style=PaintingStyle.stroke..strokeWidth=1);
    }
  }

  void _drawBleeding(Canvas canvas, double w, double h, Paint p, Color c) {
    // ذراع مع ضمادة
    p..color = c.withOpacity(0.12)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.15,h*.3,w*.7,h*.4), const Radius.circular(20)), p);
    p..color = c..style = PaintingStyle.stroke..strokeWidth = large?3:2;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.15,h*.3,w*.7,h*.4), const Radius.circular(20)), p);
    // ضمادة بيضاء
    p..style = PaintingStyle.fill..color = Colors.white.withOpacity(0.8);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.35,h*.35,w*.3,h*.3), const Radius.circular(6)), p);
    p..style = PaintingStyle.stroke..color = c..strokeWidth = large?2:1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.35,h*.35,w*.3,h*.3), const Radius.circular(6)), p);
    // خطوط الضمادة
    canvas.drawLine(Offset(w*.5,h*.35), Offset(w*.5,h*.65), p..strokeWidth=1.5);
    canvas.drawLine(Offset(w*.35,h*.5), Offset(w*.65,h*.5), p..strokeWidth=1.5);
    // قطرات دم
    p..style = PaintingStyle.fill..color = c.withOpacity(0.4);
    for (int i=0; i<3; i++) {
      canvas.drawCircle(Offset(w*(.25+i*.2),h*.8), large?3:2, p);
    }
  }

  void _drawBurn(Canvas canvas, double w, double h, Paint p, Color c) {
    // يد تحت ماء
    p..color = const Color(0xFF42A5F5).withOpacity(0.2)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.1,h*.5,w*.8,h*.4), const Radius.circular(8)), p);
    p..style = PaintingStyle.stroke..color = const Color(0xFF42A5F5)..strokeWidth=large?2:1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.1,h*.5,w*.8,h*.4), const Radius.circular(8)), p);
    // يد
    p..style = PaintingStyle.fill..color = c.withOpacity(0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.3,h*.25,w*.4,h*.5), const Radius.circular(12)), p);
    p..style = PaintingStyle.stroke..color = c..strokeWidth=large?3:2;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.3,h*.25,w*.4,h*.5), const Radius.circular(12)), p);
    // موجات الماء
    for (int i=0; i<3; i++) {
      final wavePath = Path();
      wavePath.moveTo(w*.1, h*(.58+i*.08));
      for (int j=0; j<5; j++) {
        wavePath.quadraticBezierTo(
          w*(.2+j*.16), h*(.54+i*.08),
          w*(.28+j*.16), h*(.58+i*.08));
      }
      canvas.drawPath(wavePath, p..color=const Color(0xFF42A5F5).withOpacity(.6)..strokeWidth=1.5);
    }
  }

  void _drawChoking(Canvas canvas, double w, double h, Paint p, Color c) {
    // شخص يقف، يدان حول الرقبة
    // جسم
    p..color = c.withOpacity(0.12)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.35,h*.35,w*.3,h*.45), const Radius.circular(8)), p);
    p..style=PaintingStyle.stroke..color=c..strokeWidth=large?3:2;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.35,h*.35,w*.3,h*.45), const Radius.circular(8)), p);
    // رأس
    p..style=PaintingStyle.fill..color=c.withOpacity(0.15);
    canvas.drawCircle(Offset(w*.5,h*.22), w*.13, p);
    p..style=PaintingStyle.stroke..color=c;
    canvas.drawCircle(Offset(w*.5,h*.22), w*.13, p);
    // يدان حول الرقبة
    p.strokeWidth = large?2.5:2;
    canvas.drawArc(Rect.fromCenter(center:Offset(w*.5,h*.36),
      width:w*.25,height:h*.12), math.pi*.8, math.pi*.8, false, p);
    // علامة تعجب
    p..style=PaintingStyle.fill..color=c;
    canvas.drawCircle(Offset(w*.82,h*.2), large?8:5, p);
    p..style=PaintingStyle.stroke..color=Colors.white..strokeWidth=large?2:1.5;
    canvas.drawLine(Offset(w*.82,h*.12), Offset(w*.82,h*.2), p);
    canvas.drawCircle(Offset(w*.82,h*.24), large?2:1.5, p);
  }

  void _drawFracture(Canvas canvas, double w, double h, Paint p, Color c) {
    // عظمة مكسورة وجبيرة
    p..color = c.withOpacity(0.12)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.2,h*.4,w*.6,h*.2), const Radius.circular(8)), p);
    p..style=PaintingStyle.stroke..color=c..strokeWidth=large?3:2;
    // عظمة مع كسر
    canvas.drawLine(Offset(w*.2,h*.5), Offset(w*.42,h*.5), p);
    canvas.drawLine(Offset(w*.42,h*.5), Offset(w*.45,h*.42), p..color=c..strokeWidth=large?2:1.5);
    canvas.drawLine(Offset(w*.45,h*.42), Offset(w*.48,h*.5), p);
    canvas.drawLine(Offset(w*.48,h*.5), Offset(w*.8,h*.5), p..strokeWidth=large?3:2);
    // جبيرة
    p..style=PaintingStyle.fill..color=const Color(0xFF42A5F5).withOpacity(.2);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.25,h*.35,w*.5,h*.3), const Radius.circular(6)), p);
    p..style=PaintingStyle.stroke..color=const Color(0xFF42A5F5)..strokeWidth=1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.25,h*.35,w*.5,h*.3), const Radius.circular(6)), p);
    for (int i=0; i<4; i++) {
      canvas.drawLine(Offset(w*(.32+i*.12),h*.35), Offset(w*(.32+i*.12),h*.65), p..strokeWidth=1);
    }
  }

  void _drawFainting(Canvas canvas, double w, double h, Paint p, Color c) {
    // شخص مستلقٍ مع سهم أعلى القدمين
    p..color=c.withOpacity(0.12)..style=PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.1,h*.5,w*.65,h*.22), const Radius.circular(10)), p);
    p..style=PaintingStyle.stroke..color=c..strokeWidth=large?3:2;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.1,h*.5,w*.65,h*.22), const Radius.circular(10)), p);
    // رأس
    p..style=PaintingStyle.fill..color=c.withOpacity(0.15);
    canvas.drawCircle(Offset(w*.85,h*.52), w*.1, p);
    p..style=PaintingStyle.stroke..color=c;
    canvas.drawCircle(Offset(w*.85,h*.52), w*.1, p);
    // سهم رفع أعلى
    p.color=c;p.strokeWidth=large?3:2;
    canvas.drawLine(Offset(w*.2,h*.38), Offset(w*.2,h*.5), p);
    canvas.drawLine(Offset(w*.14,h*.44), Offset(w*.2,h*.38), p);
    canvas.drawLine(Offset(w*.26,h*.44), Offset(w*.2,h*.38), p);
  }

  void _drawSnake(Canvas canvas, double w, double h, Paint p, Color c) {
    // ثعبان متعرج
    final snakePath = Path();
    snakePath.moveTo(w*.1,h*.7);
    snakePath.cubicTo(w*.2,h*.3, w*.4,h*.8, w*.5,h*.5);
    snakePath.cubicTo(w*.6,h*.2, w*.75,h*.6, w*.85,h*.4);
    p..style=PaintingStyle.stroke..color=c..strokeWidth=large?8:5;
    canvas.drawPath(snakePath, p..color=c.withOpacity(.15));
    p.strokeWidth=large?5:3.5;
    canvas.drawPath(snakePath, p..color=c);
    // رأس الثعبان
    p..style=PaintingStyle.fill..color=c;
    canvas.drawCircle(Offset(w*.85,h*.38), large?9:6, p);
    // العين
    p.color=Colors.white;
    canvas.drawCircle(Offset(w*.87,h*.36), large?3:2, p);
    // علامة تحذير
    p..style=PaintingStyle.fill..color=const Color(0xFFFFC107).withOpacity(.9);
    final tri = Path();
    tri.moveTo(w*.15,h*.15);
    tri.lineTo(w*.07,h*.3);
    tri.lineTo(w*.23,h*.3);
    tri.close();
    canvas.drawPath(tri, p);
    p..style=PaintingStyle.stroke..color=Colors.white..strokeWidth=large?2:1.5;
    canvas.drawLine(Offset(w*.15,h*.19), Offset(w*.15,h*.25), p);
    canvas.drawCircle(Offset(w*.15,h*.28), large?2:1.2, p..style=PaintingStyle.fill);
  }

  void _drawDrowning(Canvas canvas, double w, double h, Paint p, Color c) {
    // موجات ماء
    p..style=PaintingStyle.stroke..strokeWidth=large?2:1.5;
    for (int i=0; i<4; i++) {
      final wavePath = Path();
      wavePath.moveTo(0, h*(.5+i*.1));
      for (int j=0; j<6; j++) {
        wavePath.quadraticBezierTo(
          w*(.08+j*.17), h*(.44+i*.1),
          w*(.17+j*.17), h*(.5+i*.1));
      }
      canvas.drawPath(wavePath, p..color=const Color(0xFF42A5F5).withOpacity(.5-i*.08));
    }
    // شخص يرفع يده
    p..style=PaintingStyle.fill..color=c.withOpacity(0.15);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.38,h*.3,w*.24,h*.3), const Radius.circular(8)), p);
    p..style=PaintingStyle.stroke..color=c..strokeWidth=large?3:2;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w*.38,h*.3,w*.24,h*.3), const Radius.circular(8)), p);
    // رأس
    p..style=PaintingStyle.fill..color=c.withOpacity(0.2);
    canvas.drawCircle(Offset(w*.5,h*.22), w*.1, p);
    p..style=PaintingStyle.stroke..color=c;
    canvas.drawCircle(Offset(w*.5,h*.22), w*.1, p);
    // يد مرفوعة
    p.strokeWidth=large?3:2;
    canvas.drawLine(Offset(w*.5,h*.3), Offset(w*.5,h*.1), p);
    canvas.drawLine(Offset(w*.44,h*.18), Offset(w*.5,h*.1), p);
    canvas.drawLine(Offset(w*.56,h*.18), Offset(w*.5,h*.1), p);
  }

  @override
  bool shouldRepaint(_IllustrationPainter o) => false;
}