import 'package:clubz/core/data/service/auth_api.dart';
import 'package:clubz/core/data/service/blocked_database_api.dart';
import 'package:clubz/core/data/service/cities_database_api.dart';
import 'package:clubz/core/data/service/events_database_api.dart';
import 'package:clubz/core/data/service/geolocator_api.dart';
import 'package:clubz/core/data/service/places_api.dart';
import 'package:clubz/core/data/service/profiles_database_api.dart';
import 'package:clubz/core/data/service/reports_database_api.dart';
import 'package:get_it/get_it.dart';

/// Registers APIs to GetIt
void setupAPIs() {
  GetIt.instance.registerSingleton<AuthApi>(AuthApi());
  GetIt.instance.registerSingleton<ProfilesDatabaseApi>(ProfilesDatabaseApi());
  GetIt.instance.registerSingleton<EventsDatabaseApi>(EventsDatabaseApi());
  GetIt.instance.registerSingleton<PlacesApi>(PlacesApi());
  GetIt.instance.registerSingleton<GeolocatorApi>(GeolocatorApi());
  GetIt.instance.registerSingleton<CitiesDatabaseApi>(CitiesDatabaseApi());
  GetIt.instance.registerSingleton<ReportsDatabaseApi>(ReportsDatabaseApi());
  GetIt.instance.registerSingleton<BlockedDatabaseApi>(BlockedDatabaseApi());
}