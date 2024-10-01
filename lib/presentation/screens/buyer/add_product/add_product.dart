import 'package:fine_rock/presentation/screens/auth/auth_controller.dart';
import 'package:fine_rock/presentation/screens/buyer/add_product/add_product_provider.dart';
import 'package:fine_rock/presentation/widgets/custom_textfield.dart';
import 'package:fine_rock/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            title: Text('Add Product',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(provider),
                  SizedBox(height: 24.h),
                  _buildProductInfoSection(provider),
                  SizedBox(height: 24.h),
                  _buildCategorySection(provider),
                  SizedBox(height: 32.h),
                  CustomButton(
                    isLoading: provider.isLoading,
                    title: "Submit",
                    onTap: () => _handleSubmit(context, provider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(AddProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images (Max 6)',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            ...provider.images.asMap().entries.map((entry) {
              int index = entry.key;
              var image = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4.h,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => provider.removeImage(index),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(Icons.close, color: Colors.white, size: 16.w),
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
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate,
                    size: 40.w,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductInfoSection(AddProductProvider provider) {
    return Column(
      children: [
        CustomTextField(
          hint: 'Enter title',
          labelText: 'Title',
          controller: provider.titleController,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hint: 'Enter Price',
          labelText: 'Price',
          controller: provider.priceController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hint: 'Enter Description',
          labelText: 'Description',
          controller: provider.descController,
          maxLines: 3,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: 'Size',
                labelText: 'Size',
                controller: provider.sizeController,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomTextField(
                hint: 'Color',
                labelText: 'Color',
                controller: provider.colorController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(AddProductProvider provider) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
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
        SizedBox(height: 16.h),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Subcategory',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
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
      ],
    );
  }

  void _handleSubmit(BuildContext context, AddProductProvider provider) async {
    if (provider.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    try {
      await provider.addProduct();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      Navigator.of(context).pop(); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: ${e.toString()}')),
      );
    }
  }
}
