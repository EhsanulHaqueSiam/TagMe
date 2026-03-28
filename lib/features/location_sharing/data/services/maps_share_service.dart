import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for opening and sharing locations via Google Maps.
///
/// Uses geo: intent for Android native map app, falls back to
/// Google Maps web URLs when native intent is unavailable.
class MapsShareService {
  /// Opens coordinates in Google Maps app via geo: intent.
  /// Falls back to Google Maps web URL in browser if geo: intent fails.
  Future<void> openInGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = label != null ? Uri.encodeComponent(label) : '';
    final geoUri = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)',
    );

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      final webUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens Google Maps navigation to destination coordinates.
  /// Falls back to Google Maps web directions URL.
  Future<void> openDirections({
    required double destLat,
    required double destLng,
    String? label,
  }) async {
    final uri = Uri.parse('google.navigation:q=$destLat,$destLng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng',
      );
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// Shares a Google Maps link via the system share sheet.
  Future<void> shareLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final text = label != null ? '$label\n$url' : url;
    await Share.share(text);
  }
}
