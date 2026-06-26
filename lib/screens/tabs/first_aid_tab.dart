// ════════════════════════════════════════════════════════
//  tabs/first_aid_tab.dart
//  تبويب دليل الإسعافات الأولية — تصميم مُعاد بالكامل
//  ✅ نفس الهوية البصرية المنظّمة المستخدمة في صفحة "القائمة الرئيسية"
//  ✅ شريط علوي أبيض بسيط + عداد دائري
//  ✅ بطاقات بيضاء نظيفة بدل البانر الأحمر الكبير
//  ✅ "خط زمني" بصري لكل خطوة (أيقونة داخل دائرة) لشرح عملية الإنقاذ
//     بدل الرسومات التجريدية القديمة — أوضح وأسهل للفهم
// ════════════════════════════════════════════════════════
//
//  ⚠️ ملاحظة: لم أستخدم صوراً فعلية مولّدة بالذكاء الاصطناعي أو صوراً
//  من الإنترنت، لأن صور المخزون (stock images) محمية بحقوق نشر ولا يمكن
//  تضمينها مباشرة في كود التطبيق، وتوليد صور AI حقيقية يحتاج خدمة خارجية
//  (مثل DALL·E) لرفعها كملفات assets يدوياً في مشروعك. بدلاً من ذلك صممت
//  "خط إنقاذ بصري" (Visual Rescue Timeline) من الأيقونات داخل دوائر مرتبة
//  بنفس ألوان الحالة، يوضح تسلسل عملية الإنقاذ بشكل مرتّب وسريع الفهم،
//  وهو أسلوب يستخدمه تطبيقات الإسعاف الحقيقية (مثل Red Cross App).
//  إذا توفّرت لديك صور توضيحية حقيقية (PNG/SVG) أرسلها لي وسأدمجها مكان
//  الأيقونات مباشرة.
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
  /// مسار صورة توضيحية حقيقية تضعها أنت — مثال:
  /// 'assets/images/first_aid/cpr.png'
  /// إذا لم تكن الصورة موجودة بعد، تظهر الأيقونة تلقائياً بدلاً عنها.
  final String? imageAsset;

  const _Case({
    required this.titleAr, required this.titleEn,
    required this.descAr,  required this.descEn,
    required this.categoryAr, required this.categoryEn,
    required this.color, required this.icon,
    required this.steps,
    this.imageAsset,
  });
}

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
    imageAsset: 'assets/images/first_aid/cpr.png',
    steps: [
      _Step(ar:'تأكد من سلامة المكان ومن أن الضحية لا تستجيب',en:'Ensure scene safety and check responsiveness',icon:Icons.health_and_safety_rounded),
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
    imageAsset: 'assets/images/first_aid/bleeding.png',
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
    imageAsset: 'assets/images/first_aid/burns.png',
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
    imageAsset: 'assets/images/first_aid/choking.png',
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
    imageAsset: 'assets/images/first_aid/fracture.png',
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
    imageAsset: 'assets/images/first_aid/fainting.png',
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
    imageAsset: 'assets/images/first_aid/snake_bite.png',
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
    imageAsset: 'assets/images/first_aid/drowning.png',
    steps: [
      _Step(ar:'لا تقفز في الماء إلا إن كنت مدرّباً — استخدم حبلاً أو عوامة',en:'Don\'t jump in water unless trained — use rope or float',icon:Icons.health_and_safety_rounded),
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
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── هيدر أبيض منظّم (بنفس هوية صفحة القائمة) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _PageHeader(isAr: isAr, total: _cases.length),
                ),
              ),

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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CaseCard(caseData: _filtered[i], isAr: isAr),
                    ),
                    childCount: _filtered.length,
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

