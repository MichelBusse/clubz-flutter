import 'package:cached_network_image/cached_network_image.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/general/presentation/widgets/skeletons/skeleton_container.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_avatar_wrapper.dart';
import 'package:flutter/material.dart';

/// A widget to display the profile avatar.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar(
      {Key? key,
      required this.avatarUrl,
      required this.maxRadius,
      this.onTap,
      this.onTapChild})
      : super(key: key);

  final String? avatarUrl;
  final double maxRadius;
  final Function()? onTap;
  final Widget? onTapChild;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null) {}
    return ProfileAvatarWrapper(
      maxRadius: maxRadius,
      onTap: onTap,
      onTapChild: onTapChild,
      child: (avatarUrl != null)
          ? CachedNetworkImage(
              // Show default avatar image as error image.
              errorWidget: (context, url, error) => Ink.image(
                width: maxRadius,
                height: maxRadius,
                fit: BoxFit.cover,
                image: const AssetImage(AppConstants.defaultProfileAvatarPath),
                child: onTap != null
                    ? InkWell(
                        child: onTapChild,
                        onTap: () {
                          onTap!.call();
                        },
                      )
                    : null,
              ),
              // Show avatar image with or without tap functionality.
              imageBuilder: (context, imageProvider) => onTap != null
                  ? Ink.image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      width: maxRadius,
                      height: maxRadius,
                      child: InkWell(
                        child: onTapChild,
                        onTap: () {
                          onTap!.call();
                        },
                      ),
                    )
                  : Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      width: maxRadius,
                      height: maxRadius,
                    ),
              imageUrl: avatarUrl!,
              // Show skeleton as placeholder.
              placeholder: (context, url) => SkeletonContainer.rounded(
                  width: maxRadius,
                  height: maxRadius,
                  radius: BorderRadius.circular(maxRadius)),
            )
          : Ink.image( // Show default image if avatarUrl is null.
              width: maxRadius,
              height: maxRadius,
              image: const AssetImage("assets/default_profile_picture.jpg"),
              child: onTap != null
                  ? InkWell(
                      child: onTapChild,
                      onTap: () {
                        onTap!.call();
                      },
                    )
                  : null,
            ),
    );
  }
}
