import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Helper function to show a premium-styled modal bottom sheet.
///
/// Uses [showBarModalBottomSheet] for that iOS-style grab handle and behavior.
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  double? height,
}) {
  return showBarModalBottomSheet<T>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder:
        (context) => SizedBox(
          height: height, // Optional fixed height, otherwise wraps content
          child: SafeArea(
            bottom:
                false, // Let content handle safe area if needed, or set true
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: child,
            ),
          ),
        ),
  );
}
