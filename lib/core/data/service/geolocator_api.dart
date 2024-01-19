import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:geolocator/geolocator.dart';

/// A class to hold all API functions concerning the [Geolocator].
class GeolocatorApi{

  /// Returns the current position of the device.
  ///
  /// Throws an [FrontendException] with [FrontendExceptionType.locationServicesDisabled] if location service is not enabled.
  /// Throws an [FrontendException] with [FrontendExceptionType.locationPermissionDenied] if the permission to access the location is denied.
  /// Throws an [FrontendException] with [FrontendExceptionType.locationPermissionDeniedPermanently] if the permission to access the location is denied permanently.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw FrontendException(type: FrontendExceptionType.locationServicesDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw FrontendException(type: FrontendExceptionType.locationPermissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw FrontendException(type: FrontendExceptionType.locationPermissionDeniedPermanently);
    }

    return await Geolocator.getCurrentPosition();
  }
}