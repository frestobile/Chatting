import 'package:flutter/material.dart';

void showStatusDialog(BuildContext context, String message, bool status) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(status ? 'Success' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

