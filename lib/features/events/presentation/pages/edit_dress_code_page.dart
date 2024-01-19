import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A data model for [EditDressCodePage].
class DressCode {
  final int type;
  final String description;

  const DressCode(
      {required this.type, required this.description});
}

/// A page to edit the dress code of an event.
///
/// Displays [initialDressCode] and [initialDressCodeDescription] as initial values.
class EditDressCodePage extends StatefulWidget {
  const EditDressCodePage({
    Key? key,
    required this.dressCode,
  }) : super(key: key);

  final DressCode dressCode;

  @override
  State<EditDressCodePage> createState() => _EditDressCodePageState();
}

class _EditDressCodePageState extends State<EditDressCodePage> {
  final TextEditingController _description = TextEditingController();
  int _type = 0;

  @override
  void initState() {
    super.initState();

    _type = widget.dressCode.type;
    _description.text = widget.dressCode.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.editEventPageDressCode,
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
                items: Event.dressCodes.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(Event.dressCodeToString(context, value)),
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
                    DressCode(
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
