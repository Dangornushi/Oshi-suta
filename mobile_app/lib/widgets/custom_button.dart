import 'package:flutter/material.dart';

enum ButtonVariant {
  solid,
  outline,
  ghost,
}

class CustomButton extends StatelessWidget {
  final String text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const CustomButton({
    Key? key,
    this.text = '',
    this.child,
    this.onPressed,
    this.variant = ButtonVariant.solid,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final defaultFgColor = foregroundColor ?? Colors.white;

    Widget buttonChild = child ??
        (icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
            : Text(text));

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: Material(
        color: variant == ButtonVariant.solid ? defaultBgColor : Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: variant == ButtonVariant.outline
                  ? Border.all(color: defaultBgColor, width: 1.5)
                  : null,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: variant == ButtonVariant.solid
                    ? defaultFgColor
                    : defaultBgColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              child: buttonChild,
            ),
          ),
        ),
      ),
    );
  }
}
