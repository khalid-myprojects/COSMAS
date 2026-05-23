import 'dart:math';
import 'dart:ui';
import 'package:cosmos_solar_system/planet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'planet_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _nebulaController;
  late AnimationController _bgRotateController;
  late AnimationController _shimmerController;

  int _selectedPlanetIndex = -1;
  bool _showLabel = false;
  String _labelText = '';

  // Full-screen orbit radii — expanded to fill entire display
  static const List<double> _orbitRadii = [
    105, 155, 200, 255, 315, 390, 450, 510,
  ];

  // Planet visual sizes — scaled to match expanded orbits
  static const List<double> _planetSizes = [
    13, 19, 21, 16, 36, 30, 24, 22,
  ];

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _bgRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 180),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _nebulaController.dispose();
    _bgRotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _openPlanetDetail(PlanetModel planet) {
    setState(() => _selectedPlanetIndex = planets.indexOf(planet));
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => PlanetDetailScreen(planet: planet),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutExpo,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Center positioned slightly above screen center for visual balance
    final centerY = size.height * 0.46;
    final centerX = size.width / 2;

    return Scaffold(
      backgroundColor: const Color(0xff010208),
      body: Stack(
        children: [
          // ── Layer 1: Deep cosmos gradient ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.15),
                radius: 1.6,
                colors: [
                  Color(0xff0d1240),
                  Color(0xff060a24),
                  Color(0xff020510),
                  Color(0xff010208),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),

          // ── Layer 2: Volumetric nebula clouds ──────────────────────
          AnimatedBuilder(
            animation: _nebulaController,
            builder: (_, __) {
              final v = _nebulaController.value;
              final cv = Curves.easeInOut.transform(v);
              return Stack(children: [
                // Solar corona — warm amber glow around center
                Positioned(
                  top: centerY - 200 + cv * 15,
                  left: centerX - 200,
                  child: _nebulaBlob(400, const Color(0xffff8c00), 0.07 + cv * 0.04),
                ),
                // Deep violet top-right nebula
                Positioned(
                  top: -120 + cv * 40,
                  right: -100 + cv * 20,
                  child: _nebulaBlob(500, const Color(0xff4a0090), 0.06 + cv * 0.03),
                ),
                // Teal bottom-left nebula
                Positioned(
                  bottom: 80 + cv * 30,
                  left: -120 - cv * 15,
                  child: _nebulaBlob(420, const Color(0xff007b70), 0.05 + cv * 0.025),
                ),
                // Crimson accent — lower right
                Positioned(
                  bottom: 200 - cv * 20,
                  right: -60 + cv * 10,
                  child: _nebulaBlob(300, const Color(0xff8b0000), 0.045 + cv * 0.02),
                ),
                // Ice blue top accent
                Positioned(
                  top: 60 - cv * 10,
                  left: size.width * 0.1 + cv * 20,
                  child: _nebulaBlob(250, const Color(0xff0055ff), 0.04 + cv * 0.02),
                ),
              ]);
            },
          ),

          // ── Layer 3: Star field — three size tiers ─────────────────
          ..._buildStarField(size),

          // ── Layer 4: Slow-rotating outer star ring ─────────────────
          AnimatedBuilder(
            animation: _bgRotateController,
            builder: (_, __) => Transform.rotate(
              angle: _bgRotateController.value * 2 * pi,
              origin: Offset(centerX, centerY),
              child: CustomPaint(
                size: size,
                painter: _StarRingPainter(centerX: centerX, centerY: centerY),
              ),
            ),
          ),

          // ── Layer 5: Orbit rings + all planets ─────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_orbitController, _pulseController]),
            builder: (_, __) {
              final orbit = _orbitController.value;
              final pulse = _pulseController.value;
              return CustomPaint(
                size: size,
                painter: _OrbitRingsPainter(
                  centerX: centerX,
                  centerY: centerY,
                  radii: _orbitRadii,
                  selectedIndex: _selectedPlanetIndex,
                  pulseValue: pulse,
                ),
                child: Stack(
                  children: [
                    // Sun at center
                    _buildSun(centerX, centerY, pulse),
                    // Planets
                    ...List.generate(planets.length, (i) {
                      final p = planets[i];
                      final angle = p.initialAngle + orbit * 2 * pi * p.orbitSpeed;
                      final r = _orbitRadii[i];
                      final pSize = _planetSizes[i];
                      final x = centerX + r * cos(angle);
                      final y = centerY + r * sin(angle) * 0.38;
                      final depth = 0.85 + 0.15 * ((sin(angle) + 1) / 2);
                      final isSelected = _selectedPlanetIndex == i;
                      return _buildPlanet(p, x, y, pSize, pulse, depth, i, isSelected);
                    }),
                  ],
                ),
              );
            },
          ),

          // ── Layer 6: Top header ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: _buildHeader(),
            ),
          ),

          // ── Layer 7: Floating planet label ─────────────────────────
          if (_showLabel)
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.18), width: 0.6),
                      ),
                      child: Text(
                        _labelText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fade(duration: 200.ms),
            ),

          // ── Layer 8: Bottom planet selector ───────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),

          // ── Layer 9: Subtle scroll hint ────────────────────────────
          Positioned(
            bottom: 142,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (_, __) {
                  return Opacity(
                    opacity: 0.25 + _shimmerController.value * 0.2,
                    child: const Text(
                      'TAP ANY OBJECT TO EXPLORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 3.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Star field with 3 tiers ──────────────────────────────────────
  List<Widget> _buildStarField(Size size) {
    final List<Widget> stars = [];

    // Micro stars (barely visible, very numerous)
    for (int i = 0; i < 180; i++) {
      final r = Random(i * 13 + 7);
      final sz = r.nextDouble() * 0.9 + 0.2;
      stars.add(Positioned(
        left: r.nextDouble() * size.width,
        top: r.nextDouble() * size.height,
        child: Container(
          width: sz,
          height: sz,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(r.nextDouble() * 0.4 + 0.1),
          ),
        ),
      ));
    }

    // Mid stars (twinkle)
    for (int i = 0; i < 100; i++) {
      final r = Random(i * 31 + 3);
      final sz = r.nextDouble() * 1.4 + 0.6;
      stars.add(Positioned(
        left: r.nextDouble() * size.width,
        top: r.nextDouble() * size.height,
        child: Container(
          width: sz,
          height: sz,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(r.nextDouble() * 0.5 + 0.25),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(
          duration: Duration(milliseconds: (r.nextDouble() * 3000 + 1200).toInt()),
          begin: 0.08,
          end: 0.95,
        ),
      ));
    }

    // Bright foreground stars (large, with cross-diffraction)
    for (int i = 0; i < 12; i++) {
      final r = Random(i * 97 + 55);
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      final sz = r.nextDouble() * 1.5 + 1.2;
      stars.add(Positioned(
        left: x,
        top: y,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cross diffraction spike
            Container(
              width: sz * 8,
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
            Container(
              width: 0.5,
              height: sz * 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: sz,
              height: sz,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: sz * 3,
                  ),
                ],
              ),
            ),
          ],
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(
          duration: Duration(milliseconds: (r.nextDouble() * 4000 + 2000).toInt()),
          begin: 0.5,
          end: 1.0,
        ),
      ));
    }

    return stars;
  }

  Widget _nebulaBlob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
              width: 0.6,
            ),
          ),
          child: Row(
            children: [
              // Logo mark
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xffffd54f), Color(0xffff8f00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffff9800).withOpacity(0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'COSMOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                    ),
                  ),
                  Text(
                    'Solar System Explorer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Live dot + count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xff69f0ae),
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fade(duration: 900.ms, begin: 0.15, end: 1.0),
                    const SizedBox(width: 6),
                    Text(
                      '${planets.length} planets',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 800.ms)
        .slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic);
  }

  // ── Sun ────────────────────────────────────────────────────────────
  Widget _buildSun(double cx, double cy, double pulse) {
    const double sunR = 38.0;
    return Positioned(
      left: cx - sunR - pulse * 4,
      top: cy - sunR - pulse * 4,
      child: GestureDetector(
        onTap: () => _openPlanetDetail(sunData),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outermost corona ring
            Container(
              width: (sunR * 2 + 8) + pulse * 22,
              height: (sunR * 2 + 8) + pulse * 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xffff6f00).withOpacity(0.06 + pulse * 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Mid corona
            Container(
              width: (sunR * 2) + pulse * 14,
              height: (sunR * 2) + pulse * 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffff9800).withOpacity(0.18 + pulse * 0.12),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            // Inner halo
            Container(
              width: sunR * 2 + pulse * 6,
              height: sunR * 2 + pulse * 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffffcc02).withOpacity(0.55 + pulse * 0.3),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            // Sun body
            Container(
              width: sunR * 2 + pulse * 4,
              height: sunR * 2 + pulse * 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  colors: [
                    Color(0xffffffff),
                    Color(0xfffffde7),
                    Color(0xffffcc02),
                    Color(0xffff9800),
                    Color(0xffff6f00),
                    Color(0xffe65100),
                  ],
                  stops: [0.0, 0.1, 0.28, 0.55, 0.8, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.95),
                    blurRadius: 22,
                    spreadRadius: 6,
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 24.seconds),
            // Specular highlight
            Positioned(
              top: 10 + (sunR - 38) / 2,
              left: 14 + (sunR - 38) / 2,
              child: Container(
                width: 16,
                height: 9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: [
                    Colors.white.withOpacity(0.55),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Planet ─────────────────────────────────────────────────────────
  Widget _buildPlanet(PlanetModel planet, double x, double y, double pSize,
      double pulse, double depth, int index, bool isSelected) {
    return Positioned(
      left: x - pSize / 2 - 16,
      top: y - pSize / 2 - 16,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPlanetIndex = index;
            _labelText = planet.name.toUpperCase();
            _showLabel = true;
          });
          Future.delayed(const Duration(milliseconds: 180), () {
            _openPlanetDetail(planet);
            Future.delayed(const Duration(milliseconds: 900), () {
              if (mounted) setState(() => _showLabel = false);
            });
          });
        },
        child: Transform.scale(
          scale: depth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection ring
              if (isSelected)
                Container(
                  width: pSize + 32,
                  height: pSize + 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: planet.glowColor.withOpacity(0.5 + pulse * 0.3),
                      width: 1.0,
                    ),
                  ),
                ),
              // Outer glow halo
              Container(
                width: pSize + 28,
                height: pSize + 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: planet.glowColor
                          .withOpacity(isSelected ? 0.65 + pulse * 0.35 : 0.35 + pulse * 0.2),
                      blurRadius: isSelected ? 28 : 18,
                      spreadRadius: isSelected ? 6 : 2,
                    ),
                  ],
                ),
              ),
              // Saturn rings
              if (planet.hasRings)
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.004)
                    ..rotateX(0.5),
                  alignment: Alignment.center,
                  child: Container(
                    width: pSize * 2.6,
                    height: pSize * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: const Color(0xffffd54f).withOpacity(0.6),
                        width: 3.5,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xffffd54f).withOpacity(0.35),
                          const Color(0xffffe082).withOpacity(0.15),
                          const Color(0xffffd54f).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              // Planet body
              Container(
                width: pSize,
                height: pSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.38, -0.38),
                    colors: [
                      Color.lerp(planet.colors.first, Colors.white, 0.35)!,
                      planet.colors.first,
                      planet.colors.last,
                      Color.lerp(planet.colors.last, Colors.black, 0.45)!,
                    ],
                    stops: const [0.0, 0.28, 0.68, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: planet.glowColor.withOpacity(0.7),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(2.5, 2.5),
                    ),
                  ],
                ),
              ),
              // 3D specular highlight
              Positioned(
                top: pSize * 0.09 + 16,
                left: pSize * 0.17 + 16,
                child: Container(
                  width: pSize * 0.32,
                  height: pSize * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(pSize),
                    gradient: LinearGradient(colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff08091f).withOpacity(0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill drag handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4, left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SOLAR SYSTEM',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 9,
                      letterSpacing: 3.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 88,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: planets.length,
                  itemBuilder: (_, i) {
                    final p = planets[i];
                    final isSelected = _selectedPlanetIndex == i;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlanetIndex = i);
                        _openPlanetDetail(p);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(right: 8, bottom: 4, top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: isSelected
                              ? p.glowColor.withOpacity(0.18)
                              : Colors.white.withOpacity(0.04),
                          border: Border.all(
                            color: isSelected
                                ? p.glowColor.withOpacity(0.55)
                                : Colors.white.withOpacity(0.08),
                            width: isSelected ? 1.0 : 0.5,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: p.glowColor.withOpacity(0.25),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                          ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mini planet sphere
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  center: const Alignment(-0.35, -0.35),
                                  colors: [
                                    Color.lerp(
                                        p.colors.first, Colors.white, 0.35)!,
                                    p.colors.first,
                                    p.colors.last,
                                  ],
                                  stops: const [0.0, 0.38, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.glowColor.withOpacity(0.65),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(isSelected ? 1.0 : 0.82),
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.orbitalPeriod
                                      .replaceAll(' days', 'd')
                                      .replaceAll(' Earth years', 'y')
                                      .replaceAll(' Earth days', 'd'),
                                  style: TextStyle(
                                    color: isSelected
                                        ? p.glowColor.withOpacity(0.95)
                                        : Colors.white.withOpacity(0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fade(
                        delay: Duration(milliseconds: 80 * i),
                        duration: 550.ms,
                        curve: Curves.easeOut,
                      )
                          .slideX(
                        begin: 0.15,
                        end: 0,
                        delay: Duration(milliseconds: 80 * i),
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 800.ms)
        .slideY(
      begin: 0.25,
      end: 0,
      curve: Curves.easeOutCubic,
    );
  }
}

// ── Orbit rings painter (with selected highlight) ────────────────────
class _OrbitRingsPainter extends CustomPainter {
  final double centerX, centerY;
  final List<double> radii;
  final int selectedIndex;
  final double pulseValue;

  _OrbitRingsPainter({
    required this.centerX,
    required this.centerY,
    required this.radii,
    required this.selectedIndex,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < radii.length; i++) {
      final r = radii[i];
      final ry = r * 0.38;
      final isSelected = selectedIndex == i;

      // Draw subtle dashed line for selected orbit
      if (isSelected) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.white.withOpacity(0.2 + pulseValue * 0.15);

        final rect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: r * 2,
          height: ry * 2,
        );
        canvas.drawOval(rect, paint);

        // Glow layer for selected
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(0.06 + pulseValue * 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawOval(rect, glowPaint);
      } else {
        // Normal orbit ring — fades outward
        final opacity = (0.10 - i * 0.007).clamp(0.025, 0.12);
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.white.withOpacity(opacity);

        final rect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: r * 2,
          height: ry * 2,
        );
        canvas.drawOval(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_OrbitRingsPainter old) =>
      old.selectedIndex != selectedIndex || old.pulseValue != pulseValue;
}

// ── Rotating outer star ring ──────────────────────────────────────────
class _StarRingPainter extends CustomPainter {
  final double centerX, centerY;

  _StarRingPainter({required this.centerX, required this.centerY});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    for (int i = 0; i < 80; i++) {
      final angle = (i / 80) * 2 * pi;
      final r = 340 + rand.nextDouble() * 140;
      final x = centerX + r * cos(angle);
      final y = centerY + r * sin(angle) * 0.38;
      final sz = rand.nextDouble() * 1.1 + 0.2;
      final paint = Paint()
        ..color = Colors.white.withOpacity(rand.nextDouble() * 0.25 + 0.05)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), sz, paint);
    }
  }

  @override
  bool shouldRepaint(_StarRingPainter old) => false;
}