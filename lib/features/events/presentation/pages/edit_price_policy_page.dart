import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/features/events/data/models/event.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A data model for [EditPricePolicyPage].
class PricePolicy {
  final int type;
  final String description;
  final double price;
  final String link;

  const PricePolicy({
    required this.type,
    required this.description,
    required this.price,
    required this.link,
  });
}

/// A page to edit the price policy of an event.
///
/// Displays [initialPricePolicy] and [initialPricePolicyDescription] as initial values.
class EditPricePolicyPage extends StatefulWidget {
  const EditPricePolicyPage({
    Key? key,
    required this.pricePolicy,
  }) : super(key: key);

  final PricePolicy pricePolicy;

  @override
  State<EditPricePolicyPage> createState() => _EditPricePolicyPageState();
}

class _EditPricePolicyPageState extends State<EditPricePolicyPage> {
  final TextEditingController _description = TextEditingController();
  int _type = 0;
  final TextEditingController _price = TextEditingController();
  final TextEditingController _link = TextEditingController();

  @override
  void initState() {
    super.initState();

    _type = widget.pricePolicy.type;
    _description.text = widget.pricePolicy.description;
    _link.text = widget.pricePolicy.link;

    if(widget.pricePolicy.price != 0) {
      _price.text = widget.pricePolicy.price.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.editEventPagePricePolicy,
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
                    Event.pricePolicies.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(Event.pricePolicyToString(context, value)),
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
              const Divider(color: Colors.white),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9\,\.]")),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
                    try {
                      if (text.isNotEmpty) {
                        double.parse(text.replaceAll(',', '.'));
                      }
                      return newValue;
                    } catch (e) {
                      return oldValue;
                    }
                  }),
                ],
                controller: _price,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!
                      .editEventPagePricePolicyPriceHint,
                ),
              ),
              const Divider(color: Colors.white),
              TextFormField(
                controller: _link,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!
                      .editEventPagePricePolicyLinkHint,
                ),
              ),
              const Divider(color: Colors.white),
              const SizedBox(
                height: 20,
              ),
              RoundedButton(
                onTap: () {
                  Navigator.pop(
                    context,
                    PricePolicy(
                      type: _type,
                      description: _description.text,
                      price: _price.text.isNotEmpty ? double.parse(_price.text.replaceAll(',', '.')) : 0,
                      link: _link.text,
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
