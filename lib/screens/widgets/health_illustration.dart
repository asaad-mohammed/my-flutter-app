import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HealthIllustration extends StatefulWidget {
  const HealthIllustration({super.key});

  @override
  State<HealthIllustration> createState() => _HealthIllustrationState();
}

class _HealthIllustrationState extends State<HealthIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Card
          Positioned(
            top: 10,
            child: Container(
              width: 150,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          // Animated Heart
          Positioned(
            top: 25,
            child: ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: AppColors.pinkHeart,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),

          // Syringe
          Positioned(
            bottom: 12,
            left: 75,
            child: const _SyringeIcon(),
          ),

          // Check Mark
          Positioned(
            top: 55,
            right: 50,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.teal,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyringeIcon extends StatelessWidget {
  const _SyringeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Container(height: 6, color: Colors.grey[400]),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.teal.withOpacity(0.3),
                    AppColors.teal.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}