import 'package:flutter/material.dart';

/// Shows a snackbar for info messages.
showInfoSnackBar({required BuildContext context, required String infoText}){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(infoText),
    ),
  );
}

/// Shows a snackbar for error messages.
showErrorSnackBar({required BuildContext context, required String errorText}){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorText),
    ),
  );
}