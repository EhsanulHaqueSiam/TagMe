import 'package:flutter/material.dart';

/// Centralized map tile configuration for all FlutterMap TileLayer widgets.
///
/// Uses CARTO Voyager tiles for both themes — readable, colorful, modern.
/// Free, no API key, no signup required.
abstract final class TileConfig {
  /// CARTO Voyager — clean, labeled, great contrast in any context.
  static const String _voyager =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  /// Returns tile URL. Voyager works well for both light and dark app themes.
  static String tileUrl(BuildContext context) => _voyager;

  /// Legacy accessor.
  static const String stadiaMapsTemplate = _voyager;

  /// User agent must match the Android applicationId.
  static const String userAgentPackageName = 'com.tagme.tagme';

  /// Maximum zoom level supported by CARTO tiles.
  static const double maxZoom = 20;
}
