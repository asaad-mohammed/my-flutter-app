// ════════════════════════════════════════════════════════
//  tabs/profile_tab.dart  — النسخة المُعاد تصميمها (مُصلحة)
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/models/family_member.dart';
import '../../core/data/mock_users.dart';
import '../../core/providers/app_providers.dart';
import '../login_screen.dart';
import '../widgets/family/add_member_sheet.dart';
import '../widgets/family/emergency_for_member_sheet.dart';
import '../widgets/family/family_card_widget.dart';
import '../widgets/shared_widgets.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _logout() {
    ref.read(sessionProvider.notifier).logout();
    ref.read(authProvider.notifier).resetError();
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const LoginScreen(),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _openAddMember() {
    final isAr = ref.read(languageProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberSheet(isAr: isAr, ref: ref),
    );
  }

  void _openEmergencyForMember(FamilyMember m) {
    final isAr = ref.read(languageProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmergencySheet(patient: m, ref: ref, isAr: isAr),
    );
  }

  void _updateStatus(String id, MemberStatus status) {
    ref.read(familyProvider.notifier).updateStatus(id, status);
  }

  @override
  Widget build(BuildContext context) {
    final isAr     = ref.watch(languageProvider);
    final user     = ref.watch(sessionProvider);
    final family   = ref.watch(familyProvider);
    final members  = family.members;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _logout());
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: FadeTransition(
          opacity: _fade,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  s: AppStrings.of(isAr),
                  user: user,
                  onLogout: _logout,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _IDCard(user: user, members: members, isAr: isAr),
                    const SizedBox(height: 14),
                    _HealthCard(user: user, isAr: isAr),
                    const SizedBox(height: 14),
                    _FamilyCard(
                      members: members,
                      isAr: isAr,
                      onAddMember: _openAddMember,
                      onEmergency: _openEmergencyForMember,
                      onSafe: _updateStatus,
                      onProfile: (m) => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => _MemberDetailScreen(member: m, isAr: isAr))),
                    ),
                    const SizedBox(height: 14),
                    _TrustCircleCard(user: user, isAr: isAr),
                    const SizedBox(height: 22),
                    _LogoutBtn(isAr: isAr, onTap: _logout),
                    const SizedBox(height: 16),
                  ]),
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
//  _IDCard (نفسه بدون تغيير)
// ════════════════════════════════════════════════════════
class _IDCard extends StatefulWidget {
  final MockUser user;
  final List<FamilyMember> members;
  final bool isAr;
  const _IDCard({required this.user, required this.members, required this.isAr});
  @override State<_IDCard> createState() => _IDCardState();
}

class _IDCardState extends State<_IDCard> with SingleTickerProviderStateMixin {
  late AnimationController _shine;
  @override void initState() {
    super.initState();
    _shine = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }
  @override void dispose() { _shine.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final safeCount = widget.members.where((m) => m.status == MemberStatus.safe).length;
    final sosCount  = widget.members.where((m) => m.status == MemberStatus.sos).length;

    return AnimatedBuilder(
      animation: _shine,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0288D1).withValues(alpha: 0.28),
                blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF003C6E), Color(0xFF01579B), Color(0xFF0288D1), Color(0xFF29B6F6)],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5),
                    ),
                    child: Center(
                      child: Text(
                        widget.user.nameAr.isNotEmpty ? widget.user.nameAr[0] : 'إ',
                        style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.user.nameAr,
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(widget.user.nameEn,
                      style: GoogleFonts.cairo(fontSize: 11, color: Colors.white60)),
                    const SizedBox(height: 6),
                    Row(children: [
                      _MiniTag(label: widget.user.bloodType, icon: Icons.bloodtype_rounded),
                      const SizedBox(width: 6),
                      _MiniTag(label: '${widget.user.age} ${widget.isAr ? "سنة" : "yrs"}', icon: Icons.cake_rounded),
                    ]),
                  ])),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 26)),
                ]),
                const SizedBox(height: 14),
                Container(height: 0.5, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _CardInfoItem(
                    icon: Icons.badge_outlined, color: Colors.white,
                    label: widget.isAr ? 'رقم الهوية' : 'National ID',
                    value: widget.user.id,
                  )),
                  Container(width: 0.5, height: 40, color: Colors.white.withValues(alpha: 0.2)),
                  Expanded(child: _CardInfoItem(
                    icon: Icons.phone_rounded, color: Colors.white,
                    label: widget.isAr ? 'الهاتف' : 'Phone',
                    value: widget.user.phone,
                  )),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _FamilyStat(value: '${widget.members.length}', label: widget.isAr ? 'أفراد العائلة' : 'Family'),
                      Container(width: 0.5, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                      _FamilyStat(value: '$safeCount', label: widget.isAr ? 'بأمان' : 'Safe', color: const Color(0xFF81C784)),
                      if (sosCount > 0) ...[
                        Container(width: 0.5, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                        _FamilyStat(value: '$sosCount', label: widget.isAr ? 'تنبيه' : 'Alert', color: const Color(0xFFEF9A9A)),
                      ],
                    ],
                  ),
                ),
              ]),
            ),
            Positioned.fill(child: IgnorePointer(child: CustomPaint(
              painter: _ShinePainter(progress: _shine.value)))),
            Positioned(top: -40, right: -40, child: Container(width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)))),
            Positioned(bottom: -30, left: -20, child: Container(width: 90, height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)))),
          ]),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label; final IconData icon;
  const _MiniTag({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: Colors.white70),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
    ]),
  );
}

