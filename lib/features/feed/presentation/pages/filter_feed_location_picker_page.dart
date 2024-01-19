import 'dart:async';

import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/data/service/cities_database_api.dart';
import 'package:clubz/core/data/service/geolocator_api.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/feed/data/models/filter_location_details.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// A page to display the location picker for the filter of the feed.
class FilterFeedLocationPickerPage extends StatefulWidget {
  const FilterFeedLocationPickerPage({Key? key}) : super(key: key);

  @override
  State<FilterFeedLocationPickerPage> createState() => _FilterFeedLocationPickerPageState();
}

class _FilterFeedLocationPickerPageState extends State<FilterFeedLocationPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  FilterLocationDetails? myLocation;

  List<FilterLocationDetails> cities = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _updateMyLocation();
  }

  /// Updates option "My Location" to current location of user.
  void _updateMyLocation() async {
    try {
      Position pos =
          await GetIt.instance.get<GeolocatorApi>().getCurrentPosition();

      setState(() {
        myLocation = FilterLocationDetails(
            description: AppLocalizations.of(context)!.locationPickerMyLocation,
            lat: pos.latitude,
            lng: pos.longitude);
      });
    } on FrontendException catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context: context, errorText: e.getMessage(context));
      }
    }
  }

  /// Updates autocompleted places by [searchText].
  void _updatePlaces(String searchText) async {
    // Cancel active debounce (resets waiting time of function).
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Debounce function (wait 0.4s) to prevent too many invokes when typing fast.
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      List<FilterLocationDetails>? newCities = await GetIt.instance
          .get<CitiesDatabaseApi>()
          .getAutocomplete(searchText);

      setState(() {
        cities = newCities ?? [];
      });
    });
  }

  /// Pops page and returns FilterLocationDetails.
  void _submitPlace(
    FilterLocationDetails details,
  ) async {
    Navigator.of(context).pop(
      FilterLocationDetails(
        description: details.description,
        lat: details.lat,
        lng: details.lng,
      ),
    );
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
              suffixIcon: IconButton(
                onPressed: () {
                  _updatePlaces(_searchController.text);
                },
                icon: const Icon(Icons.search),
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
          children: (myLocation != null
                  ? [
                      FilterLocationPickerItem(
                        description: myLocation!.description,
                        onTap: () {
                          _submitPlace(
                            myLocation!,
                          );
                        },
                        icon: Icons.location_on,
                      )
                    ]
                  : <Widget>[]) +
              (cities
                  .map((city) => FilterLocationPickerItem(
                        description: city.description,
                        onTap: () {
                          _submitPlace(
                            city,
                          );
                        },
                      ))
                  .toList()),
        ),
      ),
    );
  }
}

class FilterLocationPickerItem extends StatelessWidget {
  const FilterLocationPickerItem(
      {Key? key, required this.description, this.icon, required this.onTap})
      : super(key: key);

  final void Function() onTap;
  final IconData? icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 15,
          bottom: 15,
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
                    description,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (icon != null) Icon(icon, size: 25),
          ],
        ),
      ),
    );
  }
}
