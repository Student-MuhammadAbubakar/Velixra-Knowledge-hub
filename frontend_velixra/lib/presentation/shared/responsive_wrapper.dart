import 'package:flutter/material.dart';

/// Keeps the app's phone-style card layout at a comfortable, fixed width
/// on wide screens (web/desktop), centered with breathing room on either
/// side — instead of stretching edge-to-edge, which looks broken on a
/// desktop browser. On an actual phone-sized viewport, this has no
/// visible effect since the screen is already narrower than maxWidth.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveWrapper({super.key, required this.child, this.maxWidth = 480});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}