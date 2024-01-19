import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/feed/data/models/filter_location_details.dart';
import 'package:clubz/features/feed/presentation/notifiers/feed_filter_notifier.dart';
import 'package:clubz/features/general/presentation/widgets/dropdown_dialog_button.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A page to display the functions to customize the filter for the feed.
class FilterFeedPage extends ConsumerStatefulWidget {
  const FilterFeedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterFeedPage> createState() => _FilterFeedPageState();
}

class _FilterFeedPageState extends ConsumerState<FilterFeedPage> {
  FilterLocationDetails? _location;

  int _radius = 10;

  /// Updates feedFilterProvider with new FilterDetails and pops page.
  _submit() {
    if (_location != null) {
      ref.read(feedFilterProvider.notifier).setFilterDetails(
        FilterDetails(
          locationDescription: _location!.description,
          lat: _location!.lat,
          lng: _location!.lng,
          radius: _radius,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    FilterDetails? filterDetails = ref.read(feedFilterProvider);

    if (filterDetails != null) {
      _location = FilterLocationDetails(
          description: filterDetails.locationDescription,
          lat: filterDetails.lat,
          lng: filterDetails.lng);
      _radius = filterDetails.radius;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.filterTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: AppConstants.paddingMainBodyContainer,
          right: AppConstants.paddingMainBodyContainer,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoundedButton(
              color: AppConstants.colorDarkGrey,
              onTap: () async {
                FilterLocationDetails? result = await context.push(AppRoutes.filterFeedLocationPicker);

                if (result != null) {
                  setState(() {
                    _location = result;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _location?.description ?? AppLocalizations.of(context)!.filterLocationDefault,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Icon(
                    Icons.location_on,
                    size: AppConstants.largeIconSize,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownDialogButton(
              value: _radius,
              icon: Icons.radio_button_unchecked,
              options: [10, 20, 30, 50, 100, 1000]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        '< $e km',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            RoundedButton(
              onTap: _submit,
              child: Text(
                AppLocalizations.of(context)!.filterSubmitButton,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
