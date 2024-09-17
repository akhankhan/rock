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
        create: (context) => AddProductProvider(),
        child: Consumer<AddProductProvider>(
          builder: (context, provider, child) => Scaffold(
            appBar: AppBar(
              title: const Text('Add Product'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => provider.getImageGallery(),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: provider.image != null
                            ? Image.file(provider.image!, fit: BoxFit.cover)
                            : const Center(
                                child: Text(
                                "Select Image",
                                style:
                                    TextStyle(fontSize: 20, color: Colors.grey),
                              )),
                      ),
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
                      hintText: 'Enter Description',
                      labelText: 'Enter Description',
                      controller: provider.descController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            labelText: 'Size',
                            controller: provider.sizeController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
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
        ));
  }
}
