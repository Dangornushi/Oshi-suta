import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final VoidCallback? onTap;
  final double? elevation;
  final BorderRadius? borderRadius;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.gradient,
    this.border,
    this.onTap,
    this.elevation,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(elevation != null ? 0.1 : 0.05),
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
