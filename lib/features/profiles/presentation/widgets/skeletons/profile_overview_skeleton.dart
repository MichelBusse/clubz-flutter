import 'package:clubz/features/general/presentation/widgets/skeletons/skeleton_container.dart';
import 'package:clubz/features/profiles/presentation/widgets/profile_overview.dart';
import 'package:flutter/material.dart';

/// A skeleton view for [ProfileOverview].
class ProfileOverviewSkeleton extends StatelessWidget {
  const ProfileOverviewSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Material(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: SkeletonContainer.rounded(
              width: 65,
              height: 65,
              radius: BorderRadius.circular(65),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonContainer.rounded(width: MediaQuery.of(context).size.width * 0.35, height: 15),
                const SizedBox(height: 2,),
                SkeletonContainer.rounded(width: MediaQuery.of(context).size.width * 0.3, height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