class _CardInfoItem extends StatelessWidget {
  final IconData icon; final Color color; final String label, value;
  const _CardInfoItem({required this.icon, required this.color, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 11, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.cairo(fontSize: 9.5, color: color.withValues(alpha: 0.6))),
      ]),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _FamilyStat extends StatelessWidget {
  final String value, label; final Color? color;
  const _FamilyStat({required this.value, required this.label, this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900,
        color: color ?? Colors.white, height: 1)),
    Text(label, style: GoogleFonts.cairo(fontSize: 9, color: Colors.white54)),
  ]);
}

class _ShinePainter extends CustomPainter {
  final double progress;
  const _ShinePainter({required this.progress});
  @override
  void paint(Canvas c, Size s) {
    final x = -s.width * 0.3 + progress * (s.width * 1.6);
    c.drawRect(Rect.fromLTWH(x - 40, 0, 80, s.height), Paint()
      ..shader = LinearGradient(colors: [Colors.transparent, Colors.white.withValues(alpha: 0.06), Colors.transparent])
          .createShader(Rect.fromLTWH(x - 40, 0, 80, s.height)));
  }
  @override bool shouldRepaint(_ShinePainter o) => o.progress != progress;
}

// ════════════════════════════════════════════════════════
//  _HealthCard (مُصلح - إزالة isMale)
// ════════════════════════════════════════════════════════
class _HealthCard extends StatelessWidget {
  final MockUser user;
  final bool isAr;
  const _HealthCard({required this.user, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      icon: Icons.favorite_rounded,
      iconColor: AppColors.pinkHeart,
      title: isAr ? 'المعلومات الصحية' : 'Health Profile',
      child: Column(children: [
        Row(children: [
          Expanded(child: _DetailTile(
            icon: Icons.flag_rounded, color: AppColors.primary,
            label: isAr ? 'الجنسية' : 'Nationality',
            value: user.nationality,
          )),
          const SizedBox(width: 10),
          Expanded(child: _DetailTile(
            icon: Icons.person_rounded, color: AppColors.accent,
            label: isAr ? 'الجنس' : 'Gender',
            value: user.gender,  // ✅ مصلح: استخدام gender بدلاً من isMale
          )),
        ]),
        const SizedBox(height: 10),
        if (user.chronicDiseases.isNotEmpty && user.chronicDiseases != 'لا يوجد')
          _HealthRow(
            icon: Icons.monitor_heart_rounded, color: AppColors.danger,
            label: isAr ? 'الأمراض المزمنة' : 'Chronic Diseases',
            value: user.chronicDiseases,
          ),
        if (user.allergies.isNotEmpty && user.allergies != 'لا يوجد') ...[
          const SizedBox(height: 8),
          _HealthRow(
            icon: Icons.warning_rounded, color: AppColors.warning,
            label: isAr ? 'الحساسية' : 'Allergies',
            value: user.allergies,
          ),
        ],
      ]),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon; final Color color; final String label, value;
  const _DetailTile({required this.icon, required this.color, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.15))),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 9.5, color: AppColors.textGray)),
        Text(value, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
            overflow: TextOverflow.ellipsis),
      ])),
    ]),
  );
}

class _HealthRow extends StatelessWidget {
  final IconData icon; final Color color; final String label; final String value;
  const _HealthRow({required this.icon, required this.color, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.18))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textGray)),
        Text(value, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ])),
    ]),
  );
}

