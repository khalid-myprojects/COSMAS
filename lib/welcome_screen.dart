import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _glowController;
  late AnimationController _rotateController;
  late AnimationController _nebulaController;
  late AnimationController _shootingStarController;
  bool _buttonPressed = false;

  // Shooting star data
  final List<_ShootingStar> _shootingStars = [];
  final Random _rand = Random(42);

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _shootingStarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    // Pre-generate shooting stars
    for (int i = 0; i < 5; i++) {
      _shootingStars.add(_ShootingStar(
        startX: _rand.nextDouble() * 400,
        startY: _rand.nextDouble() * 300,
        length: 80 + _rand.nextDouble() * 80,
        angle: -0.4 + _rand.nextDouble() * 0.3,
        delay: _rand.nextDouble(),
        speed: 0.6 + _rand.nextDouble() * 0.6,
      ));
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _nebulaController.dispose();
    _shootingStarController.dispose();
    super.dispose();
  }

  void _onExplore() {
    if (_buttonPressed) return;
    setState(() => _buttonPressed = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            // NO scale/zoom — pure clean fade only
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff020510),
      body: Stack(
        children: [
          // ── Layer 1: Static stars ──────────────────────────────
          ...List.generate(200, (i) {
            final r = Random(i * 11);
            final sz = r.nextDouble() * 2.0 + 0.3;
            return Positioned(
              left: r.nextDouble() * size.width,
              top: r.nextDouble() * size.height,
              child: Container(
                width: sz,
                height: sz,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(r.nextDouble() * 0.6 + 0.2),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(
                    duration: Duration(
                        milliseconds: (r.nextDouble() * 3500 + 800).toInt()),
                    begin: 0.08,
                    end: 0.95,
                  ),
            );
          }),

          // ── Layer 2: Animated nebula clouds ───────────────────
          AnimatedBuilder(
            animation: _nebulaController,
            builder: (_, __) {
              final v = _nebulaController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -60 + v * 20,
                    left: -40 + v * 15,
                    child: Container(
                      width: 360,
                      height: 360,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xffff6f00).withOpacity(0.06 + v * 0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200 - v * 15,
                    right: -80 + v * 10,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xff1565c0).withOpacity(0.07 + v * 0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80 + v * 10,
                    left: 20 - v * 8,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xff6a1b9a).withOpacity(0.055 + v * 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Layer 3: Shooting stars ────────────────────────────
          AnimatedBuilder(
            animation: _shootingStarController,
            builder: (_, __) {
              return CustomPaint(
                size: size,
                painter: _ShootingStarPainter(
                  stars: _shootingStars,
                  progress: _shootingStarController.value,
                ),
              );
            },
          ),

          // ── Layer 4: 3D Solar system hero ──────────────────────
          Positioned(
            top: size.height * 0.10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: size.height * 0.46,
              child: AnimatedBuilder(
                animation: Listenable.merge(
                    [_orbitController, _glowController, _rotateController]),
                builder: (_, __) {
                  final orbit = _orbitController.value;
                  final glow = _glowController.value;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer 3D orbit ellipses (tilted)
                      ..._buildOrbitEllipses(),

                      // Planet 1 — Earth-like (blue) — inner orbit
                      _build3DPlanet(
                        orbitRx: 88,
                        orbitRy: 30,
                        angle: orbit * 2 * pi,
                        size: 18,
                        colors: [const Color(0xff42a5f5), const Color(0xff1565c0)],
                        glow: const Color(0xff42a5f5),
                        glowOpacity: 0.8,
                      ),

                      // Planet 2 — Purple/Saturn-like — mid orbit
                      _build3DPlanet(
                        orbitRx: 130,
                        orbitRy: 44,
                        angle: orbit * 2 * pi * 0.6 + 1.2,
                        size: 26,
                        colors: [const Color(0xffce93d8), const Color(0xff6a1b9a)],
                        glow: const Color(0xffce93d8),
                        glowOpacity: 0.75,
                        hasRing: true,
                      ),

                      // Planet 3 — Red-Mars outer orbit
                      _build3DPlanet(
                        orbitRx: 170,
                        orbitRy: 58,
                        angle: orbit * 2 * pi * 0.38 + 2.8,
                        size: 20,
                        colors: [const Color(0xffef5350), const Color(0xffc62828)],
                        glow: const Color(0xffef5350),
                        glowOpacity: 0.7,
                      ),

                      // ── Sun (center) ────────────────────────────
                      // Corona outer
                      Container(
                        width: 78 + glow * 16,
                        height: 78 + glow * 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.12 + glow * 0.1),
                              blurRadius: 80,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      // Corona mid
                      Container(
                        width: 66 + glow * 10,
                        height: 66 + glow * 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.35 + glow * 0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Sun body (rotating texture simulation)
                      Transform.rotate(
                        angle: _rotateController.value * 2 * pi,
                        child: Container(
                          width: 56 + glow * 5,
                          height: 56 + glow * 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.3, -0.3),
                              colors: [
                                Color(0xfffff9c4),
                                Color(0xffffcc02),
                                Color(0xffff9800),
                                Color(0xffff6f00),
                                Color(0xffe65100),
                              ],
                              stops: [0.0, 0.25, 0.55, 0.8, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xffff9800).withOpacity(0.9),
                                blurRadius: 25,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Sun highlight
                      Positioned(
                        top: size.height * 0.46 / 2 - 28 - 10,
                        left: size.width / 2 - 8,
                        child: Container(
                          width: 14,
                          height: 9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Layer 5: UI content ────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.13)),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xff69f0ae),
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fade(duration: 900.ms, begin: 0.2, end: 1.0),
                        const SizedBox(width: 8),
                        Text(
                          '8 Planets  •  Interactive 3D',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms, duration: 700.ms),

                  // Spacer fills the hero area
                  SizedBox(height: size.height * 0.46 + 8),

                  // Title
                  const Text(
                    'Explore the\nSolar System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fade(delay: 500.ms, duration: 700.ms)
                      .slideY(
                          begin: 0.25,
                          end: 0,
                          delay: 500.ms,
                          duration: 650.ms,
                          curve: Curves.easeOut),

                  const SizedBox(height: 10),

                  Text(
                    'Journey through space and discover facts\nabout each planet in our solar system.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.42),
                      fontSize: 14,
                      height: 1.65,
                    ),
                  )
                      .animate()
                      .fade(delay: 680.ms, duration: 700.ms)
                      .slideY(
                          begin: 0.25,
                          end: 0,
                          delay: 680.ms,
                          duration: 650.ms,
                          curve: Curves.easeOut),

                  const Spacer(),

                  // ── CTA Button ────────────────────────────────
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, __) {
                      return GestureDetector(
                        onTap: _onExplore,
                        child: AnimatedScale(
                          scale: _buttonPressed ? 0.96 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          child: Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xffffb300),
                                  Color(0xffff9800),
                                  Color(0xffe65100),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xffff9800).withOpacity(
                                      0.45 + _glowController.value * 0.3),
                                  blurRadius: 28 + _glowController.value * 18,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Begin Exploration',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.rocket_launch_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fade(delay: 900.ms, duration: 700.ms)
                      .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 900.ms,
                          duration: 600.ms,
                          curve: Curves.easeOut),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      'Tap any planet to learn more',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.22),
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ).animate().fade(delay: 1200.ms, duration: 700.ms),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tilted 3D orbit ellipses
  List<Widget> _buildOrbitEllipses() {
    return [88.0, 130.0, 170.0].map((rx) {
      final ry = rx * 0.34;
      return Center(
        child: Container(
          width: rx * 2,
          height: ry * 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.elliptical(rx, ry)),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
              width: 0.8,
            ),
          ),
        ),
      );
    }).toList();
  }

  // 3D planet on an elliptical orbit
  Widget _build3DPlanet({
    required double orbitRx,
    required double orbitRy,
    required double angle,
    required double size,
    required List<Color> colors,
    required Color glow,
    required double glowOpacity,
    bool hasRing = false,
  }) {
    final x = orbitRx * cos(angle);
    final y = orbitRy * sin(angle);
    // 3D depth: planets at bottom of ellipse appear bigger/brighter
    final depthScale = 0.82 + 0.18 * ((sin(angle) + 1) / 2);
    final depthOpacity = 0.6 + 0.4 * ((sin(angle) + 1) / 2);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.scale(
        scale: depthScale,
        child: Opacity(
          opacity: depthOpacity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow
              Container(
                width: size + 16,
                height: size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: glow.withOpacity(glowOpacity * depthOpacity * 0.5),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              // Ring (Saturn)
              if (hasRing)
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.003)
                    ..rotateX(0.55),
                  child: Container(
                    width: size * 2.3,
                    height: size * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: const Color(0xffce93d8).withOpacity(0.5),
                        width: 3.5,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xffce93d8).withOpacity(0.25),
                          const Color(0xff9c27b0).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              // Planet body with 3D lighting
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.4),
                    colors: [
                      Color.lerp(colors.first, Colors.white, 0.35)!,
                      colors.first,
                      colors.last,
                      Color.lerp(colors.last, Colors.black, 0.45)!,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glow.withOpacity(0.55),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
              ),
              // 3D highlight
              Positioned(
                top: size * 0.1,
                left: size * 0.18,
                child: Container(
                  width: size * 0.32,
                  height: size * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shooting star data model ───────────────────────────────────
class _ShootingStar {
  final double startX, startY, length, angle, delay, speed;
  const _ShootingStar({
    required this.startX,
    required this.startY,
    required this.length,
    required this.angle,
    required this.delay,
    required this.speed,
  });
}

// ── Shooting star CustomPainter ───────────────────────────────
class _ShootingStarPainter extends CustomPainter {
  final List<_ShootingStar> stars;
  final double progress;

  _ShootingStarPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Each star has its own phase
      double p = (progress * star.speed + star.delay) % 1.0;
      // Only visible in the first 40% of its cycle
      if (p > 0.4) continue;
      final t = p / 0.4; // 0..1 during visible phase

      final dx = cos(star.angle) * star.length;
      final dy = sin(star.angle) * star.length;

      final headX = star.startX + dx * t;
      final headY = star.startY + dy * t;
      final tailX = headX - dx * 0.35;
      final tailY = headY - dy * 0.35;

      final opacity = (1.0 - t) * 0.85;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(opacity),
          ],
        ).createShader(Rect.fromPoints(
          Offset(tailX, tailY),
          Offset(headX, headY),
        ))
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(tailX, tailY), Offset(headX, headY), paint);
    }
  }

  @override
  bool shouldRepaint(_ShootingStarPainter old) => old.progress != progress;
}
