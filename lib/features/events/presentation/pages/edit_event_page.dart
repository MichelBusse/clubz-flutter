import 'package:async/async.dart';
import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/core/utils/pick_image.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/events/data/models/event_location_details.dart';
import 'package:clubz/features/events/presentation/pages/edit_age_policy_page.dart';
import 'package:clubz/features/events/presentation/pages/edit_dress_code_page.dart';
import 'package:clubz/features/events/presentation/pages/edit_price_policy_page.dart';
import 'package:clubz/features/events/presentation/widgets/event_image.dart';
import 'package:clubz/features/events/presentation/widgets/event_image_wrapper.dart';
import 'package:clubz/features/general/presentation/widgets/alert_dialog.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

/// A page to edit the data of [event].
class EditEventPage extends ConsumerStatefulWidget {
  const EditEventPage({Key? key, this.event}) : super(key: key);

  final Event? event;

  @override
  ConsumerState<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends ConsumerState<EditEventPage> {
  /// Returns default start date for new event.
  static DateTime _getDefaultStartDate() {
    DateTime startDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      20,
    );
    if (DateTime.now().isAfter(startDate)) {
      startDate.add(const Duration(days: 1));
    }
    return startDate;
  }

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _eventName = TextEditingController();
  final TextEditingController _description = TextEditingController();

  DateTime _startDateTime = _getDefaultStartDate();
  // Events last 5 hours by default.
  DateTime _endDateTime = _getDefaultStartDate().add(const Duration(hours: 5));

  bool _visible = false;
  MemoryImage? _image;
  String _placeDescription = '';
  String _location = '';

  int _dressCode = 0;
  String _dressCodeDescription = '';

  int _agePolicy = 0;
  String _agePolicyDescription = '';

  int _pricePolicy = 0;
  String _pricePolicyDescription = '';
  double _pricePolicyPrice = 0;
  String _pricePolicyLink = '';

  bool _loading = false;

  bool _loadingImage = false;

  CancelableOperation? _loadImageOperation;

  bool _repeatWeekly = false;

  @override
  void initState() {
    super.initState();

    // Initialize fields.
    if (widget.event != null) {
      _eventName.text = widget.event!.eventName;
      _startDateTime = widget.event!.startDatetime;
      _endDateTime = widget.event!.endDatetime;
      _visible = widget.event!.visible;
      _description.text = widget.event!.description;
      _placeDescription = widget.event!.placeDescription;
      _location = widget.event!.location ?? '';
      _dressCode = widget.event!.dressCode;
      _dressCodeDescription = widget.event!.dressCodeDescription;
      _agePolicy = widget.event!.agePolicy;
      _agePolicyDescription = widget.event!.agePolicyDescription;
      _pricePolicy = widget.event!.pricePolicy;
      _pricePolicyDescription = widget.event!.pricePolicyDescription;
      _pricePolicyPrice = widget.event!.pricePolicyPrice;
      _pricePolicyLink = widget.event!.pricePolicyLink;
      _repeatWeekly = widget.event!.repeatWeekly;
    }
  }

  /// Opens image picker to change event image.
  void _pickImage() async {
    if (_loadingImage) {
      // Cancel image picker if already loading.
      _loadImageOperation?.cancel();
      setState(() {
        _loadingImage = false;
      });
      return;
    }

    setState(() {
      _loadingImage = true;
    });

    try {
      // Make image picker cancelable.
      _loadImageOperation = CancelableOperation.fromFuture(
        pickCropAndCompressImage(
          context: context,
          cropperTitle: AppLocalizations.of(context)!.editEventPageCropperTitle,
          minHeight: 800,
          minWidth: 800,
          quality: 90,
        ),
      );

      final bytes = await _loadImageOperation?.value;

      if (bytes != null) {
        setState(() {
          _image = MemoryImage(bytes);
        });
      }
    } on FrontendException catch (e) {
      if (context.mounted) {
        showErrorSnackBar(
          context: context,
          errorText: e.getMessage(context),
        );
      }
    } finally {
      setState(() {
        _loadingImage = false;
      });
    }
  }

  /// Opens [EventLocationPickerPage] to pick location for event.
  void _pickEventLocation() async {
    EventLocationDetails? result =
        await context.push(AppRoutes.eventLocationPicker);

    // Cancel if EventLocationPickerPage returns no result.
    if (result == null) {
      return;
    }

    // Set empty location if location description is empty.
    if (result.description == '') {
      setState(() {
        _placeDescription = '';
        _location = '';
      });
      return;
    }

    setState(() {
      _placeDescription = result.description;
      _location = 'POINT(${result.lng} ${result.lat})';
    });
  }

  /// Validates inputs and save event.
  void _submit() async {
    if (_loading) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDateTime.isBefore(DateTime.now())) {
      showErrorSnackBar(
        context: context,
        errorText: AppLocalizations.of(context)!
            .editEventPageFormValidationStartInPast,
      );
      return;
    }

