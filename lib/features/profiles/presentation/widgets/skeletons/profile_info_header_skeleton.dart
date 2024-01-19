import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/general/presentation/widgets/skeletons/skeleton_container.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_info_header.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_stats_view.dart';
import 'package:flutter/material.dart';

/// A skeleton view for [ProfileInfoHeader].
class ProfileInfoHeaderSkeleton extends StatelessWidget {
  const ProfileInfoHeaderSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20,
          left: AppConstants.paddingMainBodyContainer,
          right: AppConstants.paddingMainBodyContainer,
          bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SkeletonContainer.rounded(
            width: 110,
            height: 110,
            radius: BorderRadius.circular(120),
          ),
          const SizedBox(
            height: 15,
          ),
          const SkeletonContainer.rounded(
            width: 150,
            height: 29,
          ),
          const SizedBox(
            height: 15,
          ),
          const ProfileStatsView(),
        ],
      ),
    );
  }
}
