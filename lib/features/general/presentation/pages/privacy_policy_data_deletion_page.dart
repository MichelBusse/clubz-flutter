import 'package:clubz/core/data/exceptions/frontend_exception.dart';
import 'package:clubz/features/general/presentation/widgets/snackbars.dart';
import 'package:clubz/features/general/presentation/widgets/rounded_button.dart';
import 'package:clubz/features/general/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

/// A page to request a deletion of the user data.
class PrivacyPolicyDataDeletionPage extends StatefulWidget {
  const PrivacyPolicyDataDeletionPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyDataDeletionPage> createState() => _PrivacyPolicyDataDeletionPageState();
}

class _PrivacyPolicyDataDeletionPageState extends State<PrivacyPolicyDataDeletionPage> {
  final TextEditingController _userMail = TextEditingController();
  bool _loading = false;

  void _submit() async {
    final userMail = _userMail.text;

    if(userMail.isEmpty){
      return;
    }

    setState(() {
      _loading = true;
    });

    // Sends request for account deletion through API url.
    try {
      http.post(Uri.parse(dotenv.get("ACCOUNT_DELETE_REQUEST_URL")), body: {"userMail" : userMail});

      showInfoSnackBar(context: context, infoText: AppLocalizations.of(context)!.privacyPolicyDataDeletionSuccess);
    } on FrontendException catch (e) {
      showErrorSnackBar(context: context, errorText: e.getMessage(context));
    }
    
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: Text(
          AppLocalizations.of(context)!.privacyPolicyDataDeletionPageTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.privacyPolicyDataDeletion1,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _userMail,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .privacyPolicyDataDeletionHint),
                  onSubmitted: (_) => !_loading ? _submit() : null,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                RoundedButton(
                  onTap: !_loading ? _submit : null,
                  child: !_loading
                      ? Text(
                    AppLocalizations.of(context)!
                        .privacyPolicyDataDeletionSubmitButton,
                    style:
                    Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.black,
                    ),
                  )
                      : const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
