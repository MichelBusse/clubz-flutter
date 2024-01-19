import 'dart:async';

import 'package:clubz/core/data/service/profiles_database_api.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/general/presentation/widgets/fetching_list.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// A page to allow the user to search for new profiles to follow.
class RequestFollowingPage extends ConsumerStatefulWidget {
  const RequestFollowingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RequestFollowingPage> createState() =>
      _RequestFollowingPageState();
}

class _RequestFollowingPageState extends ConsumerState<RequestFollowingPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  Timer? _debounce;

  /// Updates searchText to refresh FetchingList.
  void _updateSearchText() {
    // Cancel active debounce (resets waiting time of function).
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Debounce function (wait 0.4s) to prevent too many invokes when typing fast.
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        searchText = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Profile? profile = ref.watch(profileStateProvider);

    if (profile == null) {
      return Text(AppLocalizations.of(context)!.exceptionNotAuthenticated);
    }

    return Scaffold(
      extendBody: true,
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.requestFollowingPageTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(RegExp("[0-9,a-z,.,_,A-Z,-]")),
              TextInputFormatter.withFunction((oldValue, newValue) {
                return newValue.copyWith(
                  text: newValue.text.toLowerCase(),
                );
              }),
            ],
            onSubmitted: (String text) {
              _updateSearchText();
            },
            onChanged: ((_) {
              _updateSearchText();
            }),
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: 'username',
              contentPadding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMainBodyContainer,
                  10,
                  AppConstants.paddingMainBodyContainer,
                  10),
              suffixIcon: IconButton(
                onPressed: () {
                  _updateSearchText();
                },
                icon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: FetchingList(
        onRefresh: () async {},
        refreshState: "$searchText${profile.username}",
        query: (int from, int to) =>
            GetIt.instance.get<ProfilesDatabaseApi>().searchProfilesByUsername(
                  searchString: searchText,
                  excludedUsername: profile.username ?? '',
                  from: from,
                  to: to,
                ),
        buildListElement: (Profile p) => ProfileOverview(profile: p),
      ),
    );
  }
}
