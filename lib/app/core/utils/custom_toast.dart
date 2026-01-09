import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../values/app_colors.dart';

class CustomToast {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
  }) {
    if (_isShowing) {
      hide();
    }

    _isShowing = true;
    final context = Get.overlayContext!;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        icon: icon,
        onDismiss: hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto dismiss
    Future.delayed(duration, () {
      hide();
    });
  }

  static void hide() {
    if (_overlayEntry != null && _isShowing) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  // Convenience methods
  static void success(String message, {IconData? icon}) {
    show(message, type: ToastType.success, icon: icon ?? Icons.check_circle_rounded);
  }

  static void error(String message, {IconData? icon}) {
    show(message, type: ToastType.error, icon: icon ?? Icons.error_rounded);
  }

  static void warning(String message, {IconData? icon}) {
    show(message, type: ToastType.warning, icon: icon ?? Icons.warning_rounded);
  }

  static void info(String message, {IconData? icon}) {
    show(message, type: ToastType.info, icon: icon ?? Icons.info_rounded);
  }
}

enum ToastType { success, error, warning, info }

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final IconData? icon;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    this.icon,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (widget.type) {
      case ToastType.success:
        return isDark ? const Color(0xFF2D5A3D) : const Color(0xFF4CAF50);
      case ToastType.error:
        return isDark ? const Color(0xFF5A2D2D) : const Color(0xFFF44336);
      case ToastType.warning:
        return isDark ? const Color(0xFF5A4A2D) : AppColors.warning;
      case ToastType.info:
        return isDark ? const Color(0xFF2D4A5A) : AppColors.primary;
    }
  }

  Color _getTextColor() {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: _getTextColor(),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: _getTextColor(),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _controller.reverse().then((_) {
                            widget.onDismiss();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            color: _getTextColor().withOpacity(0.8),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}