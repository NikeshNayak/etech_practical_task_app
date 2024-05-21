import 'dart:math';

import 'package:flutter/material.dart';

const String baseUrl = "https://drive.google.com/uc";
const String thumbnailBaseUrl = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/";

String getFileSizeString({required int bytes, int decimals = 2}) {
  final List<String> suffixes = <String>['bytes', 'KB', 'MB', 'GB', 'TB'];
  if (bytes == 0) {
    return '0${suffixes[0]}';
  }
  int i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}

void showSnackMessage({required BuildContext context, required String title, required String text, required IconData icon, Color color = Colors.red, int seconds = 2, bool isFloating = true}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      behavior: isFloating ? SnackBarBehavior.floating : null,
      shape: isFloating ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)) : null,
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          )
        ],
      ),
      backgroundColor: color,
      duration: Duration(seconds: seconds),
    ),
  );
}
