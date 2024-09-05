import 'package:fine_rock/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Column(
        children: [
          SizedBox(20.h)
          CustomTextField(
            labelText: 'Enter title',
          ),
        ],
      ),
    );
  }
}
