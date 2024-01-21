import 'package:flutter/material.dart';

extension RowExtension on Row {
  Row withSpacing(double space) {
    return Row(
      key: key,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: List.from(
        children.map(
          (child) {
            return Padding(
              padding: EdgeInsets.only(
                left: children.first == child
                    ? 0.0
                    : children.last == child
                        ? space / 2
                        : 0.0,
                right: children.first == child
                    ? space / 2
                    : children.last == child
                        ? 0.0
                        : space / 2,
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
