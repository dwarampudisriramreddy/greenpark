import 'package:flutter/material.dart';

/// Fades + slides its child in once when it first appears on screen.
/// [delay] staggers sibling entrances for a cascading showcase effect.
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;
  final Curve curve;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.06),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
