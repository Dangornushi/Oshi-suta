import 'package:flutter/material.dart';

class CustomProgress extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;

  const CustomProgress({
    Key? key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 100.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clampedValue / 100,
          child: Container(
            decoration: BoxDecoration(
              color: gradient == null ? (foregroundColor ?? Theme.of(context).primaryColor) : null,
              gradient: gradient,
            ),
          ),
        ),
      ),
    );
  }
}
