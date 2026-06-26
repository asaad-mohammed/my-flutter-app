// ════════════════════════════════════════════════════════
//  widgets/protection_widgets.dart
//  ويدجت خاصة بتبويب "الحماية"
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

// ════════════════════════════════════════════════════════
//  StatsCards — بطاقات الإحصائيات
// ════════════════════════════════════════════════════════
class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.description_rounded,
            count: '3',
            label: isAr ? 'بلاغات معلقة' : 'Pending Reports',
            color: const Color(0xFFE53935),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            count: '12',
            label: isAr ? 'تم حلها' : 'Resolved',
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.videocam_rounded,
            count: '5',
            label: isAr ? 'اتصالات سابقة' : 'Past Calls',
            color: const Color(0xFF1E88E5),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String count, label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(count,
              style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textGray)),
        ]),
      );
}

// ════════════════════════════════════════════════════════
//  ReportFormCard — بطاقة نموذج بلاغ
// ════════════════════════════════════════════════════════
class ReportFormCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final List<String> fields;

  const ReportFormCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.fields,
  });

  @override
  State<ReportFormCard> createState() => _ReportFormCardState();
}

class _ReportFormCardState extends State<ReportFormCard> {
  bool _expanded = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        onExpansionChanged: (val) => setState(() => _expanded = val),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: widget.color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(widget.icon, color: widget.color, size: 20),
        ),
        title: Text(widget.title,
            style: GoogleFonts.cairo(
                fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        subtitle: Text(widget.subtitle,
            style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray)),
        trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.textGray),
        children: [
          ...widget.fields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _controllers[field],
                  maxLines: field.contains('تفاصيل') || field.contains('Details') || field.contains('الواقعة') ? 3 : 1,
                  decoration: InputDecoration(
                    labelText: field,
                    labelStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.textGray),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _submitReport(context);
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(isAr ? 'إرسال البلاغ' : 'Submit Report',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // إرفاق ملفات
                },
                icon: const Icon(Icons.attach_file_rounded, color: AppColors.textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('✓ ${widget.title}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: Text(
          'تم استلام بلاغك وسيتم مراجعته في أقرب وقت',
          style: GoogleFonts.cairo(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('حسناً', style: GoogleFonts.cairo(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  EmergencyReportButton — زر البلاغ الطارئ
// ════════════════════════════════════════════════════════
class EmergencyReportButton extends StatelessWidget {
  const EmergencyReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return InkWell(
      onTap: () {
        HapticFeedback.heavyImpact();
        showDialog(
          context: context,
          builder: (_) => const EmergencyReportDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD32F2F).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              isAr ? '🚨 بلاغ طارئ عاجل' : '🚨 Emergency Report',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  EmergencyAgenciesGrid — شبكة جهات الاتصال الطارئة
// ════════════════════════════════════════════════════════
class EmergencyAgenciesGrid extends StatelessWidget {
  const EmergencyAgenciesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final List<Map<String, dynamic>> agencies = [
      {'icon': Icons.local_police_rounded, 'color': const Color(0xFF1A237E), 'label': isAr ? 'شرطة' : 'Police'},
      {'icon': Icons.local_hospital_rounded, 'color': const Color(0xFFC62828), 'label': isAr ? 'إسعاف' : 'Ambulance'},
      {'icon': Icons.fire_extinguisher_rounded, 'color': const Color(0xFFE65100), 'label': isAr ? 'إطفاء' : 'Fire'},
      {'icon': Icons.electrical_services_rounded, 'color': const Color(0xFFF9A825), 'label': isAr ? 'كهرباء' : 'Electricity'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: agencies.length,
      itemBuilder: (ctx, i) {
        final item = agencies[i];
        return _AgencyCard(
          icon: item['icon'],
          color: item['color'],
          label: item['label'],
          onTap: () => _startVideoCall(ctx, item['label']),
        );
      },
    );
  }

  void _startVideoCall(BuildContext context, String agency) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VideoCallDialog(agency: agency),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AgencyCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 5),
              Text(label,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  )),
            ],
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════
//  QuickCallButton — زر اتصال سريع (جميع الجهات)
// ════════════════════════════════════════════════════════
class QuickCallButton extends StatelessWidget {
  const QuickCallButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return OutlinedButton.icon(
      onPressed: () {
        // بدء اتصال مع جميع الجهات
      },
      icon: const Icon(Icons.call_rounded, color: AppColors.primary),
      label: Text(
        isAr ? '📞 اتصال طارئ (جميع الجهات)' : '📞 Emergency Call (All Agencies)',
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  VideoCallDialog — واجهة الاتصال بالفيديو
// ════════════════════════════════════════════════════════
class VideoCallDialog extends StatefulWidget {
  final String agency;

  const VideoCallDialog({super.key, required this.agency});

  @override
  State<VideoCallDialog> createState() => _VideoCallDialogState();
}

class _VideoCallDialogState extends State<VideoCallDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _isConnected = false;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isConnected = true);
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && _isConnected) {
          setState(() => _callDuration++);
          return true;
        }
        return false;
      });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _saveRecording();
    super.dispose();
  }

  void _saveRecording() {
    // TODO: حفظ التسجيل في جهاز المستخدم
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black87,
        ),
        child: Column(
          children: [
            // شريط الحالة العلوي
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  Text(
                    _isConnected
                        ? _formatDuration(_callDuration)
                        : isAr ? 'جارٍ الاتصال...' : 'Connecting...',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert_rounded, color: Colors.white),
                ],
              ),
            ),

            const Spacer(),

            // معلومات الاتصال
            Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isConnected ? Colors.green : Colors.red,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isConnected ? Colors.green : Colors.red)
                              .withOpacity(0.4 * _pulseCtrl.value),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        _isConnected ? Icons.videocam_rounded : Icons.call_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.agency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isConnected
                      ? isAr ? 'متصل' : 'Connected'
                      : isAr ? 'جاري الاتصال...' : 'Connecting...',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),

            const Spacer(),

            // أزرار التحكم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallControlButton(
                    icon: Icons.mic_rounded,
                    isActive: true,
                    onTap: () {},
                  ),
                  _CallControlButton(
                    icon: Icons.videocam_rounded,
                    isActive: true,
                    onTap: () {},
                  ),
                  _CallControlButton(
                    icon: Icons.screen_share_rounded,
                    isActive: false,
                    onTap: () {},
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = (seconds / 60).floor();
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CallControlButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.white54,
            size: 24,
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════
//  ReportsHistorySheet — سجل البلاغات
// ════════════════════════════════════════════════════════
class ReportsHistorySheet extends StatelessWidget {
  final bool isAr;

  const ReportsHistorySheet({super.key, required this.isAr});

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isAr ? '📋 سجل البلاغات' : '📋 Reports History',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: i % 2 == 0 ? AppColors.primary : AppColors.danger,
                      radius: 16,
                      child: Icon(
                        i % 2 == 0 ? Icons.check_rounded : Icons.pending_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    title: Text(
                      i % 2 == 0
                          ? isAr ? 'بلاغ قضائي #00${i + 1}' : 'Legal Report #00${i + 1}'
                          : isAr ? 'بلاغ عشائري #00${i + 1}' : 'Tribal Report #00${i + 1}',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      '${isAr ? 'تاريخ' : 'Date'}: ${DateTime.now().subtract(Duration(days: i)).toString().substring(0, 10)}',
                      style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textGray),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: i % 2 == 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        i % 2 == 0
                            ? isAr ? 'مكتمل' : 'Completed'
                            : isAr ? 'قيد المعالجة' : 'Processing',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: i % 2 == 0 ? Colors.green.shade800 : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════
//  EmergencyReportDialog — حوار البلاغ الطارئ
// ════════════════════════════════════════════════════════
class EmergencyReportDialog extends StatefulWidget {
  const EmergencyReportDialog({super.key});

  @override
  State<EmergencyReportDialog> createState() => _EmergencyReportDialogState();
}

class _EmergencyReportDialogState extends State<EmergencyReportDialog> {
  final TextEditingController _descCtrl = TextEditingController();
  String _selectedType = 'قضائي';

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final types = isAr ? ['قضائي', 'عشائري', 'إداري'] : ['Legal', 'Tribal', 'Administrative'];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Color(0xFFD32F2F)),
          const SizedBox(width: 8),
          Text(
            isAr ? '🚨 بلاغ طارئ' : '🚨 Emergency Report',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: types.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (val) => setState(() => _selectedType = val!),
            decoration: InputDecoration(
              labelText: isAr ? 'نوع البلاغ' : 'Report Type',
              labelStyle: GoogleFonts.cairo(color: AppColors.textGray),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: isAr ? 'تفاصيل الطوارئ' : 'Emergency Details',
              labelStyle: GoogleFonts.cairo(color: AppColors.textGray),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: isAr ? 'اكتب تفاصيل الحالة الطارئة...' : 'Write emergency details...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isAr ? 'إلغاء' : 'Cancel',
              style: GoogleFonts.cairo(color: AppColors.textGray)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('✓ ${isAr ? 'تم الإرسال' : 'Sent'}',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.green)),
                content: Text(isAr ? 'تم إرسال البلاغ الطارئ بنجاح' : 'Emergency report sent successfully',
                    style: GoogleFonts.cairo()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('حسناً', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(isAr ? 'إرسال الطوارئ' : 'Send Emergency',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}