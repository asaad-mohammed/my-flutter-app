// ════════════════════════════════════════════════════════
//  tabs/protection_tab.dart
//  تبويب "الحماية" — بلاغات + اتصال فيديو طارئ
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../widgets/protection_widgets.dart';

class ProtectionTab extends ConsumerStatefulWidget {
  const ProtectionTab({super.key});

  @override
  ConsumerState<ProtectionTab> createState() => _ProtectionTabState();
}

class _ProtectionTabState extends ConsumerState<ProtectionTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentSubTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _currentSubTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: Text(
              'الحماية',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 18,
                child: Text(
                  user != null ? user.nameAr.substring(0, 1) : 'ح',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: AppColors.textDark),
                onPressed: () {
                  _showReportsHistory(context);
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textGray,
                  labelStyle: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('البلاغات'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('اتصال فوري'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── المحتوى حسب التبويب الفرعي ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _currentSubTab == 0
                    ? const ReportsContent()
                    : const VideoCallContent(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportsHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ReportsHistorySheet(isAr: true),
    );
  }
}

// ════════════════════════════════════════════════════════
//  محتوى البلاغات
// ════════════════════════════════════════════════════════
class ReportsContent extends StatelessWidget {
  const ReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // بطاقة إحصائيات سريعة
        StatsCards(),
        SizedBox(height: 16),

        // نماذج البلاغات
        ReportFormCard(
          icon: Icons.gavel_rounded,
          color: Color(0xFF1A237E),
          title: 'بلاغ قضائي',
          subtitle: 'تقديم شكوى رسمية للجهات القضائية',
          fields: ['نوع البلاغ', 'تفاصيل الواقعة', 'المرفقات'],
        ),
        SizedBox(height: 12),

        ReportFormCard(
          icon: Icons.people_rounded,
          color: Color(0xFF4A148C),
          title: 'بلاغ عشائري',
          subtitle: 'حل النزاعات عبر الوساطة العشائرية',
          fields: ['الطرف الآخر', 'سبب النزاع', 'الوسيط المقترح'],
        ),
        SizedBox(height: 12),

        ReportFormCard(
          icon: Icons.account_balance_rounded,
          color: Color(0xFF004D40),
          title: 'بلاغ إداري',
          subtitle: 'تقديم شكوى للدوائر الحكومية',
          fields: ['الجهة المعنية', 'موضوع الشكوى', 'التفاصيل'],
        ),
        SizedBox(height: 12),

        // زر بلاغ طارئ
        EmergencyReportButton(),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  محتوى الاتصال الفوري
// ════════════════════════════════════════════════════════
class VideoCallContent extends StatelessWidget {
  const VideoCallContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // تحذير مهم
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFB74D)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'سيتم حفظ تسجيل المكالمة تلقائياً في جهازك بعد انتهاء الاتصال',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // شبكة جهات الاتصال
        const EmergencyAgenciesGrid(),
        const SizedBox(height: 20),

        // زر اتصال سريع (جميع الجهات)
        const QuickCallButton(),
      ],
    );
  }
}