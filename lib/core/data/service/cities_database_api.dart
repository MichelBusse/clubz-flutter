import 'package:clubz/features/feed/data/models/filter_location_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A class to hold all API functions for the cities database.
class CitiesDatabaseApi {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Returns autocompleted city for [searchText].
  Future<List<FilterLocationDetails>?> getAutocomplete(String searchText) async {
    if(searchText.isEmpty) return null;

    // Convert text to uppercase and 'ß' to 'SS'.
    String convertedText = searchText.replaceAll('ß', 'SS');
    convertedText = convertedText.toUpperCase();

    final results = await supabase.rpc(
      "autocomplete_cities",
      params: {
        'search_text': convertedText,
      },
    );

    return results.map<FilterLocationDetails>((city) => FilterLocationDetails.fromJson(city)).toList();
  }
}