    if (_endDateTime.isBefore(_startDateTime)) {
      showErrorSnackBar(
        context: context,
        errorText: AppLocalizations.of(context)!
            .editEventPageFormValidationEndBeforeStart,
      );
      return;
    }

    Profile? profile = ref.read(profileStateProvider);

    // Cancel if no current profile is logged in.
    if (profile == null) return;

    if (_visible &&
        profile.publicProfile &&
        (widget.event == null || !widget.event!.visible)) {
      // Warn users if they try to save publicly visible event.
      showAlertDialog(
        context: _scaffoldKey.currentContext!,
        title: AppLocalizations.of(context)!.editEventPagePublicDialogTitle,
        description:
            AppLocalizations.of(context)!.editEventPagePublicDialogDescription,
        callback: () => _upsertEvent(profile),
      );
    } else {
      _upsertEvent(profile);
    }
  }

  /// Inserts or updates event.
  void _upsertEvent(
    Profile profile,
  ) async {
    if (_loading) return;

    Event event = Event(
      id: widget.event?.id,
      imageUrl: widget.event?.imageUrl,
      eventName: _eventName.text,
      startDatetime: _startDateTime,
      endDatetime: _endDateTime,
      creatorId: profile.id,
      description: _description.text,
      visible: _visible,
      placeDescription: _placeDescription,
      location: _location.isNotEmpty ? _location : null,
      dressCode: _dressCode,
      dressCodeDescription: _dressCodeDescription,
      agePolicy: _agePolicy,
      agePolicyDescription: _agePolicyDescription,
      pricePolicy: _pricePolicy,
      pricePolicyDescription: _pricePolicyDescription,
      pricePolicyPrice: _pricePolicyPrice,
      pricePolicyLink: _pricePolicyLink,
      repeatWeekly: _repeatWeekly,
    );

    setState(() {
      _loading = true;
    });
    try {
      await ref.read(eventsControllerProvider).upsertEvent(
            event: event,
            image: _image,
          );

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } on FrontendException catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context: context, errorText: e.getMessage(context));
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(
        title: Text(
          widget.event != null
              ? AppLocalizations.of(context)!.editEventPageTitle
              : AppLocalizations.of(context)!.addEventPageTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.feed);
            }
          },
        ),
        actions: [
          AnimatedOpacity(
            opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 100),
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_hide,
                color: Colors.white,
              ),
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding:
                const EdgeInsets.all(AppConstants.paddingMainBodyContainer),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_image != null || widget.event == null)
                    EventImageWrapper(
                      children: [
                        if (_image != null)
                          Image(
                            image: _image!,
                            fit: BoxFit.fill,
                          ),
                        if (_image == null)
                          const Image(
                            fit: BoxFit.cover,
                            image:
                                AssetImage(AppConstants.defaultEventImagePath),
                          ),
                        Positioned(
                          top: 15,
                          right: 15,
                          child: IconButton(
                            icon: _loadingImage
                                ? const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Icon(Icons.edit, size: 30),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                  if (_image == null && widget.event != null)
                    EventImage(
                      event: widget.event,
                      centeredWidget: Positioned(
                        top: 15,
                        right: 15,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 30),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .formValidatorEmpty;
                        }
                        return null;
                      },
                      controller: _eventName,
                      style: Theme.of(context).textTheme.displayLarge,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.editEventPageNameHint,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                  InkWell(
                    onTap: () {
                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        onConfirm: (date) {
                          setState(() {
                            _startDateTime = date;
                            if (_startDateTime.isAfter(_endDateTime)) {
                              _endDateTime =
                                  _startDateTime.add(const Duration(hours: 5));
                            }
                          });
                        },
                        currentTime: _startDateTime,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 80,
                            ),
                            child: Text(
                              '${AppLocalizations.of(context)!.editEventPageStartDatetime}:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat(
                                      "dd.MM.yyyy HH:mm",
                                      Localizations.localeOf(context)
                                          .toLanguageTag())
                                  .format(_startDateTime),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const Icon(Icons.date_range),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                  InkWell(
                    onTap: () {
                      DatePicker.showDateTimePicker(
                        context,
                        currentTime: _endDateTime,
                        minTime: _startDateTime,
                        maxTime: _startDateTime.add(
                          const Duration(
                            days: 1,
                          ),
                        ),
                        showTitleActions: true,
                        onConfirm: (date) {
                          setState(() {
                            _endDateTime = date;
                          });
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 80,
                            ),
                            child: Text(
                              '${AppLocalizations.of(context)!.editEventPageEndDatetime}:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat(
                                      "dd.MM.yyyy HH:mm",
                                      Localizations.localeOf(context)
                                          .toLanguageTag())
                                  .format(_endDateTime),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const Icon(Icons.date_range),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                  InkWell(
                    onTap: () {
                      _pickEventLocation();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 80,
                            ),
                            child: Text(
                                '${AppLocalizations.of(context)!.editEventPageLocation}:',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Expanded(
                            child: Text(
                              _placeDescription.isNotEmpty
                                  ? _placeDescription
                                  : AppLocalizations.of(context)!
                                      .editEventPageNoLocation,
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 12,
                      bottom: 12,
                    ),
                    child: TextFormField(
                      controller: _description,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .editEventPageDescriptionHint,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      minLines: 4,
                      maxLines: 15,
                    ),
                  ),
                  const Divider(color: Colors.white),
                  InkWell(
                    onTap: () async {
                      DressCode? data = await context.push(
                        AppRoutes.editDressCode,
                        extra: DressCode(
                          type: _dressCode,
                          description: _dressCodeDescription,
                        ),
                      );

                      if (data != null) {
                        setState(() {
                          _dressCode = data.type;
                          _dressCodeDescription = data.description;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 110,
                            ),
                            child: Text(
                                '${AppLocalizations.of(context)!.editEventPageDressCode}:',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Expanded(
                            child: Text(
                              Event.dressCodeToString(context, _dressCode),
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.checkroom),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                  InkWell(
                    onTap: () async {
                      AgePolicy? data = await context.push(
                        AppRoutes.editAgePolicy,
                        extra: AgePolicy(
                          type: _agePolicy,
                          description: _agePolicyDescription,
                        ),
                      );

                      if (data != null) {
                        setState(() {
                          _agePolicy = data.type;
                          _agePolicyDescription = data.description;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 110,
                            ),
                            child: Text(
                                '${AppLocalizations.of(context)!.editEventPageAgePolicy}:',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Expanded(
                            child: Text(
                              Event.agePolicyToString(context, _agePolicy),
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.person_search),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                  InkWell(
                    onTap: () async {
                      PricePolicy? data = await context.push(
                        AppRoutes.editPricePolicy,
                        extra: PricePolicy(
                          type: _pricePolicy,
                          description: _pricePolicyDescription,
                          price: _pricePolicyPrice,
                          link: _pricePolicyLink,
                        ),
                      );

                      if (data != null) {
                        setState(() {
                          _pricePolicy = data.type;
                          _pricePolicyDescription = data.description;
                          _pricePolicyPrice = data.price;
                          _pricePolicyLink = data.link;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 110,
                            ),
                            child: Text(
                                '${AppLocalizations.of(context)!.editEventPagePricePolicy}:',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Expanded(
                            child: Text(
                              Event.pricePolicyToString(context, _pricePolicy),
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.credit_card),
                        ],
                      ),
                    ),
                  ),
                  /*
                  const Divider(color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .editEventPageRepeatWeekly,
                          style: Theme.of(context).textTheme.largeIconSize,
                        ),
                        Switch(
                          value: _repeatWeekly,
                          onChanged: (newValue) {
                            setState(() {
                              _repeatWeekly = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),*/
                  const Divider(color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .editEventPageVisibleInProfile,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Switch(
                          value: _visible,
                          onChanged: (newValue) {
                            setState(() {
                              _visible = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RoundedButton(
                    onTap: _submit,
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          )
                        : Text(
                            widget.event != null
                                ? AppLocalizations.of(context)!
                                    .editEventPageSave
                                : AppLocalizations.of(context)!
                                    .editEventPageCreate,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Colors.black),
                          ),
                  ),
                  if (widget.event != null)
                    const SizedBox(
                      height: 10,
                    ),
                  if (widget.event != null)
                    RoundedButton(
                      onTap: () async {
                        if (_loading) return;
                        if (ref.read(profileStateProvider) != null) {
                          showAlertDialog(
                            context: _scaffoldKey.currentContext!,
                            title: AppLocalizations.of(context)!
                                .editEventPageDeleteDialogTitle,
                            description: AppLocalizations.of(context)!
                                .editEventPageDeleteDialogDescription,
                            callback: () async {
                              try {
                                await ref
                                    .read(eventsControllerProvider)
                                    .deleteEvent(event: widget.event!);
                                if (context.mounted) {
                                  Navigator.of(context).popUntil(
                                    (route) => route.isFirst,
                                  );
                                  context.go(AppRoutes.myProfile);
                                }
                              } on FrontendException catch (e) {
                                if (context.mounted) {
                                  showErrorSnackBar(
                                      context: context,
                                      errorText: e.getMessage(context));
                                }
                              }
                            },
                            continueButtonTextColor: Colors.red,
                          );
                        }
                      },
                      color: Colors.transparent,
                      child: Text(
                        AppLocalizations.of(context)!.editEventPageDelete,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
