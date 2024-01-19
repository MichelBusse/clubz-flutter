import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A data model for [EditAgePolicyPage].
class AgePolicy {
  final int type;
  final String description;

  const AgePolicy(
      {required this.type, required this.description});
}

/// A page to edit the age policy of an event.
///
/// Displays [initialAgePolicy] and [initialAgePolicyDescription] as initial values.
class EditAgePolicyPage extends StatefulWidget {
  const EditAgePolicyPage({
    Key? key,
    required this.agePolicy,
  }) : super(key: key);

  final AgePolicy agePolicy;

  @override
  State<EditAgePolicyPage> createState() => _EditAgePolicyPageState();
}

class _EditAgePolicyPageState extends State<EditAgePolicyPage> {
  final TextEditingController _description = TextEditingController();
  int _type = 0;

  @override
  void initState() {
    super.initState();

    _type = widget.agePolicy.type;
    _description.text = widget.agePolicy.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.editEventPageAgePolicy,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMainBodyContainer),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: _type,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                isExpanded: true,
                onChanged: (int? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _type = value;
                  });
                },
                items:
                    Event.agePolicies.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(Event.agePolicyToString(context, value)),
                  );
                }).toList(),
              ),
              const Divider(color: Colors.white),
              TextFormField(
                controller: _description,
                style: Theme.of(context).textTheme.bodyLarge,
                minLines: 4,
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!
                      .editEventPageDescriptionHint,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RoundedButton(
                onTap: () {
                  Navigator.pop(
                    context,
                    AgePolicy(
                      type: _type,
                      description: _description.text,
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.editEventPageSave,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
