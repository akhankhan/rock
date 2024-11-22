import 'package:flutter/material.dart';

class SellerScreen extends StatelessWidget {
  const SellerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome to Seller Dashboard'),
      ),
    );
  }
} 