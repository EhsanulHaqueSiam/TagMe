import 'package:flutter/material.dart';

/// Centralized map tile configuration for all FlutterMap TileLayer widgets.
///
/// Uses CARTO tiles — free, no API key, no signup, unlimited for apps.
/// Voyager (light) and Dark Matter (dark) auto-switch with system theme.
abstract final class TileConfig {
  /// CARTO Voyager — clean, colorful, modern. For light theme.
  static const String _voyager =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  /// CARTO Dark Matter — sleek dark mode. For dark theme.
  static const String _darkMatter =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  /// Returns tile URL based on current brightness.
  static String tileUrl(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark ? _darkMatter : _voyager;
  }

  /// Legacy accessor — defaults to Voyager (light).
  static const String stadiaMapsTemplate = _voyager;

  /// User agent must match the Android applicationId.
  static const String userAgentPackageName = 'com.tagme.tagme';

  /// Maximum zoom level supported by CARTO tiles.
  static const double maxZoom = 20;
}
