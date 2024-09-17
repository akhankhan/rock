import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/widgets/custom_textfield.dart';
import 'package:fine_rock/presentation/widgets/custom_button.dart';
import 'edit_product_provider.dart';

class EditProductScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditProductProvider(
        productId: productId,
        initialProductData: productData,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
        ),
        body: Consumer<EditProductProvider>(
          builder: (context, provider, child) {
            // if (provider.isLoading!) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: provider.getImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: provider.image != null
                            ? Image.file(provider.image!, fit: BoxFit.cover)
                            : (provider.currentImageUrl != null
                                ? Image.network(provider.currentImageUrl!,
                                    fit: BoxFit.cover)
                                : const Center(
                                    child: Text('Tap to select image'))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Title',
                      labelText: 'Title',
                      controller: provider.titleController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Price',
                      labelText: 'Price',
                      controller: provider.priceController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Description',
                      labelText: 'Description',
                      controller: provider.descController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Size',
                      labelText: 'Size',
                      controller: provider.sizeController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hint: 'Color',
                      labelText: 'Color',
                      controller: provider.colorController,
                    ),
                    const SizedBox(height: 16),
                    IntlPhoneField(
                      // controller: widget.phoneNumController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: kBluePrimary, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (phone) {
                        provider.setPhoneNumber(phone.completeNumber);
                      },
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      isLoading: provider.isLoading,
                      title: 'Update Product',
                      onTap: () => _updateProduct(context, provider),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _updateProduct(
      BuildContext context, EditProductProvider provider) async {
    try {
      await provider.updateProduct();
      if (provider.updateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
