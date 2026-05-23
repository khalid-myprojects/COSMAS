import 'package:flutter/material.dart';

class PlanetModel {
  final String name;
  final String emoji;
  final double size;
  final List<Color> colors;
  final double orbitRadius;
  final double initialAngle;
  final double orbitSpeed; // multiplier
  final String distanceFromSun;
  final String diameter;
  final String mass;
  final String orbitalPeriod;
  final String rotationPeriod;
  final String surfaceTemp;
  final String moons;
  final String description;
  final List<String> funFacts;
  final Color glowColor;
  final bool hasRings;

  const PlanetModel({
    required this.name,
    required this.emoji,
    required this.size,
    required this.colors,
    required this.orbitRadius,
    required this.initialAngle,
    required this.orbitSpeed,
    required this.distanceFromSun,
    required this.diameter,
    required this.mass,
    required this.orbitalPeriod,
    required this.rotationPeriod,
    required this.surfaceTemp,
    required this.moons,
    required this.description,
    required this.funFacts,
    required this.glowColor,
    this.hasRings = false,
  });
}

final List<PlanetModel> planets = [
  PlanetModel(
    name: 'Mercury',
    emoji: '⚫',
    size: 16,
    colors: [Color(0xffb0b0b0), Color(0xff757575), Color(0xff424242)],
    orbitRadius: 80,
    initialAngle: 0.5,
    orbitSpeed: 4.7,
    distanceFromSun: '57.9 million km',
    diameter: '4,879 km',
    mass: '3.30 × 10²³ kg',
    orbitalPeriod: '88 Earth days',
    rotationPeriod: '59 Earth days',
    surfaceTemp: '-180°C to 430°C',
    moons: '0',
    description:
        'Mercury is the smallest planet and closest to the Sun. It has no atmosphere to retain heat, causing extreme temperature swings.',
    funFacts: [
      'A year on Mercury is only 88 Earth days',
      'Surface temperatures swing over 600°C',
      'Mercury is shrinking as its core cools',
      'It has water ice at its poles in permanent shadow',
    ],
    glowColor: Color(0xffbdbdbd),
  ),
  PlanetModel(
    name: 'Venus',
    emoji: '🟡',
    size: 26,
    colors: [Color(0xffffeb3b), Color(0xffff9800), Color(0xffe65100)],
    orbitRadius: 120,
    initialAngle: 1.2,
    orbitSpeed: 3.5,
    distanceFromSun: '108.2 million km',
    diameter: '12,104 km',
    mass: '4.87 × 10²⁴ kg',
    orbitalPeriod: '225 Earth days',
    rotationPeriod: '243 Earth days',
    surfaceTemp: '465°C (average)',
    moons: '0',
    description:
        'Venus is the hottest planet in our solar system due to its thick CO₂ atmosphere causing a runaway greenhouse effect.',
    funFacts: [
      'Hottest planet despite not being closest to Sun',
      'Rotates backwards compared to most planets',
      'A day on Venus is longer than its year',
      'Surface pressure is 90x that of Earth',
    ],
    glowColor: Color(0xffff9800),
  ),
  PlanetModel(
    name: 'Earth',
    emoji: '🌍',
    size: 28,
    colors: [Color(0xff42a5f5), Color(0xff1565c0), Color(0xff43a047)],
    orbitRadius: 165,
    initialAngle: 2.1,
    orbitSpeed: 2.9,
    distanceFromSun: '149.6 million km',
    diameter: '12,742 km',
    mass: '5.97 × 10²⁴ kg',
    orbitalPeriod: '365.25 days',
    rotationPeriod: '24 hours',
    surfaceTemp: '-88°C to 58°C',
    moons: '1 (The Moon)',
    description:
        'Earth is the only known planet to harbor life. Its liquid water, protective atmosphere, and magnetic field make it uniquely habitable.',
    funFacts: [
      'Only known planet with life',
      '71% of surface is covered by water',
      'Has the largest moon relative to planet size',
      'Earth\'s core is as hot as the Sun\'s surface',
    ],
    glowColor: Color(0xff42a5f5),
  ),
  PlanetModel(
    name: 'Mars',
    emoji: '🔴',
    size: 22,
    colors: [Color(0xffef5350), Color(0xffc62828), Color(0xff8b0000)],
    orbitRadius: 215,
    initialAngle: 3.4,
    orbitSpeed: 2.4,
    distanceFromSun: '227.9 million km',
    diameter: '6,779 km',
    mass: '6.39 × 10²³ kg',
    orbitalPeriod: '687 Earth days',
    rotationPeriod: '24.6 hours',
    surfaceTemp: '-125°C to 20°C',
    moons: '2 (Phobos & Deimos)',
    description:
        'Mars is the Red Planet with the largest volcano and canyon in the solar system. A prime candidate for future human colonization.',
    funFacts: [
      'Home to Olympus Mons, tallest volcano in solar system',
      'Has seasons like Earth due to axial tilt',
      'Valles Marineris is 4x deeper than Grand Canyon',
      'Mars had liquid water billions of years ago',
    ],
    glowColor: Color(0xffef5350),
  ),
  PlanetModel(
    name: 'Jupiter',
    emoji: '🟠',
    size: 58,
    colors: [Color(0xffffe0b2), Color(0xffff9800), Color(0xff795548)],
    orbitRadius: 290,
    initialAngle: 0.8,
    orbitSpeed: 1.3,
    distanceFromSun: '778.5 million km',
    diameter: '139,820 km',
    mass: '1.90 × 10²⁷ kg',
    orbitalPeriod: '11.9 Earth years',
    rotationPeriod: '9.9 hours',
    surfaceTemp: '-145°C (cloud tops)',
    moons: '95 known moons',
    description:
        'Jupiter is the largest planet, a gas giant with the Great Red Spot — a storm larger than Earth that has raged for centuries.',
    funFacts: [
      'Great Red Spot storm raging for 350+ years',
      'Has 95 known moons including Europa with liquid ocean',
      '1,300 Earths could fit inside Jupiter',
      'Acts as solar system\'s vacuum cleaner catching asteroids',
    ],
    glowColor: Color(0xffff9800),
  ),
  PlanetModel(
    name: 'Saturn',
    emoji: '🪐',
    size: 52,
    colors: [Color(0xfffff9c4), Color(0xffffd54f), Color(0xffff8f00)],
    orbitRadius: 370,
    initialAngle: 2.6,
    orbitSpeed: 0.97,
    distanceFromSun: '1.43 billion km',
    diameter: '116,460 km',
    mass: '5.68 × 10²⁶ kg',
    orbitalPeriod: '29.5 Earth years',
    rotationPeriod: '10.7 hours',
    surfaceTemp: '-178°C (average)',
    moons: '146 known moons',
    description:
        'Saturn is famous for its spectacular ring system made of ice and rock. It\'s the least dense planet — it could float on water!',
    funFacts: [
      'Ring system extends 282,000 km from planet',
      'Least dense planet — less dense than water',
      'Has 146 known moons including Titan with thick atmosphere',
      'Rings are only ~10 meters thick despite spanning thousands of km',
    ],
    glowColor: Color(0xffffd54f),
    hasRings: true,
  ),
  PlanetModel(
    name: 'Uranus',
    emoji: '🔵',
    size: 40,
    colors: [Color(0xff80deea), Color(0xff00bcd4), Color(0xff006064)],
    orbitRadius: 440,
    initialAngle: 4.1,
    orbitSpeed: 0.68,
    distanceFromSun: '2.87 billion km',
    diameter: '50,724 km',
    mass: '8.68 × 10²⁵ kg',
    orbitalPeriod: '84 Earth years',
    rotationPeriod: '17.2 hours',
    surfaceTemp: '-224°C (average)',
    moons: '28 known moons',
    description:
        'Uranus is an ice giant that rotates on its side with an axial tilt of 98°. It has faint rings and a blue-green hue from methane.',
    funFacts: [
      'Rotates on its side — axial tilt of 97.8°',
      'Coldest planetary atmosphere at -224°C',
      'Has 13 known rings',
      'Moons named after Shakespeare characters',
    ],
    glowColor: Color(0xff80deea),
  ),
  PlanetModel(
    name: 'Neptune',
    emoji: '🌀',
    size: 38,
    colors: [Color(0xff5c6bc0), Color(0xff283593), Color(0xff1a237e)],
    orbitRadius: 510,
    initialAngle: 5.2,
    orbitSpeed: 0.54,
    distanceFromSun: '4.50 billion km',
    diameter: '49,244 km',
    mass: '1.02 × 10²⁶ kg',
    orbitalPeriod: '165 Earth years',
    rotationPeriod: '16.1 hours',
    surfaceTemp: '-218°C (average)',
    moons: '16 known moons',
    description:
        'Neptune is the windiest planet with storms reaching 2,100 km/h. It was the first planet discovered through mathematical prediction.',
    funFacts: [
      'Winds reach speeds of 2,100 km/h',
      'Was predicted mathematically before being observed',
      'Triton moon orbits backwards and will eventually crash',
      'Has a storm called The Great Dark Spot',
    ],
    glowColor: Color(0xff5c6bc0),
  ),
];

final PlanetModel sunData = PlanetModel(
  name: 'The Sun',
  emoji: '☀️',
  size: 90,
  colors: [Color(0xfffff176), Color(0xffff9800), Color(0xffff5722)],
  orbitRadius: 0,
  initialAngle: 0,
  orbitSpeed: 0,
  distanceFromSun: 'Center of Solar System',
  diameter: '1,392,700 km',
  mass: '1.99 × 10³⁰ kg',
  orbitalPeriod: 'N/A',
  rotationPeriod: '25-35 days (differential)',
  surfaceTemp: '5,500°C (surface)',
  moons: 'N/A',
  description:
      'The Sun is a G-type main-sequence star at the center of our solar system. It contains 99.86% of all mass in the solar system and provides energy for all life on Earth.',
  funFacts: [
    'Core temperature reaches 15 million °C',
    'Contains 99.86% of all solar system mass',
    'Light takes 8 minutes to reach Earth',
    '1.3 million Earths could fit inside the Sun',
  ],
  glowColor: Color(0xffff9800),
);
