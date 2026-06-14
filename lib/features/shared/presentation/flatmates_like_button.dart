import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

/// A heart like/favorite toggle with an animated scale-pop on tap.
///
/// Shows a filled red heart when [liked] and an outline otherwise.
/// The pop animation respects reduced-motion. State (liked/unliked) is
/// owned by the caller — [onTap] should flip it optimistically.
class FlatmatesLikeButton extends StatefulWidget {
  const FlatmatesLikeButton({
    required this.liked,
    required this.onTap,
    super.key,
    this.size = 36,
    this.iconSize = 18,
    this.backgroundColor = Colors.black38,
    this.unlikedColor = Colors.white,
    this.likedColor = Colors.red,
    this.radius = 10,
    this.tooltip = 'Like',
  });

  final bool liked;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color unlikedColor;
  final Color likedColor;
  final double radius;
  final String tooltip;

  @override
  State<FlatmatesLikeButton> createState() => _FlatmatesLikeButtonState();
}

class _FlatmatesLikeButtonState extends State<FlatmatesLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.standard,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.3,
        ).chain(CurveTween(curve: AppMotion.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1,
        ).chain(CurveTween(curve: AppMotion.easeOutCubic)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!AppMotion.reduceMotion(context)) {
      _controller.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ScaleTransition(
        scale: _scale,
        child: IconButton(
          onPressed: _handleTap,
          padding: EdgeInsets.zero,
          tooltip: widget.tooltip,
          icon: Icon(
            widget.liked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            size: widget.iconSize,
            color: widget.liked ? widget.likedColor : widget.unlikedColor,
          ),
          style: IconButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        ),
      ),
    );
  }
}
