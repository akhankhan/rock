import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class WhatsAppLauncher {
  static Future<void> launch(String phoneNumber, BuildContext context) async {
    log("check number: $phoneNumber");
    // Remove any non-digit characters except the '+' sign
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]+'), '');

    // If the number starts with '+', remove it
    if (phoneNumber.startsWith('+')) {
      phoneNumber = phoneNumber.substring(1);
    }

    String url;
    if (Platform.isAndroid) {
      url = "whatsapp://send?phone=$phoneNumber";
    } else if (Platform.isIOS) {
      url = "https://wa.me/$phoneNumber";
    } else {
      url = "https://web.whatsapp.com/send?phone=$phoneNumber";
    }

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // If we can't launch the WhatsApp URL, try opening the app store
        String appStoreUrl = Platform.isAndroid
            ? "market://details?id=com.whatsapp"
            : "https://apps.apple.com/app/whatsapp-messenger/id310633997";
        if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
          await launchUrl(Uri.parse(appStoreUrl),
              mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch WhatsApp or open app store';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Error: WhatsApp is not installed or could not be opened'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
