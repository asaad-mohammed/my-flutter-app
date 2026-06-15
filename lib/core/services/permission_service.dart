// ════════════════════════════════════════════════════════
//  core/services/permission_service.dart
//  خدمة إدارة جميع أذونات التطبيق
//  الأذونات: موقع | كاميرا | مايكروفون | جهات اتصال
//
//  pubspec.yaml - أضف:
//    permission_handler: ^11.3.1
//    geolocator: ^12.0.0
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/app_colors.dart';

// ════════════════════════════════════════════════════════
//  نموذج إذن واحد
// ════════════════════════════════════════════════════════
class AppPermission {
  final Permission permission;
  final String nameAr;
  final String nameEn;
  final String descAr;
  final String descEn;
  final IconData icon;
  final Color color;
  final bool isRequired; // مطلوب أم اختياري

  const AppPermission({
    required this.permission,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
    required this.icon,
    required this.color,
    this.isRequired = false,
  });
}

// ════════════════════════════════════════════════════════
//  PermissionService — منطق الأذونات
// ════════════════════════════════════════════════════════
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  // ── قائمة الأذونات المطلوبة ──────────────────────────
  static const List<AppPermission> appPermissions = [
    AppPermission(
      permission: Permission.locationWhenInUse,
      nameAr: 'تحديد الموقع',
      nameEn: 'Location',
      descAr: 'لعرض مواقع الطوارئ القريبة منك وإرسال موقعك عند الاستغاثة',
      descEn: 'To show nearby emergency services and share your location during SOS',
      icon: Icons.location_on_rounded,
      color: Color(0xFF1565C0),
      isRequired: true,
    ),
    AppPermission(
      permission: Permission.camera,
      nameAr: 'الكاميرا',
      nameEn: 'Camera',
      descAr: 'لالتقاط صور الحوادث ومشاركتها مع فرق الإنقاذ',
      descEn: 'To capture incident photos and share with rescue teams',
      icon: Icons.camera_alt_rounded,
      color: Color(0xFF7B1FA2),
      isRequired: false,
    ),
    AppPermission(
      permission: Permission.microphone,
      nameAr: 'المايكروفون',
      nameEn: 'Microphone',
      descAr: 'للتواصل الصوتي مع مركز الطوارئ عند الحاجة',
      descEn: 'For voice communication with emergency center',
      icon: Icons.mic_rounded,
      color: Color(0xFFE65100),
      isRequired: false,
    ),
    AppPermission(
      permission: Permission.contacts,
      nameAr: 'جهات الاتصال',
      nameEn: 'Contacts',
      descAr: 'لإضافة جهات اتصال الطوارئ وإخطارهم تلقائياً عند الخطر',
      descEn: 'To add emergency contacts and notify them automatically',
      icon: Icons.contacts_rounded,
      color: Color(0xFF2E7D32),
      isRequired: false,
    ),
  ];

  // ── طلب إذن واحد ────────────────────────────────────
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return status;
    }
    return await permission.request();
  }

  // ── طلب جميع الأذونات ────────────────────────────────
  Future<Map<Permission, PermissionStatus>> requestAll() async {
    final permissions = appPermissions.map((p) => p.permission).toList();
    return await permissions.request();
  }

  // ── فحص حالة إذن واحد ───────────────────────────────
  Future<PermissionStatus> checkStatus(Permission permission) async {
    return await permission.status;
  }

  // ── فحص جميع الأذونات ───────────────────────────────
  Future<Map<Permission, PermissionStatus>> checkAll() async {
    final Map<Permission, PermissionStatus> statuses = {};
    for (final p in appPermissions) {
      statuses[p.permission] = await p.permission.status;
    }
    return statuses;
  }

  // ── طلب إذن الموقع مع منطق geolocator ──────────────
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ── نص الحالة بالعربي ────────────────────────────────
  static String statusTextAr(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'مُفعّل ✓';
      case PermissionStatus.denied:
        return 'مرفوض';
      case PermissionStatus.permanentlyDenied:
        return 'محظور دائماً';
      case PermissionStatus.restricted:
        return 'مقيّد';
      case PermissionStatus.limited:
        return 'جزئي';
      default:
        return 'غير محدد';
    }
  }

  static String statusTextEn(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Enabled ✓';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      default:
        return 'Unknown';
    }
  }

  static Color statusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return const Color(0xFF2E7D32);
      case PermissionStatus.limited:
        return const Color(0xFFE65100);
      default:
        return const Color(0xFFE53935);
    }
  }
}

