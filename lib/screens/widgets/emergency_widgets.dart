// ════════════════════════════════════════════════════════
//  widgets/emergency_widgets.dart
//  ويدجت خاصة بتبويب "طوارئ":
//  الهيدر، بنر التنبيه، أزرار الطوارئ، صندوق الدردشة
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/data/mock_users.dart';
import 'shared_widgets.dart';

// ════════════════════════════════════════════════════════
//  EmergencyHeader — هيدر تبويب الطوارئ
// ════════════════════════════════════════════════════════
class EmergencyHeader extends StatelessWidget {
  final bool isAr;
  final MockUser? user;

  const EmergencyHeader({super.key, required this.isAr, required this.user});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 14,
          left: 18, right: 18, bottom: 17,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.headerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isAr ? 'مركز الطوارئ 🚨' : 'Emergency Hub 🚨',
                style: GoogleFonts.cairo(
                    fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Text(
                isAr ? 'استجابة سريعة · 24/7' : 'Quick Response · 24/7',
                style: GoogleFonts.cairo(fontSize: 11, color: Colors.white60),
              ),
            ]),
          ),
          // بادج الحالة النشطة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF69F0AE),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isAr ? 'نشط' : 'Active',
                style: GoogleFonts.cairo(
                    fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          HeaderIconBtn(icon: Icons.notifications_outlined),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  EmergencyTipBox — بنر التنبيه التحذيري
// ════════════════════════════════════════════════════════
class EmergencyTipBox extends StatelessWidget {
  final bool isAr;

  const EmergencyTipBox({super.key, required this.isAr});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFFFCC80)),
        ),
        child: Row(children: [
          const Icon(Icons.tips_and_updates_rounded,
              color: Color(0xFFE65100), size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              isAr
                  ? 'اضغط الزر المناسب لطلب المساعدة الفورية. سيتم تحديد موقعك تلقائياً.'
                  : 'Tap the appropriate button to request immediate help. Your location will be shared automatically.',
              style: GoogleFonts.cairo(
                  fontSize: 11, color: const Color(0xFFE65100), height: 1.5),
            ),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  EmergencyButton — زر طوارئ واحد (مع أنيميشن ضغط)
// ════════════════════════════════════════════════════════
class EmergencyButton extends StatefulWidget {
  final String label, sub;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const EmergencyButton({
    super.key,
    required this.label,
    required this.sub,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: widget.colors.last.withAlpha(100),
                  blurRadius: 13,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 27),
                ),
                const SizedBox(height: 8),
                Text(widget.label,
                    style: GoogleFonts.cairo(
                        fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text(widget.sub,
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.white70),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════
//  ChatMessage — نموذج رسالة الدردشة
// ════════════════════════════════════════════════════════
class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage(this.text, this.isUser);
}

// ════════════════════════════════════════════════════════
//  AiChatCard — صندوق الدردشة مع الذكاء الاصطناعي
// ════════════════════════════════════════════════════════
class AiChatCard extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool typing;
  final ScrollController scrollCtrl;
  final TextEditingController chatCtrl;
  final bool isAr;
  final ValueChanged<String> onSend;

  const AiChatCard({
    super.key,
    required this.messages,
    required this.typing,
    required this.scrollCtrl,
    required this.chatCtrl,
    required this.isAr,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Column(children: [
          _ChatHeader(isAr: isAr),
          _ChatMessages(
            messages: messages,
            typing: typing,
            scrollCtrl: scrollCtrl,
          ),
          _ChatInput(
            chatCtrl: chatCtrl,
            isAr: isAr,
            onSend: onSend,
          ),
        ]),
      );
}

// ── رأس صندوق الدردشة ─────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final bool isAr;
  const _ChatHeader({required this.isAr});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
        ),
        child: Row(children: [
          Container(
            width: 37, height: 37,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isAr ? 'مساعد إغاثة الذكي' : 'AI Emergency Assistant',
                style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              Text(
                isAr ? 'متاح 24/7 · يحدد موقعك تلقائياً' : 'Available 24/7 · Auto-locates you',
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white60),
              ),
            ]),
          ),
          // مؤشر الاتصال
          Container(
            width: 9, height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFF69F0AE),
              shape: BoxShape.circle,
            ),
          ),
        ]),
      );
}

// ── قائمة الرسائل ──────────────────────────────────────────
class _ChatMessages extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool typing;
  final ScrollController scrollCtrl;

  const _ChatMessages({
    required this.messages,
    required this.typing,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 195,
        child: ListView.builder(
          controller: scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          itemCount: messages.length + (typing ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == messages.length && typing) return const TypingBubble();
            return ChatBubble(msg: messages[i]);
          },
        ),
      );
}

// ── حقل الإدخال ───────────────────────────────────────────
class _ChatInput extends StatelessWidget {
  final TextEditingController chatCtrl;
  final bool isAr;
  final ValueChanged<String> onSend;

  const _ChatInput({
    required this.chatCtrl,
    required this.isAr,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF0F2F5))),
        ),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 41,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: const Color(0xFFE0E4EA)),
              ),
              child: TextField(
                controller: chatCtrl,
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: isAr
                      ? 'اكتب رسالتك أو اضغط زر الطوارئ...'
                      : 'Type or press emergency button...',
                  hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                ),
                onSubmitted: onSend,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSend(chatCtrl.text),
            child: Container(
              width: 41, height: 41,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  ChatBubble — فقاعة رسالة
// ════════════════════════════════════════════════════════
class ChatBubble extends StatelessWidget {
  final ChatMessage msg;

  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          mainAxisAlignment:
              msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isUser) ...[
              const CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: msg.isUser ? AppColors.primary : const Color(0xFFEEF5FF),
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(14),
                    topRight:    const Radius.circular(14),
                    bottomLeft:  msg.isUser ? const Radius.circular(14) : const Radius.circular(4),
                    bottomRight: msg.isUser ? const Radius.circular(4)  : const Radius.circular(14),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.cairo(
                    fontSize: 13, height: 1.45,
                    color: msg.isUser ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
            if (msg.isUser) ...[
              const SizedBox(width: 5),
              const CircleAvatar(
                radius: 13,
                backgroundColor: Color(0xFF37474F),
                child: Icon(Icons.person, color: Colors.white, size: 14),
              ),
            ],
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════
//  TypingBubble — مؤشر "يكتب..."
// ════════════════════════════════════════════════════════
class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(children: [
          const CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _DotBounce(Duration(milliseconds: i * 165))),
            ),
          ),
        ]),
      );
}

// ── نقطة متحركة ───────────────────────────────────────────
class _DotBounce extends StatefulWidget {
  final Duration delay;
  const _DotBounce(this.delay);

  @override
  State<_DotBounce> createState() => _DotBounceState();
}

class _DotBounceState extends State<_DotBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 620));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: 7, height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFF90A4AE),
              AppColors.primary,
              _anim.value,
            ),
            shape: BoxShape.circle,
          ),
        ),
      );
}