import 'package:flutter/material.dart';

/// Design system color palette following the 60-30-10 rule.
abstract final class AppColors {
  // 60-30-10 rule
  static const dominant = Color(0xFFFAFAFA); // gray-50 scaffold bg
  static const secondary = Color(0xFFFFFFFF); // white surfaces
  static const accent = Color(0xFF1B73E8); // blue-600 CTAs

  // Semantic
  static const destructive = Color(0xFFD93025); // red-600
  static const success = Color(0xFF1E8E3E); // green-600
  static const surfaceVariant = Color(0xFFF1F3F4); // gray-100
  static const onSurfaceDim = Color(0xFF5F6368); // gray-600

  // University border colors
  static const Map<String, Color> universityColors = {
    'AIUB': Color(0xFF1565C0),
    'BRACU': Color(0xFFE65100),
    'NSU': Color(0xFF2E7D32),
    'DU': Color(0xFF6A1B9A),
    'BUET': Color(0xFFAD1457),
    'IUB': Color(0xFF00695C),
    'EWU': Color(0xFFF57F17),
  };

  static const universityDefault = Color(0xFF546E7A);

  static Color getUniversityColor(String university) {
    return universityColors[university] ?? universityDefault;
  }
}
