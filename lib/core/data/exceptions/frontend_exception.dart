import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Enum for all types of [FrontendException].
enum FrontendExceptionType {
  genericError,
  notAuthenticated,
  notAuthorized,
  profileNotFound,
  profileNotInitialized,
  noProfilePictureSet,
  changeProfilePicture,
  getProfilePicture,
  updateProfile,
  createProfile,
  getProfile,
  getProfileStats,
  profileAlreadyCreated,
  signInWithEmail,
  signUpWithEmail,
  signInWithOAuth2,
  signOut,
  deleteUser,
  resetPassword,
  updatePassword,
  forcedDelay,
  noEventPictureSet,
  getEventPicture,
  changeEventThumbnail,
  addEventImage,
  removeEventImage,
  getEventImagesURLs,
  getEvent,
  deleteEvent,
  eventWithoutId,
  upsertEvent,
  sendFollowRequest,
  acceptFollowRequests,
  cancelFollowRequest,
  rejectFollowRequest,
  removeFollower,
  removeFollowing,
  toggleEventState,
  locationServicesDisabled,
  locationPermissionDenied,
  locationPermissionDeniedPermanently,
  share,
  googlePlaces,
  reportProfile,
  reportEvent,
  blockProfile,
  pickImage,
  pickImagePermission,
  generateImage,
}

/// Class for exceptions which can be shown to the user.
class FrontendException implements Exception {
  FrontendExceptionType type;

  FrontendException({this.type = FrontendExceptionType.genericError});

