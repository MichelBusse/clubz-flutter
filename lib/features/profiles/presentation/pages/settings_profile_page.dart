import 'package:async/async.dart';
import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:clubz/core/utils/pick_image.dart';
import 'package:clubz/features/general/presentation/widgets/alert_dialog.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar_wrapper.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// A data model for the arguments of [SettingsProfilePage].
class SettingsProfilePageArgs {
  final Function(bool)? callback;

  const SettingsProfilePageArgs({this.callback});
}

/// A page to display the available settings for the current users profile.
class SettingsProfilePage extends ConsumerStatefulWidget {
  const SettingsProfilePage({
    Key? key,
    this.args,
  }) : super(key: key);

  final SettingsProfilePageArgs? args;

  @override
  ConsumerState<SettingsProfilePage> createState() =>
      _SettingsProfilePageState();
}

class _SettingsProfilePageState extends ConsumerState<SettingsProfilePage> {
  Profile? _editingProfile;
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  bool _publicProfile = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _pictureChanged = false;
  bool _loadingImage = false;
  MemoryImage? _image;
  bool loading = false;
  CancelableOperation? _loadImageOperation;

  @override
  void initState() {
    super.initState();

    _editingProfile = ref.read(profileStateProvider);

    // Initialize fields.
    if (_editingProfile != null) {
      _displayName.text = _editingProfile!.fullName ?? '';
      _userName.text = _editingProfile!.username ?? '';
      _publicProfile = _editingProfile!.publicProfile;
    }
  }

  /// Opens image picker to change event image.
  void pickImage() async {
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
          _pictureChanged = true;
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

  /// Opens delete confirm dialog and deletes profile if confirmed.
  _deleteProfile(){
    showAlertDialog(
      context: _scaffoldKey.currentContext!,
      title: AppLocalizations.of(context)!
          .settingsPageDeleteProfileDialogTitle,
      description: AppLocalizations.of(context)!
          .settingsPageDeleteProfileDialogDescription,
      callback: () async {
        Navigator.of(context).popUntil(
              (route) => route.isFirst,
        );
        context.go(AppRoutes.feed);
        try {
          await ref
              .read(authStateProvider.notifier)
              .deleteUser();
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

  @override
  Widget build(BuildContext context) {
    // Listen for changes of current profile and insert them.
    ref.listen<Profile?>(profileStateProvider, (previous, next) {
      if (previous == null && next != null) {
        _editingProfile = next;

        if (_editingProfile != null) {
          _displayName.text = _editingProfile!.fullName ?? '';
          _userName.text = _editingProfile!.username ?? '';
          _publicProfile = _editingProfile!.publicProfile;
        }
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      appBar: TransparentAppBar( // Transparent App Bar
        title: Text(AppLocalizations.of(context)!.settingsPageTitle,
            style: Theme.of(context).textTheme.displayMedium),
        leading: _editingProfile != null &&
                _editingProfile!.username != null &&
                _editingProfile!.username!.isNotEmpty &&
                _editingProfile!.fullName != null &&
                _editingProfile!.fullName!.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    context.go(AppRoutes.feed);
                  }
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
                start: AppConstants.paddingMainBodyContainer,
                top: 20,
                end: AppConstants.paddingMainBodyContainer,
                bottom: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ref.watch(profileStateProvider) == null
                    ? []
                    : [
                        Center(
                          child: (_image != null)
                              ? ProfileAvatarWrapper(
                                  maxRadius: 140,
                                  child: Ink.image(
                                    image: _image!,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    child: InkWell(
                                      onTap: pickImage,
                                      child: _loadingImage
                                          ? const CircularProgressIndicator()
                                          : null,
                                    ),
                                  ),
                                )
                              : ProfileAvatar(
                                  avatarUrl: _editingProfile?.avatarUrl,
                                  maxRadius: 140,
                                  onTap: pickImage,
                                  onTapChild: _loadingImage
                                      ? const CircularProgressIndicator()
                                      : null,
                                ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .formValidatorEmpty;
                            }
                            return null;
                          },
                          style: Theme.of(context).textTheme.bodyLarge,
                          autocorrect: false,
                          controller: _displayName,
                          textAlign: TextAlign.left,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ],
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: AppLocalizations.of(context)!
                                  .settingsProfilePageDisplayNameHint),
                        ),
                        const Divider(
                          color: Colors.white,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .formValidatorEmpty;
                            }
                            if (value.length < 3) {
                              return AppLocalizations.of(context)!
                                  .formValidatorTooShort;
                            }
                            return null;
                          },
                          autocorrect: false,
                          controller: _userName,
                          textAlign: TextAlign.left,
                          textCapitalization: TextCapitalization.none,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                            FilteringTextInputFormatter.allow(
                                RegExp("[0-9,a-z,.,_,A-Z,-]")),
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              return newValue.copyWith(
                                text: newValue.text.toLowerCase(),
                              );
                            }),
                          ],
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: AppLocalizations.of(context)!
                                  .settingsProfilePageUserNameHint),
                        ),
                        const Divider(
                          color: Colors.white,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .settingsProfilePagePublicProfileLabel,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Switch(
                              value: _publicProfile,
                              activeTrackColor: Colors.red,
                              onChanged: (switched) {
                                setState(() {
                                  _publicProfile = switched;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_publicProfile)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text(
                                  "Wähle nur ein öffentliches Profil, wenn du ein Club oder ein Veranstalter bist.",
                                  softWrap: true,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        RoundedButton(
                          onTap: () async {
                            if (loading) {
                              return;
                            }
                            setState(() {
                              loading = true;
                            });
                            if (_formKey.currentState!.validate()) {
                              if (ref.read(profileStateProvider) != null) {
                                try {
                                  await ref
                                      .read(profileStateProvider.notifier)
                                      .updateProfile(
                                        userName: _userName.text.toLowerCase(),
                                        displayName: _displayName.text,
                                        publicProfile: _publicProfile,
                                        profilePicture: _image,
                                        pictureChanged: _pictureChanged,
                                      );

                                  if (context.mounted) {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    } else {
                                      context.go(AppRoutes.myProfile);
                                    }
                                  }
                                  if (widget.args?.callback != null) {
                                    widget.args?.callback!.call(true);
                                  }
                                } on FrontendException catch (e) {
                                  if (context.mounted) {
                                    showErrorSnackBar(
                                        context: context,
                                        errorText: e.getMessage(context));
                                  }
                                }
                              }
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (loading)
                                const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                ),
                              if (!loading)
                                Text(
                                  AppLocalizations.of(context)!
                                      .settingsProfilePageSave,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.black),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RoundedButton(
                          onTap: () async {
                            try {
                              await ref
                                  .read(authStateProvider.notifier)
                                  .signOut();

                              if (context.mounted) {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                }
                                context.go(AppRoutes.feed);
                              }
                            } on FrontendException catch (e) {
                              if (context.mounted) {
                                showErrorSnackBar(
                                    context: context,
                                    errorText: e.getMessage(context));
                              }
                            }
                          },
                          color: AppConstants.colorDarkGrey,
                          child: Text(
                            AppLocalizations.of(context)!
                                .settingsProfilePageLogout,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RoundedButton(
                          onTap: _deleteProfile,
                          color: AppConstants.colorDarkGrey,
                          child: Text(
                            AppLocalizations.of(context)!
                                .settingsPageDeleteAccountButton,
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.red,
                                    ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                            10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.push(AppRoutes.imprint);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .imprintPageButton,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push(AppRoutes.privacyPolicy);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .privacyPolicyPageButton,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                            10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.push(AppRoutes.termsOfUse);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .termsOfUsePageButton,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
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
