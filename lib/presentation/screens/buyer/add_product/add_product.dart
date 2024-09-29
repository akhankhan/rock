import 'package:fine_rock/presentation/screens/auth/auth_controller.dart';
import 'package:fine_rock/presentation/screens/buyer/add_product/add_product_provider.dart';
import 'package:fine_rock/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/custom_button.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddProductProvider(
        Provider.of<AuthController>(context, listen: false),
      ),
      child: Consumer<AddProductProvider>(
        builder: (context, provider, child) => Scaffold(
          appBar: AppBar(
            title: const Text('Add Product'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Images (Max 6)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ...provider.images.asMap().entries.map((entry) {
                        int index = entry.key;
                        var image = entry.value;
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => provider.removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (provider.images.length < AddProductProvider.maxImages)
                        GestureDetector(
                          onTap: () => provider.addImage(),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hint: 'Enter title',
                    labelText: 'Enter title',
                    controller: provider.titleController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hint: 'Enter Price',
                    labelText: 'Enter Price',
                    controller: provider.priceController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hint: 'Enter Description',
                    labelText: 'Enter Description',
                    controller: provider.descController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hint: 'Size',
                          labelText: 'Size',
                          controller: provider.sizeController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          hint: 'Color',
                          labelText: 'Color',
                          controller: provider.colorController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: provider.selectedCategory,
                    items: provider.categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      provider.setCategory(newValue);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: provider.selectedSubCategory,
                    items: provider.subcategories.map((String subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory,
                        child: Text(subcategory),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      provider.setSubCategory(newValue);
                    },
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    isLoading: provider.isLoading,
                    title: "Submit",
                    onTap: () => provider.addProduct(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
