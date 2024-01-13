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
}
