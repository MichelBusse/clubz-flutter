import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/features/events/data/models/place_autocomplete.dart';
import 'package:clubz/features/events/data/models/place_details.dart';
import 'dart:convert' as convert;

import 'package:supabase_flutter/supabase_flutter.dart';

/// A class to hold all API functions for Google places.
class PlacesApi {
  final SupabaseClient supabase = Supabase.instance.client;

  final String language = 'en';
  final String components = 'country:de';

  /// Returns autocompleted result for [searchInput] for user with [uuid].
  Future<List<PlaceAutocomplete>?> getAutocomplete(
      String searchInput, String uuid) async {
    try {
      // Communicates through Supabase Edge functions with Google Places API.
      var response = await supabase.functions.invoke(
        'placesAutocomplete',
        body: {
          "input": searchInput,
          "components": components,
          "language": language,
          "sessiontoken": uuid,
        },
      );

      // Print response.data to debug API request.
      // print(response.data);

      var json = convert.jsonDecode(response.data.toString());

      var results = json['predictions'] as List;

      return results.map((place) => PlaceAutocomplete.fromJson(place)).toList();
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.googlePlaces);
    }
  }

  /// Returns details for place with [placeId] for user with [uuid].
  Future<PlaceDetails?> getPlaceDetails(String placeId, String uuid) async {
    try {
      // Communicates through Supabase Edge functions with Google Places API.
      var response = await supabase.functions.invoke(
        'placesDetails',
        body: {
          "placeId": placeId,
          "language": language,
          "sessiontoken": uuid,
        },
      );

      // Print response.data to debug API request.
      // print(response.data);

      var json = convert.jsonDecode(response.data.toString());

      var result = json['result'];

      if (result != null) {
        return PlaceDetails.fromJson(result);
      } else {
        return null;
      }
    } catch (e) {
      throw FrontendException(type: FrontendExceptionType.googlePlaces);
    }
  }
}