  /// Converts FrontendExceptionType to a readable message.
  String getMessage(BuildContext context) {
    switch (type) {
      case FrontendExceptionType.notAuthenticated:
        return AppLocalizations.of(context)!.exceptionNotAuthenticated;

      case FrontendExceptionType.notAuthorized:
        return AppLocalizations.of(context)!.exceptionNotAuthorized;

      case FrontendExceptionType.profileNotFound:
        return AppLocalizations.of(context)!.exceptionProfileNotFound;

      case FrontendExceptionType.profileNotInitialized:
        return AppLocalizations.of(context)!.exceptionProfileNotInitialized;

      case FrontendExceptionType.noProfilePictureSet:
        return AppLocalizations.of(context)!.exceptionNoProfilePictureSet;

      case FrontendExceptionType.changeProfilePicture:
        return AppLocalizations.of(context)!.exceptionChangeProfilePicture;

      case FrontendExceptionType.getProfilePicture:
        return AppLocalizations.of(context)!.exceptionGetProfilePicture;

      case FrontendExceptionType.updateProfile:
        return AppLocalizations.of(context)!.exceptionUpdateProfile;

      case FrontendExceptionType.createProfile:
        return AppLocalizations.of(context)!.exceptionCreateProfile;

      case FrontendExceptionType.getProfile:
        return AppLocalizations.of(context)!.exceptionGetProfile;

      case FrontendExceptionType.getProfileStats:
        return AppLocalizations.of(context)!.exceptionGetProfileStats;

      case FrontendExceptionType.profileAlreadyCreated:
        return AppLocalizations.of(context)!.exceptionProfileAlreadyCreated;

      case FrontendExceptionType.signInWithEmail:
        return AppLocalizations.of(context)!.exceptionSignInWithEmail;

      case FrontendExceptionType.signUpWithEmail:
        return AppLocalizations.of(context)!.exceptionSignUpWithEmail;

      case FrontendExceptionType.signInWithOAuth2:
        return AppLocalizations.of(context)!.exceptionSignInWithOAuth2;

      case FrontendExceptionType.signOut:
        return AppLocalizations.of(context)!.exceptionSignOut;

      case FrontendExceptionType.deleteUser:
        return AppLocalizations.of(context)!.exceptionDeleteUser;

      case FrontendExceptionType.updatePassword:
        return AppLocalizations.of(context)!.exceptionUpdatePassword;

      case FrontendExceptionType.resetPassword:
        return AppLocalizations.of(context)!.exceptionResetPassword;

      case FrontendExceptionType.forcedDelay:
        return AppLocalizations.of(context)!.exceptionForcedDelay;

      case FrontendExceptionType.noEventPictureSet:
        return AppLocalizations.of(context)!.exceptionNoEventPictureSet;

      case FrontendExceptionType.getEventPicture:
        return AppLocalizations.of(context)!.exceptionGetEventPicture;

      case FrontendExceptionType.changeEventThumbnail:
        return AppLocalizations.of(context)!.exceptionChangeEventThumbnail;

      case FrontendExceptionType.addEventImage:
        return AppLocalizations.of(context)!.exceptionAddEventImage;

      case FrontendExceptionType.removeEventImage:
        return AppLocalizations.of(context)!.exceptionRemoveEventImage;

      case FrontendExceptionType.getEventImagesURLs:
        return AppLocalizations.of(context)!.exceptionGetEventImagesURLs;

      case FrontendExceptionType.getEvent:
        return AppLocalizations.of(context)!.exceptionGetEvent;

      case FrontendExceptionType.deleteEvent:
        return AppLocalizations.of(context)!.exceptionDeleteEvent;

      case FrontendExceptionType.eventWithoutId:
        return AppLocalizations.of(context)!.exceptionEventWithoutId;

      case FrontendExceptionType.upsertEvent:
        return AppLocalizations.of(context)!.exceptionUpsertEvent;

      case FrontendExceptionType.sendFollowRequest:
        return AppLocalizations.of(context)!.exceptionSendFollowRequest;

      case FrontendExceptionType.acceptFollowRequests:
        return AppLocalizations.of(context)!.exceptionAcceptFollowRequests;

      case FrontendExceptionType.cancelFollowRequest:
        return AppLocalizations.of(context)!.exceptionCancelFollowRequest;

      case FrontendExceptionType.rejectFollowRequest:
        return AppLocalizations.of(context)!.exceptionRejectFollowRequest;

      case FrontendExceptionType.removeFollower:
        return AppLocalizations.of(context)!.exceptionRemoveFollower;

      case FrontendExceptionType.removeFollowing:
        return AppLocalizations.of(context)!.exceptionRemoveFollowing;

      case FrontendExceptionType.toggleEventState:
        return AppLocalizations.of(context)!.exceptionToggleEventState;

      case FrontendExceptionType.locationServicesDisabled:
        return AppLocalizations.of(context)!.exceptionLocationServicesDisabled;

      case FrontendExceptionType.locationPermissionDenied:
        return AppLocalizations.of(context)!.exceptionLocationPermissionsDenied;

      case FrontendExceptionType.locationPermissionDeniedPermanently:
        return AppLocalizations.of(context)!
            .exceptionLocationPermissionsDeniedPermanently;

      case FrontendExceptionType.share:
        return AppLocalizations.of(context)!.exceptionShare;

      case FrontendExceptionType.googlePlaces:
        return AppLocalizations.of(context)!.exceptionGooglePlaces;

      case FrontendExceptionType.reportProfile:
        return AppLocalizations.of(context)!.exceptionReportProfile;

      case FrontendExceptionType.reportEvent:
        return AppLocalizations.of(context)!.exceptionReportEvent;

      case FrontendExceptionType.blockProfile:
        return AppLocalizations.of(context)!.exceptionBlockProfile;

      case FrontendExceptionType.pickImage:
        return AppLocalizations.of(context)!.exceptionPickImage;

      case FrontendExceptionType.pickImagePermission:
        return AppLocalizations.of(context)!.exceptionPickImagePermission;

      case FrontendExceptionType.generateImage:
        return AppLocalizations.of(context)!.exceptionGenerateImage;

      default:
        return AppLocalizations.of(context)!.exceptionGenericError;
    }
  }
}
