import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text('An Error Occurred'),
            content:
                const Text('Please, check internet connection and try again.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          ));
}
