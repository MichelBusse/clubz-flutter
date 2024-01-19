import 'package:clubz/core/res/routes.dart';
import 'package:clubz/features/general/presentation/widgets/share_bottom_sheet_wrapper.dart';
import 'package:clubz/features/profiles/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A button to open the sharing options for a profile.
class ProfileShareBottomSheet extends StatelessWidget {
  const ProfileShareBottomSheet({
    Key? key,
    required this.profile,
  }) : super(key: key);

  final Profile profile;

  /// Copies url of profile to clipboard.
  void _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: '${dotenv.get("WEBSITE_URL")}${AppRoutes.profileDetailView}/${profile.id}',
      ),
    );

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShareBottomSheetWrapper(
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: InkWell(
              onTap: () => _copyToClipboard(context),
              borderRadius: BorderRadius.circular(50),
              child: const Icon(
                Icons.copy,
                size: 40,
                color: Color(0xFFDDDDDD),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
