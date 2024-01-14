import 'package:ets2_environments/src/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';

mixin StatefulMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _loadingEntry;

  void showLoading([String? message]) {
    hideLoading();

    _loadingEntry = OverlayEntry(
      builder: (context) {
        return Container(
          color: Colors.black12,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (message != null) const SizedBox(height: 16.0),
              if (message != null)
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(),
                ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_loadingEntry!);
  }

  void hideLoading() {
    if (_loadingEntry != null) {
      _loadingEntry?.remove();
      _loadingEntry = null;
    }
  }

  void showErrorDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Error!',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
