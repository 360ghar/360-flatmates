import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Reusable map controller wrapper that encapsulates [MapController]
/// and provides convenient methods for camera movement, zoom, etc.
///
/// Follows the project's core-layer pattern: pure plumbing, no feature logic.
/// Use via [mapControllerProvider] or instantiate directly in feature pages.
class FlatmatesMapController {
  FlatmatesMapController() : _mapController = MapController();

  final MapController _mapController;
  MapController get controller => _mapController;

  TickerProvider? _vsync;
  AnimationController? _animController;

  LatLng get center => _mapController.camera.center;
  double get zoom => _mapController.camera.zoom;

  /// Attach a [TickerProvider] (usually `this` from a State that mixes in
  /// [TickerProviderStateMixin]) so [animateTo] can drive a real animation.
  /// Without a ticker, [animateTo] falls back to an instant move.
  void attachTicker(TickerProvider vsync) {
    _vsync = vsync;
  }

  void move(LatLng center, double zoom) {
    _mapController.move(center, zoom);
  }

  /// Smoothly animates the camera to [center] at [zoom] over ~400ms using
  /// [Curves.easeInOut]. Requires [attachTicker] to have been called; otherwise
  /// performs an instant move.
  Future<void> animateTo(LatLng center, {double zoom = 14}) async {
    final vsync = _vsync;
    if (vsync == null) {
      _mapController.move(center, zoom);
      return;
    }

    // Cancel any in-flight animation so we can interrupt it cleanly.
    _animController?.stop();
    _animController?.dispose();

    final startCenter = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;

    final controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 400),
    );
    _animController = controller;

    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    void tick() {
      final t = curved.value;
      final lat = startCenter.latitude +
          (center.latitude - startCenter.latitude) * t;
      final lng = startCenter.longitude +
          (center.longitude - startCenter.longitude) * t;
      final z = startZoom + (zoom - startZoom) * t;
      _mapController.move(LatLng(lat, lng), z, id: 'animate');
    }

    curved.addListener(tick);

    try {
      await controller.forward();
    } on TickerCanceled {
      // Animation interrupted — fine, a newer animation took over.
    } finally {
      curved.removeListener(tick);
      if (identical(_animController, controller)) {
        controller.dispose();
        _animController = null;
      }
    }
  }

  void fitBounds(
    List<LatLng> points, {
    EdgeInsets padding = const EdgeInsets.all(48),
  }) {
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: padding),
    );
  }

  void zoomIn() {
    move(center, zoom + 1);
  }

  void zoomOut() {
    move(center, zoom - 1);
  }

  void dispose() {
    _animController?.dispose();
    _animController = null;
    _vsync = null;
    // MapController does not need explicit disposal in flutter_map.
  }
}

/// Default OpenStreetMap tile URL template used across the app.
const String kDefaultOsmTileUrl =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Maximum zoom level for OSM tiles.
const double kDefaultMaxZoom = 19.0;

/// Default initial zoom level for map views.
const double kDefaultInitialZoom = 12.0;

/// Default minimum zoom level.
const double kDefaultMinZoom = 3.0;

/// Creates a default [TileLayer] configured for OpenStreetMap tiles.
///
/// Use this factory to ensure consistent tile configuration across all
/// map instances in the app.
TileLayer createOsmTileLayer({
  String? templateUrl,
  double maxZoom = kDefaultMaxZoom,
  double minZoom = kDefaultMinZoom,
  bool retinaMode = true,
}) {
  return TileLayer(
    urlTemplate: templateUrl ?? kDefaultOsmTileUrl,
    userAgentPackageName: 'com.the360ghar.flatmates',
    maxZoom: maxZoom,
    minZoom: minZoom,
    retinaMode: retinaMode,
  );
}
