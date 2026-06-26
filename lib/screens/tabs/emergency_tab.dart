// ════════════════════════════════════════════════════════
//  tabs/emergency_tab.dart
//  ✅ دمج خدمات الطوارئ مع الخدمات العامة في شبكة واحدة
//  ✅ حذف بطاقة SOS القصوى (_BigSOSButton)
//  ✅ الإبقاء على زر 911 الدائري فقط
//  ✅ حذف قسم تبليغ عن حالة طارئة
//  ✅ حذف قسم الوصول السريع
//  ✅ إصلاح مشكلة unbounded height
//  ✅ إصلاح مشكلة الكتابة تحت أزرار الهاتف
//  ✅ دعم صوتي (TTS): ترحيب صوتي + نطق ردود المساعد الذكي
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/voice_service.dart';
import '../emergency_widgets.dart';

class EmergencyTab extends ConsumerStatefulWidget {
  const EmergencyTab({super.key});

  @override
  ConsumerState<EmergencyTab> createState() => _EmergencyTabState();
}

class _EmergencyTabState extends ConsumerState<EmergencyTab>
    with TickerProviderStateMixin {

  // ── حالة المحادثة الذكية ──────────────────────────────
  bool _chatVisible = false;

  // ── حالة الصوت (تشغيل/إيقاف نطق ردود المساعد) ────────
  bool _voiceOn = true;

  // ── أنيميشن ظهور/اختفاء المحادثة والخدمات ────────────
  late AnimationController _transitionCtrl;
  late Animation<double>   _servicesFade;
  late Animation<double>   _servicesScale;
  late Animation<double>   _chatFade;
  late Animation<double>   _chatSlide;
  late Animation<double>   _topBarFade;

  // ── المحادثة ─────────────────────────────────────────
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;

  final List<ChatMessage> _messages = [
    const ChatMessage('مرحباً! أنا مساعدك في حالات الطوارئ. كيف يمكنني مساعدتك؟', false),
  ];

  static const List<String> _aiReplies = [
    'تم تحديد موقعك تلقائياً ✓ جاري إرسال طلب المساعدة...',
    'أقرب مستشفى: مستشفى الملك عبدالله — على بُعد 2.3 كم.',
    'رقم الطوارئ الموحد: 122 — اضغط زر الاتصال الآن.',
    'تم إخطار جهات الاتصال الطارئة الخاصة بك بنجاح.',
    'فريق الإسعاف في الطريق، وقت الوصول المتوقع: 8 دقائق.',
    'ابق هادئاً. المساعدة في الطريق إليك الآن.',
    'تم تسجيل بلاغك ورقمه: #ER-2024-7841 ✓',
  ];
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();

    _transitionCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    _servicesFade = CurvedAnimation(
        parent: _transitionCtrl, curve: Curves.easeOut);
    _servicesScale = Tween<double>(begin: 1.0, end: 0.8)
        .animate(CurvedAnimation(parent: _transitionCtrl, curve: Curves.easeOut));

    _chatFade = CurvedAnimation(
        parent: _transitionCtrl, curve: Curves.easeOut);
    _chatSlide = Tween<double>(begin: 50, end: 0)
        .animate(CurvedAnimation(parent: _transitionCtrl, curve: Curves.easeOutCubic));

    _topBarFade = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _transitionCtrl, curve: Curves.easeOut));

    // ── ترحيب صوتي عند فتح التبويب ──────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isAr = ref.read(languageProvider);
      VoiceService.instance.setEnabled(_voiceOn);
      VoiceService.instance.speak(
        isAr
            ? 'أهلاً وسهلاً بتطبيق الإنقاذ. كيف يمكنني مساعدتك؟'
            : 'Welcome to the Rescue app. How can I help you?',
        isAr: isAr,
      );
    });
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    _transitionCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── تبديل ظهور المحادثة ──────────────────────────────
  void _toggleChat() {
    HapticFeedback.selectionClick();
    if (!_chatVisible) {
      setState(() => _chatVisible = true);
      _transitionCtrl.forward();
    } else {
      VoiceService.instance.stop();
      _transitionCtrl.reverse().then((_) {
        if (mounted) setState(() => _chatVisible = false);
      });
    }
  }

  // ── تبديل تشغيل/إيقاف الصوت ──────────────────────────
  void _toggleVoice() {
    HapticFeedback.selectionClick();
    setState(() => _voiceOn = !_voiceOn);
    VoiceService.instance.setEnabled(_voiceOn);
    if (!_voiceOn) VoiceService.instance.stop();
  }

  // ── إرسال رسالة ──────────────────────────────────────
  void _send(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    final isAr = ref.read(languageProvider);
    setState(() {
      _messages.add(ChatMessage(text.trim(), true));
      _typing = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1350), () {
      if (!mounted) return;
      final reply = _aiReplies[_replyIndex++ % _aiReplies.length];
      setState(() {
        _typing = false;
        _messages.add(ChatMessage(reply, false));
      });
      _scrollToBottom();

      // ── نطق رد المساعد الذكي صوتياً ───────────────────
      VoiceService.instance.speak(reply, isAr: isAr);
    });
  }

  void _scrollToBottom() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      });

  // ── قائمة الخدمات المدمجة (طوارئ + عامة) ─────────────
  List<_EService> _services(bool isAr) => [
    // ── الخدمات العامة ──
    _EService(
      emoji: '🚔', labelAr: 'مراكز الشرطة', labelEn: 'Police Stations',
      subAr: 'القريبة', subEn: 'Nearby',
      colors: const [Color(0xFF0D47A1), Color(0xFF1976D2)],
      shadow: const Color(0x501976D2),
      msgAr: 'أحتاج الشرطة في موقعي', msgEn: 'I need police at my location'),
    _EService(
      emoji: '🚒', labelAr: 'مراكز الإطفاء', labelEn: 'Fire Stations',
      subAr: 'القريبة', subEn: 'Nearby',
      colors: const [Color(0xFF880E4F), Color(0xFFC2185B)],
      shadow: const Color(0x50C2185B),
      msgAr: 'يوجد حريق! أحتاج سيارة إطفاء', msgEn: 'Fire! Need a fire truck'),
    _EService(
      emoji: '🏥', labelAr: 'المستشفيات', labelEn: 'Hospitals',
      subAr: 'القريبة', subEn: 'Nearby',
      colors: const [Color(0xFF1565C0), Color(0xFF0288D1)],
      shadow: const Color(0x500288D1),
      msgAr: 'أحتاج سيارة إسعاف فوراً!', msgEn: 'I need an ambulance now!'),
    // ── خدمات الطوارئ ──
    _EService(
      emoji: '🚑', labelAr: 'إسعاف', labelEn: 'Ambulance',
      subAr: 'طبي عاجل', subEn: 'Medical',
      colors: const [Color(0xFFE65100), Color(0xFFFF6D00)],
      shadow: const Color(0x50FF6D00),
      msgAr: 'أحتاج سيارة إسعاف فوراً!', msgEn: 'I need an ambulance!'),
    _EService(
      emoji: '⚡', labelAr: 'كهرباء', labelEn: 'Electric',
      subAr: 'خطر كهربائي', subEn: 'Electric Hazard',
      colors: const [Color(0xFFF57F17), Color(0xFFFBC02D)],
      shadow: const Color(0x50FBC02D),
      msgAr: 'يوجد خطر كهربائي! خط ساقط أو تماس', msgEn: 'Electrical hazard! Fallen line'),
    _EService(
      emoji: '🌊', labelAr: 'غرق', labelEn: 'Drowning',
      subAr: 'إنقاذ مائي', subEn: 'Water Rescue',
      colors: const [Color(0xFF006064), Color(0xFF00838F)],
      shadow: const Color(0x5000838F),
      msgAr: 'شخص يغرق! أحتاج فريق إنقاذ', msgEn: 'Someone drowning! Need rescue'),
    _EService(
      emoji: '🏗️', labelAr: 'انهيار', labelEn: 'Collapse',
      subAr: 'أنقاض', subEn: 'Rubble',
      colors: const [Color(0xFF4A148C), Color(0xFF7B1FA2)],
      shadow: const Color(0x507B1FA2),
      msgAr: 'انهار مبنى! أشخاص محاصرون تحت الأنقاض', msgEn: 'Building collapsed! People trapped'),
    _EService(
      emoji: '☢️', labelAr: 'تسرب', labelEn: 'Gas Leak',
      subAr: 'غاز خطر', subEn: 'Hazardous',
      colors: const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      shadow: const Color(0x502E7D32),
      msgAr: 'يوجد تسرب غاز خطير في المنطقة', msgEn: 'Dangerous gas leak in area'),
    _EService(
      emoji: '🆘', labelAr: 'نجدة', labelEn: 'Rescue',
      subAr: 'مفقود', subEn: 'Missing',
      colors: const [Color(0xFF37474F), Color(0xFF546E7A)],
      shadow: const Color(0x50546E7A),
      msgAr: 'شخص مفقود! أحتاج فريق بحث وإنقاذ', msgEn: 'Person missing! Need search team'),
  ];

  // ── ردود سريعة ───────────────────────────────────────
  List<_QR> _quickReplies(bool isAr) => [
    _QR(label: isAr ? '🏥 أقرب مستشفى' : '🏥 Nearest hospital',
        msg:   isAr ? 'أين أقرب مستشفى؟' : 'Where is the nearest hospital?'),
    _QR(label: isAr ? '💊 إسعاف ذاتي'  : '💊 Self aid',
        msg:   isAr ? 'كيف أسعف نفسي؟' : 'How to do self first aid?'),
    _QR(label: isAr ? '📞 أرقام الطوارئ' : '📞 Numbers',
        msg:   isAr ? 'ما أرقام الطوارئ؟' : 'What are the emergency numbers?'),
    _QR(label: isAr ? '❓ ماذا أفعل؟'  : '❓ What to do?',
        msg:   isAr ? 'ماذا أفعل الآن في حالة طارئة؟' : 'What do I do in an emergency?'),
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);
    final user  = ref.watch(sessionProvider);
    final srvs  = _services(isAr);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // ── الهيدر ──────────────────────────────────
              EmergencyHeader(isAr: isAr, user: user),

              // ── المحتوى ─────────────────────────────────
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          14, 10, 14,
                          MediaQuery.of(context).viewInsets.bottom + 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([

                          // ── تنبيه ──────────────────────
                          EmergencyTipBox(isAr: isAr),
                          const SizedBox(height: 14),

                          // ── زر 911 الدائري ─────────────
                          _Sos911Button(isAr: isAr),
                          const SizedBox(height: 18),

                          // ── عنوان الخدمات + زر المساعد ──
                          AnimatedBuilder(
                            animation: _transitionCtrl,
                            builder: (_, __) {
                              if (_chatVisible && _transitionCtrl.value > 0.5) {
                                return const SizedBox.shrink();
                              }
                              return Opacity(
                                opacity: _chatVisible ? _topBarFade.value : 1.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _SLabel(
                                      icon: Icons.grid_view_rounded,
                                      color: AppColors.primary,
                                      label: isAr ? 'الخدمات العامة' : 'General Services',
                                    ),
                                    _AiToggleBtn(
                                      isAr: isAr,
                                      isOpen: _chatVisible,
                                      onTap: _toggleChat,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // ── شبكة الخدمات المدمجة ───────
                          AnimatedBuilder(
                            animation: _transitionCtrl,
                            builder: (_, __) {
                              if (_chatVisible && _transitionCtrl.isCompleted) {
                                return const SizedBox.shrink();
                              }
                              return FadeTransition(
                                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                                    CurvedAnimation(
                                        parent: _transitionCtrl,
                                        curve: Curves.easeOut)),
                                child: ScaleTransition(
                                  scale: _servicesScale,
                                  child: Column(
                                    children: [
                                      _ServicesGrid(
                                        services: srvs,
                                        isAr: isAr,
                                        onTap: (s) {
                                          final msg = isAr ? s.msgAr : s.msgEn;
                                          HapticFeedback.mediumImpact();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(msg,
                                                  style: GoogleFonts.cairo(
                                                      color: Colors.white)),
                                              backgroundColor: AppColors.primary,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12)),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      _TipRow(isAr: isAr),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          // ── لوحة المساعد الذكي ─────────
                          AnimatedBuilder(
                            animation: _transitionCtrl,
                            builder: (_, __) {
                              if (!_chatVisible && _transitionCtrl.isDismissed) {
                                return const SizedBox.shrink();
                              }
                              return FadeTransition(
                                opacity: _chatFade,
                                child: Transform.translate(
                                  offset: Offset(0, _chatSlide.value),
                                  child: SizedBox(
                                    height: 460,
                                    child: _AiChatPanel(
                                      isAr: isAr,
                                      messages: _messages,
                                      typing: _typing,
                                      scrollCtrl: _scrollCtrl,
                                      inputCtrl: _inputCtrl,
                                      quickReplies: _quickReplies(isAr),
                                      services: srvs,
                                      voiceOn: _voiceOn,
                                      onSend: _send,
                                      onClose: _toggleChat,
                                      onToggleVoice: _toggleVoice,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
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
//  _Sos911Button — زر 911 الدائري فقط (بدون SOS Card)
// ════════════════════════════════════════════════════════
class _Sos911Button extends StatefulWidget {
  final bool isAr;
  const _Sos911Button({required this.isAr});

  @override
  State<_Sos911Button> createState() => _Sos911ButtonState();
}

class _Sos911ButtonState extends State<_Sos911Button>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.heavyImpact();
    setState(() => _pressed = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.isAr
        ? 'اتصل بالرقم 911 او بلغ عن حالة طوارئ'
        : 'Call 911 or report an emergency';

    return Column(children: [
      Text(hint,
          style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF888888))),
      const SizedBox(height: 10),
      ScaleTransition(
        scale: _pressed ? const AlwaysStoppedAnimation(1.0) : _pulse,
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE53935).withOpacity(0.12),
            ),
            child: Center(
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935).withOpacity(0.20),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 105, height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pressed
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE53935),
                      boxShadow: [
                        BoxShadow(
                          color: (_pressed
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE53935))
                              .withOpacity(0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _pressed
                          ? Text('✓',
                              style: GoogleFonts.cairo(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white))
                          : Text(
                              widget.isAr
                                  ? '(( 911 ))'
                                  : '(( 911 ))',
                              style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}


// ════════════════════════════════════════════════════════
//  _AiToggleBtn — زر تبديل المساعد الذكي
// ════════════════════════════════════════════════════════
class _AiToggleBtn extends StatelessWidget {
  final bool isAr, isOpen;
  final VoidCallback onTap;
  const _AiToggleBtn({required this.isAr, required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: isOpen
              ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0288D1)])
              : null,
          color: isOpen ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isOpen
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: isOpen
                  ? AppColors.primary.withOpacity(0.3)
                  : const Color(0x0A000000),
              blurRadius: 8, offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            isOpen ? Icons.smart_toy_rounded : Icons.smart_toy_outlined,
            color: isOpen ? Colors.white : AppColors.primary,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            isAr
                ? (isOpen ? 'إخفاء المساعد' : 'المساعد الذكي')
                : (isOpen ? 'Hide Assistant' : 'AI Assistant'),
            style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isOpen ? Colors.white : AppColors.primary),
          ),
          const SizedBox(width: 4),
          AnimatedRotation(
            duration: const Duration(milliseconds: 250),
            turns: isOpen ? 0.5 : 0,
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: isOpen ? Colors.white : AppColors.primary, size: 16),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _AiChatPanel — لوحة المساعد الذكي
// ════════════════════════════════════════════════════════
class _AiChatPanel extends StatelessWidget {
  final bool isAr, typing, voiceOn;
  final List<ChatMessage> messages;
  final ScrollController scrollCtrl;
  final TextEditingController inputCtrl;
  final List<_QR> quickReplies;
  final List<_EService> services;
  final ValueChanged<String> onSend;
  final VoidCallback onClose;
  final VoidCallback onToggleVoice;

  const _AiChatPanel({
    required this.isAr, required this.typing,
    required this.messages, required this.scrollCtrl,
    required this.inputCtrl, required this.quickReplies,
    required this.services, required this.voiceOn,
    required this.onSend, required this.onClose,
    required this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 4)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _ChatHeader(
          isAr: isAr,
          voiceOn: voiceOn,
          onClose: onClose,
          onToggleVoice: onToggleVoice,
        ),
        _MiniServicesRow(services: services, isAr: isAr, onTap: onSend),
        _QuickRepliesRow(quickReplies: quickReplies, onTap: onSend),
        Expanded(
          child: ListView.builder(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            itemCount: messages.length + (typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == messages.length && typing) return const TypingBubble();
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ChatBubble(msg: messages[i]),
              );
            },
          ),
        ),
        _ChatInputBar(isAr: isAr, controller: inputCtrl, onSend: onSend),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _ChatHeader — هيدر لوحة المساعد
// ════════════════════════════════════════════════════════
class _ChatHeader extends StatelessWidget {
  final bool isAr, voiceOn;
  final VoidCallback onClose;
  final VoidCallback onToggleVoice;
  const _ChatHeader({
    required this.isAr,
    required this.voiceOn,
    required this.onClose,
    required this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          isAr ? 'مساعد إغاثة الذكي' : 'AI Emergency Assistant',
          style: GoogleFonts.cairo(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(
          isAr ? 'متاح 24/7 · يحدد موقعك تلقائياً' : 'Available 24/7 · Auto-locates you',
          style: GoogleFonts.cairo(fontSize: 9.5, color: Colors.white60)),
      ])),
      Container(width: 8, height: 8,
          decoration: const BoxDecoration(
              color: Color(0xFF69F0AE), shape: BoxShape.circle)),
      const SizedBox(width: 8),
      // ── زر تشغيل/إيقاف الصوت ─────────────────────────
      GestureDetector(
        onTap: onToggleVoice,
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
          child: Icon(
            voiceOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onClose,
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
          child: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    ]),
  );
}

// ════════════════════════════════════════════════════════
//  _MiniServicesRow — شريط الخدمات الصغير داخل المحادثة
// ════════════════════════════════════════════════════════
class _MiniServicesRow extends StatelessWidget {
  final List<_EService> services;
  final bool isAr;
  final ValueChanged<String> onTap;
  const _MiniServicesRow(
      {required this.services, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final s = services[i];
          return _MiniServiceChip(
            service: s, isAr: isAr,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(isAr ? s.msgAr : s.msgEn);
            },
          );
        },
      ),
    );
  }
}

class _MiniServiceChip extends StatefulWidget {
  final _EService service;
  final bool isAr;
  final VoidCallback onTap;
  const _MiniServiceChip(
      {required this.service, required this.isAr, required this.onTap});
  @override
  State<_MiniServiceChip> createState() => _MiniServiceChipState();
}

class _MiniServiceChipState extends State<_MiniServiceChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: s.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: s.shadow, blurRadius: 6, offset: const Offset(0, 2))
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              widget.isAr ? s.labelAr : s.labelEn,
              style: GoogleFonts.cairo(
                  fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _QuickRepliesRow — ردود سريعة
// ════════════════════════════════════════════════════════
class _QuickRepliesRow extends StatelessWidget {
  final List<_QR> quickReplies;
  final ValueChanged<String> onTap;
  const _QuickRepliesRow({required this.quickReplies, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 34,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      itemCount: quickReplies.length,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (_, i) {
        final qr = quickReplies[i];
        return GestureDetector(
          onTap: () => onTap(qr.msg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.18)),
            ),
            child: Text(qr.label,
                style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        );
      },
    ),
  );
}

// ════════════════════════════════════════════════════════
//  _ChatInputBar — شريط الإدخال
// ════════════════════════════════════════════════════════
class _ChatInputBar extends StatelessWidget {
  final bool isAr;
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  const _ChatInputBar(
      {required this.isAr, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 7, 10, 10),
    decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F2F5)))),
    child: Row(children: [
      Expanded(
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE0E4EA)),
          ),
          child: TextField(
            controller: controller,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.cairo(fontSize: 12.5, color: AppColors.textDark),
            onSubmitted: onSend,
            decoration: InputDecoration(
              hintText:
                  isAr ? 'اكتب رسالتك...' : 'Type your message...',
              hintStyle: GoogleFonts.cairo(
                  fontSize: 11.5, color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
      ),
      const SizedBox(width: 7),
      GestureDetector(
        onTap: () => onSend(controller.text),
        child: Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child:
              const Icon(Icons.send_rounded, color: Colors.white, size: 17),
        ),
      ),
    ]),
  );
}

// ════════════════════════════════════════════════════════
//  _ServicesGrid — شبكة الخدمات
// ════════════════════════════════════════════════════════
class _ServicesGrid extends StatelessWidget {
  final List<_EService> services;
  final bool isAr;
  final ValueChanged<_EService> onTap;
  const _ServicesGrid(
      {required this.services, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 0.9,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
    ),
    itemCount: services.length,
    itemBuilder: (_, i) => _ServiceBtn(
        service: services[i], isAr: isAr, onTap: () => onTap(services[i])),
  );
}

class _ServiceBtn extends StatefulWidget {
  final _EService service;
  final bool isAr;
  final VoidCallback onTap;
  const _ServiceBtn(
      {required this.service, required this.isAr, required this.onTap});
  @override
  State<_ServiceBtn> createState() => _ServiceBtnState();
}

class _ServiceBtnState extends State<_ServiceBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEF0F4)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: s.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                          color: s.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Center(
                      child: Text(s.emoji,
                          style: const TextStyle(fontSize: 21))),
                ),
                const SizedBox(height: 7),
                Text(
                  widget.isAr ? s.labelAr : s.labelEn,
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2636),
                      height: 1.1),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isAr ? s.subAr : s.subEn,
                  style: GoogleFonts.cairo(
                      fontSize: 9.5, color: const Color(0xFF888888)),
                  textAlign: TextAlign.center,
                ),
              ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  _TipRow — تلميح أسفل الخدمات
// ════════════════════════════════════════════════════════
class _TipRow extends StatelessWidget {
  final bool isAr;
  const _TipRow({required this.isAr});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFFCC80)),
    ),
    child: Row(children: [
      const Icon(Icons.tips_and_updates_rounded,
          color: Color(0xFFE65100), size: 13),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          isAr
              ? 'اضغط الخدمة المناسبة للمساعدة الفورية — موقعك يُرسل تلقائياً'
              : 'Tap the appropriate service — location auto-sent',
          style: GoogleFonts.cairo(
              fontSize: 10.5,
              color: const Color(0xFFE65100),
              height: 1.35),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]),
  );
}

// ════════════════════════════════════════════════════════
//  _SLabel — عنوان القسم
// ════════════════════════════════════════════════════════
class _SLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _SLabel(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7)),
      child: Icon(icon, color: color, size: 14),
    ),
    const SizedBox(width: 8),
    Text(label,
        style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark)),
  ]);
}

// ════════════════════════════════════════════════════════
//  نماذج البيانات
// ════════════════════════════════════════════════════════
class _EService {
  final String emoji, labelAr, labelEn, subAr, subEn;
  final List<Color> colors;
  final Color shadow;
  final String msgAr, msgEn;
  const _EService({
    required this.emoji,
    required this.labelAr, required this.labelEn,
    required this.subAr,   required this.subEn,
    required this.colors,  required this.shadow,
    required this.msgAr,   required this.msgEn,
  });
}

class _QR {
  final String label, msg;
  const _QR({required this.label, required this.msg});
}