// ════════════════════════════════════════════════════════
//  _PageHeader — نفس أسلوب رأس صفحة "القائمة الرئيسية"
// ════════════════════════════════════════════════════════
class _PageHeader extends StatelessWidget {
  final bool isAr;
  final int total;
  const _PageHeader({required this.isAr, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      InkWell(
        onTap: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(19),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            isAr ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            color: AppColors.textGray,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 19),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isAr ? 'دليل الإسعافات الأولية' : 'First Aid Guide',
            style: GoogleFonts.cairo(
                fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          Text(
            isAr ? 'تعلّم كيف تنقذ حياة في لحظات حرجة' : 'Learn to save lives in critical moments',
            style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
          ),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('$total',
            style: GoogleFonts.cairo(
                fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
      ),
    ]);
  }
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
      border: Border.all(color: const Color(0xFFEFF2F7)),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: TextField(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      onChanged: onChanged,
      style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: isAr ? 'ابحث عن حالة طارئة...' : 'Search emergency case...',
        hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.textHint),
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
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
              border: Border.all(color: isSel ? cat.col : const Color(0xFFEFF2F7)),
              boxShadow: [BoxShadow(
                color: isSel ? cat.col.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
                blurRadius: 6, offset: const Offset(0, 2))],
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
//  _CaseCard — بطاقة بيضاء نظيفة (بنفس هوية بطاقات القائمة)
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded ? d.color.withValues(alpha: 0.25) : const Color(0xFFEFF2F7),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(children: [
        // ── رأس البطاقة (نظيف، بدون بانر) ──
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              _CaseThumb(caseData: d),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isAr ? d.titleAr : d.titleEn,
                    style: GoogleFonts.cairo(fontSize: 13.5,
                        fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Text(isAr ? d.descAr : d.descEn,
                    style: GoogleFonts.cairo(fontSize: 11,
                        color: AppColors.textGray, height: 1.3),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: d.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(isAr ? d.categoryAr : d.categoryEn,
                        style: GoogleFonts.cairo(fontSize: 10,
                            color: d.color, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text('${d.steps.length} ${isAr ? "خطوات" : "steps"}',
                      style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textGray)),
                  ]),
                ],
              )),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textGray, size: 22),
              ),
            ]),
          ),
        ),

        // ── المحتوى الموسّع ──
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: Column(children: [
              Container(height: 1, color: const Color(0xFFEEF2F7)),
              const SizedBox(height: 14),

              // ── مكان الصورة التوضيحية الحقيقية (ضعها أنت هنا) ──
              _CaseImageSlot(caseData: d, isAr: isAr),
              const SizedBox(height: 14),

              // ── خط الإنقاذ البصري: أيقونات الخطوات مرتّبة بشكل أفقي ──
              _RescueTimeline(color: d.color, steps: d.steps),
              const SizedBox(height: 16),

              // ── الخطوات التفصيلية ──
              ...d.steps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(color: d.color, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${i + 1}',
                          style: GoogleFonts.cairo(
                            fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: d.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(step.icon, color: d.color, size: 15),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            isAr ? step.ar : step.en,
                            style: GoogleFonts.cairo(
                              fontSize: 12.5, color: AppColors.textDark,
                              height: 1.45, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── زر اتصال الطوارئ ──
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: Text(
                    isAr ? 'اتصل بالطوارئ 911' : 'Call Emergency 911',
                    style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: d.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _CaseThumb — صورة مصغّرة في رأس البطاقة (أو الأيقونة كبديل)
// ════════════════════════════════════════════════════════
class _CaseThumb extends StatelessWidget {
  final _Case caseData;
  const _CaseThumb({required this.caseData});

  @override
  Widget build(BuildContext context) {
    final d = caseData;
    return Container(
      width: 50, height: 50,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: d.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: d.imageAsset == null
          ? Icon(d.icon, color: d.color, size: 24)
          : Image.asset(
              d.imageAsset!,
              fit: BoxFit.cover,
              // إذا لم تُضف الصورة بعد، تظهر الأيقونة تلقائياً بدلاً عنها
              errorBuilder: (_, __, ___) => Icon(d.icon, color: d.color, size: 24),
            ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _CaseImageSlot — مكان مخصّص لوضع صورة توضيحية حقيقية
//  ضع صورتك في: assets/images/first_aid/<اسم الملف>.png
//  وأضف المسار في pubspec.yaml أسفل assets:
//      assets:
//        - assets/images/first_aid/
//  إن لم تُضف الصورة بعد، يظهر مكانها إطار منقّط بالأيقونة كبديل مؤقت.
// ════════════════════════════════════════════════════════
class _CaseImageSlot extends StatelessWidget {
  final _Case caseData;
  final bool isAr;
  const _CaseImageSlot({required this.caseData, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final d = caseData;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 170,
        width: double.infinity,
        color: d.color.withValues(alpha: 0.06),
        child: d.imageAsset == null
            ? _placeholder(d)
            : Image.asset(
                d.imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(d),
              ),
      ),
    );
  }

  Widget _placeholder(_Case d) {
    return DottedBorderBox(
      color: d.color.withValues(alpha: 0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: d.color.withValues(alpha: 0.6), size: 30),
          const SizedBox(height: 8),
          Text(
            isAr ? 'ضع صورتك التوضيحية هنا' : 'Place your illustration image here',
            style: GoogleFonts.cairo(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: d.color.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 3),
          Text(
            d.imageAsset ?? 'assets/images/first_aid/...',
            style: GoogleFonts.cairo(fontSize: 9.5, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

/// إطار بحدود منقّطة بسيطة (بدون أي حزمة خارجية)
class DottedBorderBox extends StatelessWidget {
  final Color color;
  final Widget child;
  const DottedBorderBox({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(color: color),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  const _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)));
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        final next = dist + dashWidth;
        canvas.drawPath(m.extractPath(dist, next.clamp(0, m.length)), paint);
        dist = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) => oldDelegate.color != color;
}

// ════════════════════════════════════════════════════════
//  _RescueTimeline — خط زمني بصري يلخّص تسلسل عملية الإنقاذ
//  (أيقونة كل خطوة داخل دائرة، مربوطة بخط، مرقّمة بالترتيب)
// ════════════════════════════════════════════════════════
class _RescueTimeline extends StatelessWidget {
  final Color color;
  final List<_Step> steps;
  const _RescueTimeline({required this.color, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(steps.length, (i) {
            final isLast = i == steps.length - 1;
            return Row(children: [
              Column(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.6),
                    boxShadow: [BoxShadow(
                        color: color.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Icon(steps[i].icon, color: color, size: 21),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${i + 1}',
                      style: GoogleFonts.cairo(
                          fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ]),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Container(
                    width: 22, height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
            ]);
          }),
        ),
      ),
    );
  }
}