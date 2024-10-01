import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/screens/home/home_privder.dart';
import 'package:fine_rock/presentation/screens/auth/auth_controller.dart';
import 'edit_product_screen.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Implement pagination logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePrivder>(
      builder: (context, homeProvider, child) {
        return Column(
          children: [
            _buildSearchBar(),
            _buildCategoryFilters(homeProvider),
            Expanded(
              child: _buildProductList(homeProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your products...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilters(HomePrivder homeProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              value: homeProvider.category,
              items: homeProvider.categorySubcategoryMap.keys.toList(),
              onChanged: (String? newValue) {
                homeProvider.setCategory(newValue);
              },
              hint: 'Select Category',
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildDropdown(
              value: homeProvider.subCategory,
              items:
                  homeProvider.categorySubcategoryMap[homeProvider.category] ??
                      [],
              onChanged: (String? newValue) {
                homeProvider.setSubCategory(newValue);
              },
              hint: 'Select Subcategory',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 14.sp)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 14.sp)),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildProductList(HomePrivder homeProvider) {
    final authProvider = Provider.of<AuthController>(context, listen: false);
    final user = authProvider.userModel;

    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('userId', isEqualTo: user?.id)
            .where('category', isEqualTo: homeProvider.category)
            .where('subCategory', isEqualTo: homeProvider.subCategory)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong',
                    style: TextStyle(fontSize: 16.sp)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No products found',
                    style: TextStyle(fontSize: 16.sp)));
          }

          List<DocumentSnapshot> filteredDocs = snapshot.data!.docs
              .where((doc) =>
                  doc['title'].toString().toLowerCase().contains(_searchQuery))
              .toList();

          return GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.w,
            ),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = filteredDocs[index];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return SellerProductCard(
                id: data['id'] ?? '',
                title: data['title'] ?? 'No Title',
                price: (data['price'] as num?)?.toDouble() ?? 0,
                imageUrls: List<String>.from(data['imageUrls'] ?? []),
                category: data['category'] ?? 'No Category',
                subCategory: data['subCategory'] ?? 'No Subcategory',
                onEdit: () => _editProduct(context, document.id, data),
                onDelete: () => _deleteProduct(context, document.id),
              );
            },
          );
        },
      ),
    );
  }

  void _editProduct(BuildContext context, String productId,
      Map<String, dynamic> productData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          productId: productId,
          productData: productData,
        ),
      ),
    );
  }

  void _deleteProduct(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SellerProductCard extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String subCategory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SellerProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrls,
    required this.category,
    required this.subCategory,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15.r)),
                    child: imageUrls.isNotEmpty
                        ? CarouselSlider(
                            options: CarouselOptions(
                              aspectRatio: 1,
                              viewportFraction: 1,
                              autoPlay: false,
                              autoPlayInterval: const Duration(seconds: 3),
                            ),
                            items: imageUrls.map((url) {
                              return Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            }).toList(),
                          )
                        : Image.network(
                            'https://placeholder.com/300',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '$category - $subCategory',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.edit, size: 12.w),
                        label: Text('Edit', style: TextStyle(fontSize: 9.sp)),
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    5.horizontalSpace,
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.delete,
                          size: 12.w,
                          color: Colors.white,
                        ),
                        label: Text('Delete',
                            style:
                                TextStyle(fontSize: 9.sp, color: Colors.white)),
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
