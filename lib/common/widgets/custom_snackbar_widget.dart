import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// void showCustomSnackBar(String? message, {bool isError = true}) {
//   Get.showSnackbar(GetSnackBar(
//     backgroundColor: isError ? Colors.red : Colors.green,
//     message: message,
//     duration: const Duration(seconds: 3),
//     snackStyle: SnackStyle.FLOATING,
//     margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//     borderRadius: 10,
//     isDismissible: true,
//     dismissDirection: DismissDirection.horizontal,
//   ));
// }

import 'package:fluttertoast/fluttertoast.dart';

// Import your dimensions file for the padding if needed,
// though Fluttertoast uses gravity for positioning.

void showCustomSnackBar(String? message, {bool isError = true}) {
  Fluttertoast.showToast(
    msg: message ?? "",
    toastLength: Toast.LENGTH_SHORT, // Duration (approx 2-3 seconds)
    gravity: ToastGravity.BOTTOM, // Position on screen
    timeInSecForIosWeb: 3, // Duration for iOS
    backgroundColor: isError ? Colors.red : Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
