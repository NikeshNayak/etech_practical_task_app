import 'package:flutter/material.dart';

class ShimmerView extends StatefulWidget {
  final double? height;
  final double? width;

  const ShimmerView({super.key, this.height, this.width});

  @override
  ShimmerViewState createState() => ShimmerViewState();
}

class ShimmerViewState extends State<ShimmerView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    gradientPosition = Tween<double>(
      begin: -3,
      end: 10,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(gradientPosition.value, 0),
          end: const Alignment(-1, 0),
          colors: const [
            Colors.black12,
            Colors.black26,
            Colors.black12,
          ],
        ),
      ),
    );
  }
}
