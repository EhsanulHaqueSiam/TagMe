/// Centralized map tile configuration for all FlutterMap TileLayer widgets.
///
/// Uses Stadia Maps OSM Bright tiles (200K/month free tier, no credit card).
/// Stadia Maps free tier does not require an API key for mobile apps.
/// Register at stadiamaps.com if you need higher limits.
abstract final class TileConfig {
  /// Stadia Maps OSM Bright tiles.
  /// The `{r}` placeholder provides retina tiles on high-DPI devices.
  static const String stadiaMapsTemplate =
      'https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png';

  /// User agent must match the Android applicationId.
  static const String userAgentPackageName = 'com.tagme.tagme';

  /// Maximum zoom level supported by Stadia Maps OSM Bright tiles.
  static const double maxZoom = 20;
}
