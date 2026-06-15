// ════════════════════════════════════════════════════════
//  widgets/profile_widgets.dart
//  ويدجت خاصة بتبويب "معلوماتك"
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/data/mock_users.dart';
import 'shared_widgets.dart';

// ════════════════════════════════════════════════════════
//  ProfileCard — بطاقة الملف الشخصي الكاملة
// ════════════════════════════════════════════════════════
class ProfileCard extends StatelessWidget {
  final MockUser user;
  final bool isAr;

  const ProfileCard({super.key, required this.user, required this.isAr});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Column(children: [
          _ProfileCardHeader(user: user),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              // ── بيانات شخصية ──
              InfoTileRow([
                InfoTile(Icons.badge_outlined,   isAr ? 'رقم الهوية' : 'ID',             user.id,          AppColors.primary),
                InfoTile(Icons.cake_outlined,     isAr ? 'تاريخ الميلاد' : 'Date of Birth', user.dateOfBirth, AppColors.secondary),
              ]),
              const SizedBox(height: 9),
              InfoTileRow([
                InfoTile(Icons.flag_outlined,    isAr ? 'الجنسية' : 'Nationality', user.nationality, AppColors.accent),
                InfoTile(Icons.wc_rounded,       isAr ? 'الجنس' : 'Gender',       user.gender,      const Color(0xFF7B1FA2)),
              ]),
              const SizedBox(height: 9),
              InfoTileRow([
                InfoTile(Icons.phone_outlined,   isAr ? 'رقم الجوال' : 'Phone', user.phone, AppColors.actionAppt),
                InfoTile(Icons.email_outlined,   isAr ? 'البريد' : 'Email',     user.email, const Color(0xFFF57F17)),
              ]),

              // ── معلومات صحية ──
              const InfoDivider(),
              SectionTitle(
                icon: Icons.medical_information_rounded,
                label: isAr ? 'المعلومات الصحية' : 'Health Info',
                color: AppColors.pinkHeart,
              ),
              const SizedBox(height: 9),
              HealthInfoRow(Icons.coronavirus_outlined,
                  isAr ? 'الأمراض المزمنة' : 'Chronic Diseases', user.chronicDiseases, AppColors.pinkHeart),
              const SizedBox(height: 7),
              HealthInfoRow(Icons.warning_amber_rounded,
                  isAr ? 'الحساسية' : 'Allergies', user.allergies, AppColors.warning),

              // ── التأمين الصحي ──
              const InfoDivider(),
              SectionTitle(
                icon: Icons.security_rounded,
                label: isAr ? 'التأمين الصحي' : 'Health Insurance',
                color: AppColors.accent,
              ),
              const SizedBox(height: 9),
              InfoTileRow([
                InfoTile(Icons.credit_card_rounded, isAr ? 'رقم التأمين' : 'Insurance No.', user.insuranceNumber, AppColors.accent),
                InfoTile(Icons.event_outlined,       isAr ? 'تاريخ الانتهاء' : 'Expiry',    user.insuranceExpiry, AppColors.warning),
              ]),

              // ── جهة الاتصال في الطوارئ ──
              const InfoDivider(),
              SectionTitle(
                icon: Icons.emergency_rounded,
                label: isAr ? 'طوارئ — جهة الاتصال' : 'Emergency Contact',
                color: AppColors.pinkHeart,
              ),
              const SizedBox(height: 9),
              InfoTileRow([
                InfoTile(Icons.person_outline_rounded, isAr ? 'الاسم والعلاقة' : 'Name & Relation', user.emergencyContact, AppColors.pinkHeart),
                InfoTile(Icons.phone_in_talk_outlined, isAr ? 'رقم الطوارئ' : 'Emergency Phone',   user.emergencyPhone,   AppColors.pinkHeart),
              ]),
            ]),
          ),
        ]),
      );
}

// ── رأس بطاقة الملف الشخصي ────────────────────────────────
class _ProfileCardHeader extends StatelessWidget {
  final MockUser user;
  const _ProfileCardHeader({required this.user});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.cardGradientBlue,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(children: [
          _AvatarCircle(user.nameAr),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.nameAr,
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(user.nameEn,
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70)),
            ]),
          ),
          _BloodBadge(user.bloodType),
        ]),
      );
}

class _AvatarCircle extends StatelessWidget {
  final String name;
  const _AvatarCircle(this.name);

