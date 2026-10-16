import 'package:flutter/material.dart';
import 'app_theme.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: kText,
                    fontSize: 16.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.2)),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4)),
              child: Text(action!,
                  style: const TextStyle(
                      color: kPrimary, fontWeight: FontWeight.w700)),
            ),
        ],
      );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(12), this.margin, this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Material(
          color: color ?? kSurface,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Padding(padding: padding, child: child),
        ),
      );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 46, this.light = false});
  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: light ? Colors.white.withValues(alpha: .14) : kPrimaryLight,
          borderRadius: BorderRadius.circular(size * .3),
        ),
        child: Icon(Icons.eco_rounded,
            color: light ? Colors.white : kPrimary, size: size * .56),
      );
}

class AppStateCard extends StatelessWidget {
  const AppStateCard({super.key, required this.icon, required this.title, required this.message, this.action, this.compact = false});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.all(compact ? 12 : 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kTextSoft, size: compact ? 26 : 34),
            SizedBox(height: compact ? 8 : 12),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kText, fontSize: compact ? 11 : 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kTextSoft, fontSize: compact ? 9 : 12, height: 1.4)),
            if (action != null) ...[const SizedBox(height: 8), action!],
          ],
        ),
      );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(text,
              style: const TextStyle(
                  color: kText, fontSize: 13.8, fontWeight: FontWeight.w700)),
          if (required)
            const Text(' *', style: TextStyle(color: kDanger, fontSize: 14.9)),
        ]),
      );
}

class InlineNotice extends StatelessWidget {
  const InlineNotice({super.key, required this.message, this.icon = Icons.info_outline_rounded});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEE5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE9DDCA)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 17.7, color: kWarning),
          const SizedBox(width: 7),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: kText, fontSize: 12.5, height: 1.4))),
        ]),
      );
}
