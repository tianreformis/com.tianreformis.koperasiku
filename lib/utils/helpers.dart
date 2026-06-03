import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false, bool isSuccess = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? Colors.red.shade600
          : isSuccess
              ? Colors.green.shade600
              : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String formatError(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Terjadi kesalahan';
  }
}