// ════════════════════════════════════════════════════════
//  PermissionsScreen — شاشة طلب الأذونات الكاملة
//  استدعِها مرة واحدة بعد تسجيل الدخول
// ════════════════════════════════════════════════════════
class PermissionsScreen extends StatefulWidget {
  final bool isAr;
  final VoidCallback onDone;

  const PermissionsScreen({
    super.key,
    required this.isAr,
    required this.onDone,
  });

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  Map<Permission, PermissionStatus> _statuses = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _ctrl.forward();
    _loadStatuses();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatuses() async {
    final s = await PermissionService.instance.checkAll();
    if (mounted) setState(() => _statuses = s);
  }

  Future<void> _requestAll() async {
    setState(() => _loading = true);
    final s = await PermissionService.instance.requestAll();
    if (mounted) setState(() { _statuses = s; _loading = false; });
  }

  Future<void> _requestOne(Permission p) async {
    final status = await PermissionService.instance.requestPermission(p);
    if (mounted) setState(() => _statuses[p] = status);
  }

  bool get _requiredGranted {
    for (final p in PermissionService.appPermissions) {
      if (p.isRequired) {
        final s = _statuses[p.permission];
        if (s == null || !s.isGranted) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
            child: Column(
              children: [
                // ── هيدر ──
                _buildHeader(isAr),
                const SizedBox(height: 8),

                // ── قائمة الأذونات ──
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: PermissionService.appPermissions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final perm = PermissionService.appPermissions[i];
                      final status = _statuses[perm.permission];
                      return _PermissionTile(
                        perm: perm,
                        status: status,
                        isAr: isAr,
                        onRequest: () => _requestOne(perm.permission),
                      );
                    },
                  ),
                ),

                // ── أزرار القرار ──
                _buildActions(isAr),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.headerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              isAr ? 'أذونات التطبيق' : 'App Permissions',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'نحتاج الأذونات التالية لتقديم أفضل خدمة طوارئ ممكنة'
                  : 'We need the following permissions to provide the best emergency service',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                  fontSize: 13, color: Colors.white70, height: 1.4),
            ),
          ],
        ),
      );

  Widget _buildActions(bool isAr) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _requestAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        isAr ? 'السماح بجميع الأذونات' : 'Allow All Permissions',
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: widget.onDone,
              child: Text(
                isAr
                    ? (_requiredGranted ? 'متابعة' : 'تخطي (بعض الميزات قد لا تعمل)')
                    : (_requiredGranted ? 'Continue' : 'Skip (some features may not work)'),
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: _requiredGranted
                      ? AppColors.primary
                      : AppColors.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════
//  _PermissionTile — بطاقة إذن واحد
// ════════════════════════════════════════════════════════
class _PermissionTile extends StatelessWidget {
  final AppPermission perm;
  final PermissionStatus? status;
  final bool isAr;
  final VoidCallback onRequest;

  const _PermissionTile({
    required this.perm,
    required this.status,
    required this.isAr,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = status?.isGranted ?? false;
    final statusColor = PermissionService.statusColor(
        status ?? PermissionStatus.denied);
    final statusText = isAr
        ? PermissionService.statusTextAr(status ?? PermissionStatus.denied)
        : PermissionService.statusTextEn(status ?? PermissionStatus.denied);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGranted
              ? const Color(0xFF2E7D32).withOpacity(0.3)
              : Colors.transparent,
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الإذن
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: perm.color.withOpacity(isGranted ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(perm.icon,
                color: isGranted
                    ? perm.color
                    : perm.color.withOpacity(0.5),
                size: 24),
          ),
          const SizedBox(width: 14),

          // معلومات الإذن
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAr ? perm.nameAr : perm.nameEn,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (perm.isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAr ? 'مطلوب' : 'Required',
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isAr ? perm.descAr : perm.descEn,
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textGray,
                      height: 1.4),
                ),
                const SizedBox(height: 5),
                // حالة الإذن
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // زر السماح / الإعدادات
          if (!isGranted)
            GestureDetector(
              onTap: onRequest,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: perm.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAr
                      ? (status?.isPermanentlyDenied == true
                          ? 'الإعدادات'
                          : 'سماح')
                      : (status?.isPermanentlyDenied == true
                          ? 'Settings'
                          : 'Allow'),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF2E7D32), size: 18),
            ),
        ],
      ),
    );
  }
}