// ════════════════════════════════════════════════════════
//  AppStrings — نصوص التطبيق (عربي / إنجليزي)
// ════════════════════════════════════════════════════════
final class AppStrings {
  final bool isAr;
  const AppStrings(this.isAr);

  factory AppStrings.of(bool ar) => AppStrings(ar);

  // ── هوية ──────────────────────────────────────────────
  String get appName    => 'إغاثة';
  String get appNameEn  => 'IGHATHA';
  String get langToggle => isAr ? 'English' : 'عربي';

  // ── Splash ────────────────────────────────────────────
  String get splashTagLine => isAr ? 'نظام الاستجابة الطارئة' : 'EMERGENCY RESPONSE SYSTEM';
  String get splashLoading => isAr ? 'جاري تأمين الاتصال...' : 'Securing connection...';
  String get splashReady   => isAr ? '✓ النظام جاهز' : '✓ System Ready';
  String get splashAlways  => isAr ? 'حماية على مدار الساعة · 24/7' : '24/7 Protection';

  // ── Onboarding ────────────────────────────────────────
  String get ob1Title => isAr ? 'أهلاً وسهلاً'      : 'Welcome';
  String get ob1Desc  => isAr
      ? 'إغاثة هو رفيقك الصحي الذكي، مصمم ليكون معك في كل لحظة تحتاج فيها المساعدة.'
      : 'Ighatha is your smart health companion, always by your side when you need help.';

  String get ob2Title => isAr ? 'مواعيدك بنظام'     : 'Stay Organized';
  String get ob2Desc  => isAr
      ? 'تابع جميع مواعيدك الطبية وتذكيرات الأدوية والفحوصات الدورية في مكان واحد.'
      : 'Track all medical appointments, medication reminders, and check-ups in one place.';

  String get ob3Title => isAr ? 'صحة عائلتك'        : 'Family Health';
  String get ob3Desc  => isAr
      ? 'أدر صحة أفراد عائلتك بالكامل من حساب واحد بسهولة وأمان.'
      : 'Manage your entire family\'s health from one secure account.';

  String get obNext  => isAr ? 'متابعة'        : 'Next';
  String get obStart => isAr ? 'ابدأ الحماية'  : 'Start Protection';

  // ── Login ──────────────────────────────────────────────
  String get loginTitle     => isAr ? 'تسجيل الدخول للنظام'          : 'System Login';
  String get idField        => isAr ? 'رقم البطاقة الوطنية / الإقامة' : 'National ID / Iqama';
  String get passField      => isAr ? 'كلمة المرور'                   : 'Password';
  String get resident       => isAr ? 'مواطن / مقيم'                  : 'Citizen / Resident';
  String get visitor        => isAr ? 'زائر (سائح/دبلوماسي)'          : 'Visitor';
  String get loginBtn       => isAr ? 'دخول آمن'                      : 'Secure Login';
  String get forgotPassword => isAr ? 'نسيت كلمة المرور؟'             : 'Forgot password?';

  // ── Home ──────────────────────────────────────────────
  String get homeGreeting  => isAr ? 'مرحباً بك،'             : 'Welcome,';
  String get homeSubGreet  => isAr ? 'نتمنى لك يوماً صحياً سعيداً' : 'Wishing you a healthy day';
  String get homeStatus    => isAr ? 'النظام يراقب موقعك الآن' : 'System monitoring location';
  String get quickActions  => isAr ? 'إجراءات سريعة'           : 'Quick Actions';
  String get myHealth      => isAr ? 'صحتي'                    : 'My Health';
  String get appointments  => isAr ? 'المواعيد'                : 'Appointments';
  String get medications   => isAr ? 'الأدوية'                 : 'Medications';
  String get reports       => isAr ? 'التقارير'                : 'Reports';
  String get family        => isAr ? 'العائلة'                 : 'Family';
  String get vitals        => isAr ? 'العلامات الحيوية'        : 'Vitals';
  String get nextAppt      => isAr ? 'الموعد القادم'           : 'Next Appointment';
  String get seeAll        => isAr ? 'عرض الكل'                : 'See All';
  