// ════════════════════════════════════════════════════════
//  _FamilyCard (مُصلح - onSafe يستقبل id فقط)
// ════════════════════════════════════════════════════════
class _FamilyCard extends StatelessWidget {
  final List<FamilyMember> members;
  final bool isAr;
  final VoidCallback onAddMember;
  final Function(FamilyMember) onEmergency;
  final Function(String, MemberStatus) onSafe;
  final Function(FamilyMember) onProfile;

  const _FamilyCard({
    required this.members, required this.isAr,
    required this.onAddMember, required this.onEmergency,
    required this.onSafe, required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      icon: Icons.family_restroom_rounded,
      iconColor: AppColors.success,
      title: isAr ? 'أفراد العائلة' : 'Family Members',
      trailing: GestureDetector(
        onTap: onAddMember,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(isAr ? 'إضافة' : 'Add', style: GoogleFonts.cairo(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        ),
      ),
      child: members.isEmpty
          ? _EmptyFamily(isAr: isAr, onAdd: onAddMember)
          : Column(children: [
              ...members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FamilyCardWidget(
                  member: m, isAr: isAr,
                  onSOS: () => onEmergency(m),
                  onSafe: () => onSafe(m.id, MemberStatus.safe),  // ✅ مصلح
                  onProfile: () => onProfile(m),
                ),
              )),
            ]),
    );
  }
}

class _EmptyFamily extends StatelessWidget {
  final bool isAr; final VoidCallback onAdd;
  const _EmptyFamily({required this.isAr, required this.onAdd});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: const Icon(Icons.family_restroom_rounded, size: 30, color: AppColors.success)),
      const SizedBox(height: 10),
      Text(isAr ? 'لا يوجد أفراد مضافون بعد' : 'No family members added yet',
        style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textGray)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded, size: 16),
        label: Text(isAr ? 'أضف فرداً الآن' : 'Add a member now',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), elevation: 0),
      ),
    ]),
  );
}

// ════════════════════════════════════════════════════════
//  _TrustCircleCard (نفسه)
// ════════════════════════════════════════════════════════
class _TrustCircleCard extends ConsumerStatefulWidget {
  final MockUser user;
  final bool isAr;
  const _TrustCircleCard({required this.user, required this.isAr});
  @override ConsumerState<_TrustCircleCard> createState() => _TrustCircleCardState();
}

class _TrustCircleCardState extends ConsumerState<_TrustCircleCard> {
  late List<_TrustContact> _contacts;
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contacts = [
      if (widget.user.emergencyContact.isNotEmpty && widget.user.emergencyPhone.isNotEmpty)
        _TrustContact(
          name: widget.user.emergencyContact,
          phone: widget.user.emergencyPhone,
          relation: widget.isAr ? 'جهة الثقة الرئيسية' : 'Primary Contact',
        ),
    ];
  }

  @override void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  void _addContact() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTrustContactSheet(
        isAr: widget.isAr,
        nameCtrl: _nameCtrl,
        phoneCtrl: _phoneCtrl,
        onSave: (name, phone, rel) {
          setState(() => _contacts.add(_TrustContact(name: name, phone: phone, relation: rel)));
          _nameCtrl.clear(); _phoneCtrl.clear();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeContact(int i) {
    HapticFeedback.lightImpact();
    setState(() => _contacts.removeAt(i));
  }

  void _callContact(String phone) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.call_rounded, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(widget.isAr ? 'جاري الاتصال بـ $phone...' : 'Calling $phone...',
          style: GoogleFonts.cairo(color: Colors.white)),
      ]),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      icon: Icons.groups_rounded,
      iconColor: AppColors.accent,
      title: widget.isAr ? 'دائرة الثقة' : 'Circle of Trust',
      trailing: GestureDetector(
        onTap: _addContact,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(widget.isAr ? 'إضافة' : 'Add', style: GoogleFonts.cairo(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
          ]),
        ),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(child: Text(
              widget.isAr
                  ? 'عند إرسال نداء استغاثة سيُتصل بهؤلاء الأشخاص تلقائياً مع إرسال موقعك'
                  : 'When you send a distress call, these contacts are automatically notified with your location',
              style: GoogleFonts.cairo(fontSize: 10.5, color: AppColors.accent, height: 1.5),
            )),
          ]),
        ),
        const SizedBox(height: 12),
        if (_contacts.isEmpty)
          _EmptyTrust(isAr: widget.isAr, onAdd: _addContact)
        else
          ..._contacts.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TrustContactTile(
              contact: e.value,
              isAr: widget.isAr,
              onCall: () => _callContact(e.value.phone),
              onRemove: () => _removeContact(e.key),
            ),
          )),
      ]),
    );
  }
}

