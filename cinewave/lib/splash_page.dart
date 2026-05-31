import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    // Navigate to home page after a brief delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.dispose();
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Logo or Name
            Image(image:  AssetImage('assets/logo.png'), width: 100, height: 100),
            Text(
              'CineWave',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Optional: Add a loading indicator
            const SizedBox(height: 24),
            _DottedLoader(controller: _controller),
          ],
        ),
      ),
    );
  }
}

class _DottedLoader extends StatelessWidget {
  const _DottedLoader({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    const totalDots = 3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final anim = Tween<double>(begin: 0.4, end: 1)
            .animate(CurvedAnimation(parent: controller, curve: Interval(
          index / totalDots,
          (index + 1) / totalDots,
          curve: Curves.easeInOut,
        )));
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) {
            return Opacity(
              opacity: anim.value,
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}