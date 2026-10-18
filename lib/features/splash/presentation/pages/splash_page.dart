import 'dart:async';
import 'package:flutter/material.dart';
import 'package:traker_task/features/news/presentation/pages/news_list_page.dart';
import '../widgets/brand_title.dart';
import '../widgets/pulse_logo.dart';
import '../widgets/splash_loader.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2800), _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;
    _timer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NewsListPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: GestureDetector(
        onTap: _navigateToHome,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 500;

              if (isCompact) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PulseLogo(
                                    size: 72,
                                    borderRadius: 18,
                                    showGlow: true,
                                  ),
                                  SizedBox(height: 14),
                                  BrandTitle(fontSize: 24),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const SplashLoader(),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PulseLogo(
                              size: 104,
                              borderRadius: 26,
                              showGlow: true,
                            ),
                            SizedBox(height: 28),
                            BrandTitle(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: SplashLoader(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
