import 'package:flutter/material.dart';

class StoryGradientPreset {
  const StoryGradientPreset({
    required this.id,
    required this.name,
    required this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  final String id;
  final String name;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  /// Hex representation of the primary color for API storage.
  String get primaryHex {
    final c = colors.first;
    final hex = c.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${hex.substring(2).toUpperCase()}';
  }

  LinearGradient get gradient => LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      );
}

const List<StoryGradientPreset> kStoryGradientPresets = [
  StoryGradientPreset(
    id: 'cosmic_sunset',
    name: 'Sunset',
    colors: [
      Color(0xFF8A2387),
      Color(0xFFE94057),
      Color(0xFFF27121),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  StoryGradientPreset(
    id: 'instagram_signature',
    name: 'Signature',
    colors: [
      Color(0xFFFBAA47),
      Color(0xFFD91A46),
      Color(0xFFA60F93),
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  ),
  StoryGradientPreset(
    id: 'midnight_neon',
    name: 'Midnight Neon',
    colors: [
      Color(0xFF0F0C29),
      Color(0xFF302B63),
      Color(0xFF24243E),
    ],
  ),
  StoryGradientPreset(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    colors: [
      Color(0xFFFF0844),
      Color(0xFFFFB199),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  ),
  StoryGradientPreset(
    id: 'emerald_dream',
    name: 'Emerald',
    colors: [
      Color(0xFF10B981),
      Color(0xFF047857),
      Color(0xFF064E3B),
    ],
  ),
  StoryGradientPreset(
    id: 'ocean_breeze',
    name: 'Ocean Breeze',
    colors: [
      Color(0xFF2193B0),
      Color(0xFF6DD5ED),
    ],
  ),
  StoryGradientPreset(
    id: 'velvet_lavender',
    name: 'Lavender',
    colors: [
      Color(0xFF654EA3),
      Color(0xFFEAAFC8),
    ],
  ),
  StoryGradientPreset(
    id: 'solar_flare',
    name: 'Solar',
    colors: [
      Color(0xFFFF512F),
      Color(0xFFDD2476),
    ],
  ),
  StoryGradientPreset(
    id: 'pure_dark',
    name: 'Obsidian',
    colors: [
      Color(0xFF141418),
      Color(0xFF0A0A0C),
    ],
  ),
];
