import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class WhatsAppLauncher {
  static Future<void> launch(String phoneNumber, BuildContext context) async {
    // Remove any non-digit characters from the phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]+'), '');

    // Construct the WhatsApp URL
    final whatsappUrl = "https://wa.me/$phoneNumber";

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl),
            mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching WhatsApp: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