class _TrustContact {
  final String name, phone, relation;
  const _TrustContact({required this.name, required this.phone, required this.relation});
}

class _TrustContactTile extends StatelessWidget {
  final _TrustContact contact;
  final bool isAr;
  final VoidCallback onCall, onRemove;
  const _TrustContactTile({required this.contact, required this.isAr, required this.onCall, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    const avatarColors = [
      Color(0xFFB5D4F4), Color(0xFFC0DD97), Color(0xFFFFCDD2),
      Color(0xFFE1BEE7), Color(0xFFB2EBF2), Color(0xFFFFE082),
    ];
    final avBg = avatarColors[contact.name.hashCode.abs() % avatarColors.length];
    final initials = contact.name.trim().split(' ').take(2).map((p) => p[0]).join();

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDF4), width: 0.5),
        boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: avBg, shape: BoxShape.circle),
          child: Center(child: Text(initials, style: GoogleFonts.cairo(
              fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A2332))))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(contact.name, style: GoogleFonts.cairo(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          Text(contact.relation, style: GoogleFonts.cairo(fontSize: 10.5, color: AppColors.textGray)),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.phone_rounded, size: 11, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(contact.phone, style: GoogleFonts.cairo(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
          ]),
        ])),
        GestureDetector(
          onTap: onCall,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
          ),
        ),
      ]),
    );
  }
}

class _EmptyTrust extends StatelessWidget {
  final bool isAr; final VoidCallback onAdd;
  const _EmptyTrust({required this.isAr, required this.onAdd});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onAdd,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), style: BorderStyle.solid)),
      child: Column(children: [
        const Icon(Icons.group_add_rounded, size: 36, color: AppColors.accent),
        const SizedBox(height: 8),
        Text(isAr ? 'أضف أشخاصاً تثق بهم' : 'Add people you trust',
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
        Text(isAr ? 'سيُتصل بهم عند إرسال استغاثة' : 'They\'ll be called when you send SOS',
          style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray)),
      ]),
    ),
  );
}

// ── شيت إضافة جهة ثقة ─────────────────────────────────────
class _AddTrustContactSheet extends StatefulWidget {
  final bool isAr;
  final TextEditingController nameCtrl, phoneCtrl;
  final Function(String, String, String) onSave;
  const _AddTrustContactSheet({required this.isAr, required this.nameCtrl,
      required this.phoneCtrl, required this.onSave});
  @override State<_AddTrustContactSheet> createState() => _AddTrustContactSheetState();
}

