import 'dart:async';

import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/places_api.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/events/data/models/event_location_details.dart';
import 'package:clubz/features/events/data/models/place_autocomplete.dart';
import 'package:clubz/features/events/data/models/place_details.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A page to display the location picker for the event location.
class EventLocationPickerPage extends StatefulWidget {
  const EventLocationPickerPage({Key? key}) : super(key: key);

  @override
  State<EventLocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<EventLocationPickerPage> {
  final TextEditingController _searchController = TextEditingController();

  List<PlaceAutocomplete> places = [];

  String loadingId = '';
  Timer? _debounce;
  final String _uuid = const Uuid().v4();

  /// Updates autocompleted places by [searchText].
  void _updatePlaces(String searchText) async {
    // Cancel active debounce (resets waiting time of function).
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Debounce function (wait 0.4s) to prevent too many invokes when typing fast.
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        List<PlaceAutocomplete>? newPlaces = await GetIt.instance
            .get<PlacesApi>()
            .getAutocomplete(searchText, _uuid);
        setState(() {
          places = newPlaces ?? [];
        });
      } on FrontendException catch (e) {
        if(context.mounted) {
          showErrorSnackBar(
            context: context,
            errorText: e.getMessage(context),
          );
        }
      }
    });
  }

  /// Pops page and returns EventLocationDetails.
  void _submitPlace(String placeId, String placeDescription) async {
    // Cancel function if already waiting to submit place with placeId.
    if (loadingId == placeId) return;

    setState(() {
      loadingId = placeId;
    });

    // Return empty EventLocationDetails (remove location) if placeId is -1.
    if (placeId == '-1') {
      Navigator.of(context).pop(
        const EventLocationDetails(
          description: '',
          lat: 0,
          lng: 0,
        ),);
      return;
    }

    // Fetch place details from google places api.
    PlaceDetails? details =
        await GetIt.instance.get<PlacesApi>().getPlaceDetails(placeId, _uuid);

    if (details == null) return;

    if(context.mounted) {
      Navigator.of(context).pop(
        EventLocationDetails(
          description: placeDescription,
          lat: details.lat,
          lng: details.lng,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.locationPickerTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (String text) {
              _updatePlaces(text);
            },
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: AppLocalizations.of(context)!.locationPickerHint,
              contentPadding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMainBodyContainer,
                  10,
                  AppConstants.paddingMainBodyContainer,
                  10),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/google_icon.png',
                  ),
                  IconButton(
                    onPressed: () {
                      _updatePlaces(_searchController.text);
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        child: ListView(
          children: [
                InkWell(
                  onTap: () {
                    // Remove location from event.
                    _submitPlace(
                      '-1',
                      AppLocalizations.of(context)!.editEventPageNoLocation,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .editEventPageNoLocation,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .locationPickerNoLocationDescription,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        if (loadingId == '-1')
                          const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
              ] +
              places
                  .map(
                    (place) => InkWell(
                      onTap: () {
                        _submitPlace(
                          place.placeId,
                          place.description,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.mainText,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    place.secondaryText,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            if (loadingId == place.placeId)
                              const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
