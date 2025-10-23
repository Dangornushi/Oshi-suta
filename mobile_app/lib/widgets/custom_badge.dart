import 'package:flutter/material.dart';

enum BadgeVariant {
  solid,
  outline,
}

class CustomBadge extends StatelessWidget {
  final String text;
  final Widget? child;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final BadgeVariant variant;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const CustomBadge({
    Key? key,
    this.text = '',
    this.child,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.variant = BadgeVariant.solid,
    this.padding,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final defaultTextColor = textColor ?? Colors.white;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: variant == BadgeVariant.solid ? defaultBgColor : Colors.transparent,
        border: variant == BadgeVariant.outline
            ? Border.all(color: borderColor ?? defaultBgColor, width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: child ??
          Text(
            text,
            style: TextStyle(
              color: variant == BadgeVariant.solid
                  ? defaultTextColor
                  : (textColor ?? defaultBgColor),
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
    );
  }
}
