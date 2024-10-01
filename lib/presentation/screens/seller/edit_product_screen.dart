import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/widgets/custom_textfield.dart';
import 'package:fine_rock/presentation/widgets/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(context, provider),
                    SizedBox(height: 24.h),
                    _buildProductForm(context, provider),
                    SizedBox(height: 32.h),
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

  Widget _buildImageSection(
      BuildContext context, EditProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...provider.currentImageUrls.asMap().entries.map(
                    (entry) => _buildImageCard(
                      context,
                      imageUrl: entry.value,
                      onRemove: () => provider.removeCurrentImage(entry.key),
                    ),
                  ),
              ...provider.newImages.asMap().entries.map(
                    (entry) => _buildImageCard(
                      context,
                      imageFile: entry.value,
                      onRemove: () => provider.removeNewImage(entry.key),
                    ),
                  ),
              _buildAddImageCard(context, provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(BuildContext context,
      {String? imageUrl, File? imageFile, required VoidCallback onRemove}) {
    return Container(
      width: 100.w,
      height: 100.w,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: imageUrl != null
                ? Image.network(imageUrl,
                    fit: BoxFit.cover, width: 100.w, height: 100.w)
                : Image.file(imageFile!,
                    fit: BoxFit.cover, width: 100.w, height: 100.w),
          ),
          Positioned(
            top: 4.w,
            right: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageCard(
      BuildContext context, EditProductProvider provider) {
    return GestureDetector(
      onTap: provider.addImage,
      child: Container(
        width: 100.w,
        height: 100.w,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey),
        ),
        child: Icon(Icons.add_photo_alternate,
            size: 40.w, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildProductForm(BuildContext context, EditProductProvider provider) {
    return Column(
      children: [
        CustomTextField(
          hint: 'Title',
          labelText: 'Title',
          controller: provider.titleController,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hint: 'Price',
          labelText: 'Price',
          controller: provider.priceController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hint: 'Description',
          labelText: 'Description',
          controller: provider.descController,
          maxLines: 3,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hint: 'Size',
          labelText: 'Size',
          controller: provider.sizeController,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hint: 'Color',
          labelText: 'Color',
          controller: provider.colorController,
        ),
        SizedBox(height: 16.h),
        IntlPhoneField(
          controller: provider.phoneNumberController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(
              borderSide: const BorderSide(),
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          initialCountryCode: 'PK',
          onChanged: (PhoneNumber phone) {
            provider.setPhoneNumber(phone.completeNumber);
          },
          onCountryChanged: (country) {
            provider.phoneNumberController.clear();
          },
        ),
      ],
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
