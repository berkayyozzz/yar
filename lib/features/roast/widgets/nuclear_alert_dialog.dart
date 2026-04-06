import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NuclearAlertDialog extends StatefulWidget {
  const NuclearAlertDialog({super.key});

  @override
  State<NuclearAlertDialog> createState() => _NuclearAlertDialogState();
}

class _NuclearAlertDialogState extends State<NuclearAlertDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..repeat(reverse: true);
      
    HapticFeedback.heavyImpact();
    
    // Vibrate intensely
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 600), () => HapticFeedback.heavyImpact());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isRed = _controller.value > 0.5;
          final offset = Offset(
              Random().nextDouble() * 10 - 5, Random().nextDouble() * 10 - 5);
          return Container(
            color: isRed ? Colors.red.withValues(alpha: 0.9) : Colors.black87,
            child: Center(
              child: Transform.translate(
                offset: offset,
                child: child,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '☣️',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                'BUDGET EXCEEDED!!!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You are officially broke.\nStop buying things immediately!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('I ACCEPT MY SHAME', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showNuclearAlert(BuildContext context) {
  showDialog(
    context: context,
    useSafeArea: false,
    barrierDismissible: false,
    builder: (ctx) => const NuclearAlertDialog(),
  );
}
