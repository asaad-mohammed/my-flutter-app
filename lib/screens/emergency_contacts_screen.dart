// ════════════════════════════════════════════════════════
//  screens/emergency_contacts_screen.dart
//  شاشة جهات اتصال الطوارئ
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/providers/app_providers.dart';

// نموذج جهة الاتصال
class _EmergencyContact {
  final String name, phone, relation, icon;
  final Color color;

  const _EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
    required this.icon,
    required this.color,
  });
}

class EmergencyContactsScreen extends ConsumerStatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  ConsumerState<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends ConsumerState<EmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  // بيانات جهات الاتصال الرسمية
  final List<_EmergencyContact> _officialContacts = const [
    _EmergencyContact(
      name: 'الإسعاف الطارئ',
      phone: '122',
      relation: 'طب طارئ',
      icon: '🚑',
      color: Color(0xFFE53935),
    ),
    _EmergencyContact(
      name: 'الدفاع المدني',
      phone: '115',
      relation: 'إطفاء وإنقاذ',
      icon: '🚒',
      color: Color(0xFFE65100),
    ),
    _EmergencyContact(
      name: 'الشرطة',
      phone: '104',
      relation: 'أمن وسلامة',
      icon: '👮',
      color: Color(0xFF1565C0),
    ),
    _EmergencyContact(
      name: 'الدفاع المدني - خط طوارئ',
      phone: '911',
      relation: 'طوارئ شاملة',
      icon: '🆘',
      color: Color(0xFF6A1B9A),
    ),
  ];

  // جهات الاتصال الشخصية (ستُحمَّل من قاعدة البيانات)
  final List<_EmergencyContact> _personalContacts = const [
    _EmergencyContact(
      name: 'أحمد محمد (الأب)',
      phone: '+964 770 123 4567',
      relation: 'الأب',
      icon: '👨',
      color: Color(0xFF0288D1),
    ),
    _EmergencyContact(
      name: 'فاطمة أحمد (الأم)',
      phone: '+964 771 234 5678',
      relation: 'الأم',
      icon: '👩',
      color: Color(0xFFAD1457),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _callNumber(String phone, BuildContext context) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري الاتصال بـ $phone...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── الهيدر ──
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.headerGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                title: Text(
                  isAr ? 'جهات اتصال الطوارئ' : 'Emergency Contacts',
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── بنر تحذيري ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFCC80)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFE65100), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'في حالات الطوارئ الحرجة اتصل بـ 122 فوراً'
                              : 'In critical emergencies call 122 immediately',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: const Color(0xFFE65100),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // ── أرقام رسمية ──
                  _SectionTitle(
                    label: isAr ? '🏛️ الأرقام الرسمية' : '🏛️ Official Numbers',
                  ),
                  const SizedBox(height: 12),
                  ..._officialContacts.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ContactCard(
                          contact: c,
                          isAr: isAr,
                          onCall: () => _callNumber(c.phone, context),
                          isOfficial: true,
                        ),
                      )),

                  const SizedBox(height: 20),

                  // ── جهات شخصية ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle(
                        label:
                            isAr ? '👨‍👩‍👧 جهاتي الشخصية' : '👨‍👩‍👧 My Personal Contacts',
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddContactSheet(context, isAr),
                        icon: const Icon(Icons.add_circle_outline_rounded,
                            size: 16),
                        label: Text(isAr ? 'إضافة' : 'Add',
                            style: GoogleFonts.cairo(fontSize: 12)),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._personalContacts.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ContactCard(
                          contact: c,
                          isAr: isAr,
                          onCall: () => _callNumber(c.phone, context),
                        ),
                      )),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactSheet(BuildContext context, bool isAr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddContactSheet(isAr: isAr),
    );
  }
}

// ── عنوان القسم ────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      );
}

// ── بطاقة جهة الاتصال ──────────────────────────────────
class _ContactCard extends StatelessWidget {
  final _EmergencyContact contact;
  final bool isAr;
  final VoidCallback onCall;
  final bool isOfficial;

  const _ContactCard({
    required this.contact,
    required this.isAr,
    required this.onCall,
    this.isOfficial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOfficial
              ? contact.color.withOpacity(0.25)
              : const Color(0xFFE8EDF4),
        ),
        boxShadow: [
          BoxShadow(
            color: isOfficial
                ? contact.color.withOpacity(0.08)
                : const Color(0x0A000000),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        // أيقونة
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: contact.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(contact.icon,
                style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 13),

        // معلومات
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.name,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                contact.relation,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: AppColors.textGray),
              ),
              const SizedBox(height: 3),
              Text(
                contact.phone,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: contact.color,
                ),
              ),
            ],
          ),
        ),

        // زر الاتصال
        GestureDetector(
          onTap: onCall,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [contact.color, contact.color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: contact.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.phone_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ]),
    );
  }
}

// ── شيت إضافة جهة اتصال ───────────────────────────────
class _AddContactSheet extends StatelessWidget {
  final bool isAr;
  const _AddContactSheet({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAr ? 'إضافة جهة اتصال طارئة' : 'Add Emergency Contact',
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            // حقل الاسم
            _buildField(isAr ? 'الاسم الكامل' : 'Full Name',
                Icons.person_outline_rounded),
            const SizedBox(height: 12),
            // حقل الهاتف
            _buildField(
                isAr ? 'رقم الهاتف' : 'Phone Number', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            // حقل العلاقة
            _buildField(
                isAr ? 'صلة القرابة' : 'Relationship', Icons.group_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  isAr ? 'حفظ جهة الاتصال' : 'Save Contact',
                  style: GoogleFonts.cairo(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textGray),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
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
}