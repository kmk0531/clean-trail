import 'package:flutter/material.dart';

class IosButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const IosButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.borderRadius = 14.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
  });

  @override
  State<IosButton> createState() => _IosButtonState();
}

class _IosButtonState extends State<IosButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final Color bgColor = widget.backgroundColor ?? const Color(0xFF2F7D4F);

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: isEnabled
            ? (_) {
                _controller.forward();
              }
            : null,
        onTapUp: isEnabled
            ? (_) {
                _controller.reverse();
              }
            : null,
        onTapCancel: isEnabled
            ? () {
                _controller.reverse();
              }
            : null,
        onTap: widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isEnabled ? bgColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: bgColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            padding: widget.padding,
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
