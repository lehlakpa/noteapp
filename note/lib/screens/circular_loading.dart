import 'package:flutter/material.dart';

/// A dedicated page for showing a circular loading indicator
/// during an artificial "fetch" delay.
class CircularLoadingPage extends StatefulWidget {
  final Duration delay;
  final Color color;
  final String? message;
  final bool autoSuccess;

  const CircularLoadingPage({
    super.key,
    required this.delay,
    this.color = const Color(0xFF2ECC71),
    this.message,
    this.autoSuccess = true,
  });

  @override
  State<CircularLoadingPage> createState() => _CircularLoadingPageState();
}

class _CircularLoadingPageState extends State<CircularLoadingPage> {
  @override
  void initState() {
    super.initState();

    // Simulate a fetch delay, then pop back.
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      Navigator.of(context).pop(widget.autoSuccess);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.message!,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A lightweight inline loading indicator for use inside widgets
/// (e.g. StreamBuilder loading states, button children).
class CircularLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const CircularLoadingIndicator({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
