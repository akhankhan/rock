import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/logger.dart';

class StripeService {
  static const String _secretKey =
      'sk_test_51NwgHwDLhc7CAq0Wxa7ju6viBcxAu9Sk8KfEmtGxiqytd3DTa9pR2l2v9sKnAxvXPHb43XgZ663En0lNjxRoLDee00cXrQPOYg';

  static const String _publishableKey =
      'pk_test_51NwgHwDLhc7CAq0WXEhFjBFRnbsBNALfgojMa31mxcdEHansVRhCyPahuKikFwpRUVZXqCHOah8htZDE0FEScKFk00sL95eOnG';

  static Future<void> initialize() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      AppLogger.log('Error creating payment intent: $err');
      throw Exception(err);
    }
  }

  static Future<void> makePayment(
      {required String amount, required String currency}) async {
    try {
      // Create payment intent
      Map<String, dynamic> paymentIntent =
          await createPaymentIntent(amount, currency);

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Your App Name',
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      AppLogger.log('Payment completed successfully');
    } catch (err) {
      AppLogger.log('Error making payment: $err');
      throw Exception(err);
    }
  }
}