  @override
  Widget build(BuildContext context) => Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(50),
          border: Border.all(color: Colors.white.withAlpha(100), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: GoogleFonts.cairo(
            fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
          ),
        ),
      );
}

class _BloodBadge extends StatelessWidget {
  final String type;
  const _BloodBadge(this.type);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.favorite_rounded, color: AppColors.pinkHeart, size: 13),
          const SizedBox(width: 4),
          Text(type,
              style: GoogleFonts.cairo(
                  fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.pinkHeart)),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  InfoTileRow — صف من بطاقتين معلومات متجاورتين
// ════════════════════════════════════════════════════════
class InfoTileRow extends StatelessWidget {
  final List<InfoTile> tiles;
  const InfoTileRow(this.tiles, {super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: tiles
            .expand((t) => [Expanded(child: t), if (t != tiles.last) const SizedBox(width: 9)])
            .toList(),
      );
}

// ════════════════════════════════════════════════════════
//  InfoTile — بطاقة معلومة واحدة (أيقونة + عنوان + قيمة)
// ════════════════════════════════════════════════════════
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const InfoTile(this.icon, this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textGray),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 1),
              Text(value,
                  style: GoogleFonts.cairo(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  HealthInfoRow — صف معلومة صحية (عريض)
// ════════════════════════════════════════════════════════
class HealthInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const HealthInfoRow(this.icon, this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(38)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray)),
              Text(value,
                  style: GoogleFonts.cairo(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ]),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  QuickActionItem — زر الإجراء السريع (أفقي)
// ════════════════════════════════════════════════════════
class QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const QuickActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {},
        child: Container(
          width: 78,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            boxShadow: const [
              BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
      );
}

// ════════════════════════════════════════════════════════
//  VitalsCard — بطاقة العلامات الحيوية
// ════════════════════════════════════════════════════════
class VitalsCard extends StatelessWidget {
  final AppStrings s;

  const VitalsCard({super.key, required this.s});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.cardGradientBlue,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(64),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s.vitals,
                style: GoogleFonts.cairo(
                    fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('الآن',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 13),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _VitalSign(Icons.favorite_rounded,   '72',   'BPM', 'القلب'),
            _VitalDivider(),
            _VitalSign(Icons.water_drop_rounded, '98',   '%',   'SpO₂'),
            _VitalDivider(),
            _VitalSign(Icons.thermostat_rounded, '36.8', '°C',  'الحرارة'),
          ]),
        ]),
      );
}

class _VitalSign extends StatelessWidget {
  final IconData icon;
  final String value, unit, label;
  const _VitalSign(this.icon, this.value, this.unit, this.label);

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: Colors.white70, size: 15),
        const SizedBox(height: 3),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 20, fontWeight: FontWeight.w900,
                  color: Colors.white, height: 1)),
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Text(unit,
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white60)),
          ),
        ]),
        Text(label, style: GoogleFonts.cairo(fontSize: 10, color: Colors.white60)),
      ]);
}

class _VitalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 42, color: Colors.white.withAlpha(50));
}

// ════════════════════════════════════════════════════════
//  EmergencyBanner — شريط الطوارئ (911)
// ════════════════════════════════════════════════════════
class EmergencyBanner extends StatelessWidget {
  final MockUser user;
  final bool isAr;

  const EmergencyBanner({super.key, required this.user, required this.isAr});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.emergencyGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withAlpha(70),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isAr ? 'طوارئ' : 'Emergency',
                style: GoogleFonts.cairo(
                    fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Text(
                '${isAr ? "جهة الاتصال:" : "Contact:"} ${user.emergencyContact}',
                style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.danger,
              elevation: 0,
              minimumSize: const Size(56, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('911',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.danger)),
          ),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  AppointmentCard — بطاقة الموعد القادم
// ════════════════════════════════════════════════════════
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.cardGradientBlue),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('15',
                  style: GoogleFonts.cairo(
                      fontSize: 16, fontWeight: FontWeight.w900,
                      color: Colors.white, height: 1)),
              Text('أبر',
                  style: GoogleFonts.cairo(fontSize: 9, color: Colors.white70)),
            ]),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('د. أحمد محمد',
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text('طب عام · مستشفى الملك فهد',
                  style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textGray)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text('10:30 ص',
                style: GoogleFonts.cairo(
                    fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ]),
      );
}