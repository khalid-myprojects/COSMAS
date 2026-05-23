import 'dart:math';
import 'dart:ui';
import 'package:cosmos_solar_system/planet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlanetDetailScreen extends StatefulWidget {
  final PlanetModel planet;

  const PlanetDetailScreen({super.key, required this.planet});

  @override
  State<PlanetDetailScreen> createState() => _PlanetDetailScreenState();
}

class _PlanetDetailScreenState extends State<PlanetDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late AnimationController _entryController;
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    _entryController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  Widget _buildPlanetHero() {
    final p = widget.planet;
    final isSun = p.name == 'The Sun';

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (_, __) {
        final pulse = _pulseController.value;

        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer corona glow
              Container(
                width: 200 + pulse * 20,
                height: 200 + pulse * 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: p.glowColor.withOpacity(0.08 + pulse * 0.06),
                      blurRadius: 80,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),

              // Glow ring
              Container(
                width: 160 + pulse * 12,
                height: 160 + pulse * 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: p.glowColor.withOpacity(0.25 + pulse * 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              // Saturn ring
              if (p.hasRings)
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(0.5),
                  alignment: Alignment.center,
                  child: Container(
                    width: 220,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: const Color(0xffffd54f).withOpacity(0.5),
                        width: 8,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xffffd54f).withOpacity(0.4),
                          const Color(0xffffb300).withOpacity(0.2),
                          const Color(0xfffff9c4).withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),

              // Orbiting moon for non-sun planets
              if (!isSun && p.moons != '0')
                AnimatedBuilder(
                  animation: _orbitController,
                  builder: (_, __) {
                    final a = _orbitController.value * 2 * pi;
                    return Transform.translate(
                      offset: Offset(90 * cos(a), 90 * sin(a) * 0.5),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.7),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Planet body with rotation
              RotationTransition(
                turns: isSun ? _rotateController : AlwaysStoppedAnimation(0),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSun
                        ? RadialGradient(colors: p.colors)
                        : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: p.colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.glowColor.withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 5,
                        offset: const Offset(-5, -5),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 20,
                        spreadRadius: 3,
                        offset: const Offset(8, 8),
                      ),
                    ],
                  ),
                ),
              ),

              // Highlight shimmer
              Positioned(
                top: 45,
                left: 52,
                child: Container(
                  width: 35,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.35),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.planet.glowColor.withOpacity(0.12),
              border: Border.all(
                color: widget.planet.glowColor.withOpacity(0.2),
              ),
            ),
            child: Icon(icon, color: widget.planet.glowColor, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    // was: opacity 0.4, fontSize 10, no weight
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    // was: fontSize 14, w600
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunFact(String fact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.planet.glowColor.withOpacity(0.18),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: widget.planet.glowColor,
                  // was: fontSize 11, w800
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fact,
              style: TextStyle(
                // was: opacity 0.7, fontSize 13
                color: Colors.white.withOpacity(0.88),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(
      delay: Duration(milliseconds: 800 + index * 120),
      duration: 500.ms,
    )
        .slideX(
      begin: 0.15,
      end: 0,
      delay: Duration(milliseconds: 800 + index * 120),
      duration: 500.ms,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.planet;

    return Scaffold(
      backgroundColor: const Color(0xff020510),
      body: Stack(
        children: [
          // Stars
          ...List.generate(100, (i) {
            final rand = Random(i * 17);
            final size = MediaQuery.of(context).size;
            return Positioned(
              left: rand.nextDouble() * size.width,
              top: rand.nextDouble() * size.height,
              child: Container(
                width: rand.nextDouble() * 1.8,
                height: rand.nextDouble() * 1.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(rand.nextDouble() * 0.5 + 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          // Ambient glow from planet
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: p.glowColor.withOpacity(
                            0.06 + _pulseController.value * 0.04),
                        blurRadius: 200,
                        spreadRadius: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Scrollable content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 380,
                pinned: true,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.08),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 16),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: _buildPlanetHero(),
                    ),
                  ).animate().fade(duration: 900.ms).scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    duration: 1000.ms,
                    curve: Curves.elasticOut,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Planet name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name.toUpperCase(),
                                style: TextStyle(
                                  // was: opacity 0.3, fontSize 11, no weight
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 12,
                                  letterSpacing: 5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  // was: fontSize 38, w900 — kept same, already bold
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: p.glowColor.withOpacity(0.12),
                              border: Border.all(
                                  color: p.glowColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: p.colors),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  p.name == 'The Sun' ? 'Star' : 'Planet',
                                  style: TextStyle(
                                    color: p.glowColor,
                                    // was: fontSize 11, w600
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fade(delay: 300.ms, duration: 700.ms)
                          .slideY(begin: 0.2, end: 0, delay: 300.ms),

                      const SizedBox(height: 20),

                      // Description card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Text(
                              p.description,
                              style: TextStyle(
                                // was: opacity 0.65, fontSize 14
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fade(delay: 450.ms, duration: 700.ms)
                          .slideY(begin: 0.2, end: 0, delay: 450.ms),

                      const SizedBox(height: 28),

                      // Stats section header
                      Text(
                        'PLANET STATS',
                        style: TextStyle(
                          // was: opacity 0.35, fontSize 11, w600
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fade(delay: 550.ms, duration: 600.ms),

                      const SizedBox(height: 16),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Column(
                              children: [
                                _buildStatRow('Distance from Sun',
                                    p.distanceFromSun, Icons.straighten),
                                _buildStatRow(
                                    'Diameter', p.diameter, Icons.circle_outlined),
                                _buildStatRow(
                                    'Mass', p.mass, Icons.scale_outlined),
                                _buildStatRow('Orbital Period',
                                    p.orbitalPeriod, Icons.rotate_right),
                                _buildStatRow('Rotation Period',
                                    p.rotationPeriod, Icons.refresh),
                                _buildStatRow('Surface Temperature',
                                    p.surfaceTemp, Icons.thermostat_outlined),
                                _buildStatRow(
                                    'Moons', p.moons, Icons.brightness_3_outlined),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fade(delay: 600.ms, duration: 700.ms)
                          .slideY(begin: 0.2, end: 0, delay: 600.ms),

                      const SizedBox(height: 28),

                      // Fun facts header
                      Text(
                        'FUN FACTS',
                        style: TextStyle(
                          // was: opacity 0.35, fontSize 11, w600
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fade(delay: 700.ms, duration: 600.ms),

                      const SizedBox(height: 14),

                      ...p.funFacts.asMap().entries.map(
                            (e) => _buildFunFact(e.value, e.key),
                      ),

                      const SizedBox(height: 30),

                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                p.glowColor.withOpacity(0.25),
                                p.glowColor.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                                color: p.glowColor.withOpacity(0.35)),
                          ),
                          child: Center(
                            child: Text(
                              '← Back to Solar System',
                              style: TextStyle(
                                color: p.glowColor,
                                // was: fontSize 15, w600
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fade(delay: 1200.ms, duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}