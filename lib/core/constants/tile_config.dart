/// Centralized map tile configuration for all FlutterMap TileLayer widgets.
///
/// Uses CARTO Voyager tiles — free, no API key, no signup required.
abstract final class TileConfig {
  /// CARTO Voyager — clean, labeled, great contrast in any context.
  static const String tileUrl =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  /// User agent must match the Android applicationId.
  static const String userAgentPackageName = 'com.tagme.tagme';

  /// Maximum zoom level supported by CARTO tiles.
  static const double maxZoom = 20;
}
