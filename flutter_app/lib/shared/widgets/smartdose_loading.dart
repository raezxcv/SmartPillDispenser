import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SmartDoseLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const SmartDoseLoading({
    super.key,
    this.size = 120.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = size < 70;

    Widget animation = Lottie.asset(
      'assets/smartdose_loading.json',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Lottie.asset(
          'assets/SmartDose Loading.json',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => SizedBox(
            width: size * 0.6,
            height: size * 0.6,
            child: CircularProgressIndicator(
              color: color ?? const Color(0xFF00A36C),
              strokeWidth: 2.5,
            ),
          ),
        );
      },
    );

    if (color != null) {
      animation = ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: animation,
      );
    }

    if (isSmall) {
      animation = Transform.scale(
        scale: 2.6,
        child: animation,
      );
    }

    return Center(
      child: ClipRect(
        child: SizedBox(
          width: size,
          height: size,
          child: animation,
        ),
      ),
    );
  }
}