class _AddTrustContactSheetState extends State<_AddTrustContactSheet> {
  String _relation = '';
  final _relations = ['أب/أم', 'أخ/أخت', 'زوج/زوجة', 'صديق مقرب', 'جار', 'زميل', 'أخرى'];
  final _relationsEn = ['Parent', 'Sibling', 'Spouse', 'Close Friend', 'Neighbor', 'Colleague', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE0E7F0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(widget.isAr ? 'إضافة جهة ثقة' : 'Add Trusted Contact',
            style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _Field(ctrl: widget.nameCtrl, hint: widget.isAr ? 'الاسم الكامل' : 'Full Name',
              icon: Icons.person_rounded),
          const SizedBox(height: 10),
          _Field(ctrl: widget.phoneCtrl, hint: widget.isAr ? 'رقم الهاتف' : 'Phone Number',
              icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          Align(alignment: widget.isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(widget.isAr ? 'صلة القرابة / العلاقة' : 'Relation',
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGray))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7, runSpacing: 7,
            children: (widget.isAr ? _relations : _relationsEn).map((r) {
              final sel = r == _relation;
              return GestureDetector(
                onTap: () => setState(() => _relation = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.accent : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.accent : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(r, style: GoogleFonts.cairo(
                      fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                      color: sel ? Colors.white : AppColors.textGray)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (widget.nameCtrl.text.isEmpty || widget.phoneCtrl.text.isEmpty) return;
                widget.onSave(
                  widget.nameCtrl.text.trim(),
                  widget.phoneCtrl.text.trim(),
                  _relation.isEmpty ? (widget.isAr ? 'جهة ثقة' : 'Trusted Contact') : _relation,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0),
              child: Text(widget.isAr ? 'حفظ جهة الاتصال' : 'Save Contact',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl; final String hint; final IconData icon;
  final TextInputType? keyboardType;
  const _Field({required this.ctrl, required this.hint, required this.icon, this.keyboardType});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, keyboardType: keyboardType,
    style: GoogleFonts.cairo(fontSize: 13),
    decoration: InputDecoration(
      hintText: hint, hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: AppColors.textHint),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textGray),
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

// ════════════════════════════════════════════════════════
//  _LogoutBtn
// ════════════════════════════════════════════════════════
class _LogoutBtn extends StatelessWidget {
  final bool isAr; final VoidCallback onTap;
  const _LogoutBtn({required this.isAr, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.logout_rounded, size: 18),
    label: Text(isAr ? 'تسجيل الخروج' : 'Logout',
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.danger,
      side: const BorderSide(color: AppColors.danger),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

// ════════════════════════════════════════════════════════
//  _SectionBox
// ════════════════════════════════════════════════════════
class _SectionBox extends StatelessWidget {
  final IconData icon; final Color iconColor; final String title;
  final Widget child; final Widget? trailing;
  const _SectionBox({
    required this.icon, required this.iconColor,
    required this.title, required this.child, this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 12, offset: Offset(0, 3))],
    ),
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 17, color: iconColor)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: GoogleFonts.cairo(
              fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark))),
          if (trailing != null) trailing!,
        ]),
      ),
      Container(height: 0.5, color: const Color(0xFFF0F3F8)),
      Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 14), child: child),
    ]),
  );
}

// ════════════════════════════════════════════════════════
//  _MemberDetailScreen
// ════════════════════════════════════════════════════════
class _MemberDetailScreen extends StatelessWidget {
  final FamilyMember member; final bool isAr;
  const _MemberDetailScreen({required this.member, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg, elevation: 0,
        title: Text(isAr ? member.nameAr : member.nameEn,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF0288D1).withValues(alpha: 0.28),
                  blurRadius: 18, offset: const Offset(0, 8))]),
            child: Column(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2)),
                child: Center(child: Text(member.initials,
                  style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)))),
              const SizedBox(height: 10),
              Text(isAr ? member.nameAr : member.nameEn,
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${member.relationLabel(isAr)} · ${member.age} ${isAr ? "سنة" : "yrs"} · ${member.bloodLabel()}',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70)),
              if (member.emergencyNote != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(member.emergencyNote!,
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.white))),
                  ])),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          if (member.chronicDiseases.isNotEmpty || member.allergies.isNotEmpty || member.currentMeds.isNotEmpty)
            _SectionBox(
              icon: Icons.medical_information_rounded, iconColor: AppColors.danger,
              title: isAr ? 'الملف الطبي' : 'Medical Profile',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.send_rounded, size: 12, color: AppColors.danger),
                    const SizedBox(width: 6),
                    Text(isAr ? 'يُرسل تلقائياً مع أي بلاغ طوارئ' : 'Auto-sent with every emergency report',
                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  ])),
                const SizedBox(height: 10),
                if (member.chronicDiseases.isNotEmpty)
                  _MedTag(icon: Icons.monitor_heart_rounded, color: AppColors.danger,
                      label: isAr ? 'أمراض مزمنة' : 'Chronic', items: member.chronicDiseases),
                if (member.allergies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _MedTag(icon: Icons.warning_rounded, color: AppColors.warning,
                      label: isAr ? 'حساسيات' : 'Allergies', items: member.allergies),
                ],
                if (member.currentMeds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _MedTag(icon: Icons.medication_rounded, color: AppColors.primary,
                      label: isAr ? 'أدوية دائمة' : 'Medications', items: member.currentMeds),
                ],
              ]),
            ),
        ]),
      ),
    );
  }
}

class _MedTag extends StatelessWidget {
  final IconData icon; final Color color; final String label; final List<String> items;
  const _MedTag({required this.icon, required this.color, required this.label, required this.items});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, size: 13, color: color), const SizedBox(width: 6),
      Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    ]),
    const SizedBox(height: 6),
    Wrap(spacing: 6, runSpacing: 6, children: items.map((s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(s, style: GoogleFonts.cairo(fontSize: 12, color: color)))).toList()),
  ]);
}