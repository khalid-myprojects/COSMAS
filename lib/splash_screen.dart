import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 900),
            pageBuilder: (_, __, ___) => const WelcomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020510),
      body: Stack(
        children: [
          // Starfield
          ...List.generate(200, (i) {
            final rand = Random(i);
            return Positioned(
              left: rand.nextDouble() * MediaQuery.of(context).size.width,
              top: rand.nextDouble() * MediaQuery.of(context).size.height,
              child: Container(
                width: rand.nextDouble() * 2.5,
                height: rand.nextDouble() * 2.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(rand.nextDouble() * 0.8 + 0.2),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(
                duration: Duration(
                    milliseconds: (rand.nextDouble() * 2000 + 1000).toInt()),
                begin: 0.1,
                end: 0.9,
              ),
            );
          }),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rotating rings + sun
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Container(
                          width: 160 + _pulseController.value * 20,
                          height: 160 + _pulseController.value * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.25),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Orbit rings
                      ...[70.0, 90.0, 110.0].map((r) => Container(
                        width: r,
                        height: r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.07),
                            width: 1,
                          ),
                        ),
                      )),

                      // Orbiting dot
                      AnimatedBuilder(
                        animation: _rotateController,
                        builder: (_, __) {
                          final angle = _rotateController.value * 2 * pi;
                          return Transform.translate(
                            offset: Offset(
                              90 * cos(angle),
                              90 * sin(angle),
                            ),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xff42a5f5),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    const Color(0xff42a5f5).withOpacity(0.8),
                                    blurRadius: 12,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Sun
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Container(
                          width: 55 + _pulseController.value * 6,
                          height: 55 + _pulseController.value * 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xfffff9c4),
                                Color(0xffff9800),
                                Color(0xffff5722),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.8),
                                blurRadius: 30,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(
                  duration: 1200.ms,
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                )
                    .fade(duration: 800.ms),

                const SizedBox(height: 48),

                // App title
                const Text(
                  'COSMOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 14,
                  ),
                )
                    .animate()
                    .fade(delay: 600.ms, duration: 800.ms)
                    .slideY(begin: 0.4, end: 0),

                const SizedBox(height: 8),

                Text(
                  'SOLAR SYSTEM EXPLORER',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 15,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w700,
                  ),
                )
                    .animate()
                    .fade(delay: 900.ms, duration: 800.ms)
                    .slideY(begin: 0.4, end: 0),

                const SizedBox(height: 60),

                // Loading bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (_, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            minHeight: 3,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xffff9800),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Initializing universe...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 1200.ms, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}