  // ✅ إضافة: شريط البحث
  String get searchHint    => isAr ? 'ابحث في إغاثة...'        : 'Search in Ighatha...';

  // ── Emergency ────────────────────────────────────────
  String get btnPolice        => isAr ? 'شرطة (نجدة)'                : 'Police (SOS)';
  String get btnPoliceDesc    => isAr ? 'إبلاغ عن جريمة أو تهديد أمني' : 'Report crime or security threat';
  String get btnAmbulance     => isAr ? 'إسعاف فوري'                  : 'Ambulance';
  String get btnAmbulanceDesc => isAr ? 'طلب مساعدة طبية عاجلة'       : 'Request urgent medical aid';
  String get btnFire          => isAr ? 'إطفاء (حريق)'               : 'Fire Dept';
  String get btnFireDesc      => isAr ? 'إبلاغ عن حريق أو انفجار'    : 'Report fire or explosion';
  String get btnCritical      => isAr ? 'استغاثة قصوى (SOS)'         : 'CRITICAL SOS';
  String get btnCriticalDesc  => isAr ? 'اضغط مطولاً لتعميم موقعك'   : 'Hold to broadcast location';
  String get alertSending     => isAr ? 'جاري إرسال إشارة الاستغاثة...' : 'Sending distress signal...';
  String get alertSent        => isAr ? '✓ تم استلام بلاغك، المساعدة في الطريق' : '✓ Signal received, help is coming';
  String get alertCancel      => isAr ? 'إلغاء البلاغ (أنا بخير)'     : 'Cancel Alert (I am safe)';

  // ── AI ────────────────────────────────────────────────
  String get aiChatTitle => isAr ? 'مساعد الطوارئ الذكي' : 'Smart Emergency Assistant';
  String get aiChatHint  => isAr ? 'اشرح الموقف...'       : 'Describe the situation...';
  String get aiStatus    => isAr ? 'جاهز للمساعدة فوراً'  : 'Ready to assist';

  // ── Welcome ───────────────────────────────────────────
  String get tagline      => isAr ? 'مساعدة فورية في كل لحظة حرجة'    : 'Instant help in every critical moment';
  String get description  => isAr
      ? 'أمانك بضغطة زر. نصل إليك أينما كنت وفي أسرع وقت ممكن.'
      : 'Safety at your fingertips. We reach you wherever you are, as fast as possible.';
  String get login        => isAr ? 'تسجيل الدخول'  : 'Login';
  String get noAccount    => isAr ? 'ليس لديك حساب؟ ' : "Don't have an account? ";
  String get createAccount=> isAr ? 'إنشاء حساب'     : 'Create account';
  String get contactUs    => isAr ? 'تواصل معنا'      : 'Contact us';
  String get selectLang   => isAr ? 'اختر اللغة'      : 'Select Language';
  String get arabic       => isAr ? 'العربية'          : 'Arabic';
  String get english      => isAr ? 'الإنجليزية'       : 'English';

  // ── Legal ──────────────────────────────────────────────
  String get legalNotice  => isAr ? 'تحذير: البلاغات الكاذبة تعرضك للمساءلة القانونية.' : 'Warning: False reports lead to legal prosecution.';
  String get legalPre     => isAr ? 'باستخدامك توافق على '   : 'By using you agree to ';
  String get privacyPolicy=> isAr ? 'سياسة الخصوصية'         : 'Privacy Policy';
  String get legalMid     => isAr ? ' و '                     : ' and ';
  String get terms        => isAr ? 'الشروط والأحكام'         : 'Terms & Conditions';

  // ── Contacts ──────────────────────────────────────────
  String get contactsTitle=> isAr ? 'دائرة الثقة'             : 'Circle of Trust';
  String get contactsDesc => isAr ? 'أضف أهلك ليصلهم تنبيه فور تعرضك لخطر' : 'Add family to notify them in danger';
  String get addContact   => isAr ? 'إضافة جهة اتصال طارئة'  : 'Add Emergency Contact';
}