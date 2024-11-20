import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fine_rock/presentation/screens/buyer/buyer_product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/screens/home/home_provider.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
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
      // Load more products when reaching the bottom
      // Implement pagination logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
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
          hintText: 'Search products...',
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

  Widget _buildCategoryFilters(HomeProvider homeProvider) {
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

  Widget _buildProductList(HomeProvider homeProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
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

              return ProductCard(
                id: data['id'] ?? '',
                title: data['title'] ?? 'No Title',
                price: (data['price'] as num?)?.toDouble() ?? 0,
                imageUrls: List<String>.from(data['imageUrls'] ?? []),
                category: data['category'] ?? 'No Category',
                subCategory: data['subCategory'] ?? 'No Subcategory',
                phoneNumber: data['phoneNumber'] ?? '',
                description: data['description'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String subCategory;
  final String phoneNumber;
  final String description;

  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrls,
    required this.category,
    required this.subCategory,
    required this.phoneNumber,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              id: id,
              title: title,
              price: price,
              imageUrls: imageUrls,
              category: category,
              subCategory: subCategory,
              phoneNumber: phoneNumber,
              description: description,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15.r)),
                    child: imageUrls.isNotEmpty
                        ? ImageSlideshow(
                            width: double.infinity,
                            height: double.infinity,
                            initialPage: 0,
                            indicatorColor: Colors.white,
                            indicatorBackgroundColor:
                                Colors.white.withOpacity(0.4),
                            autoPlayInterval: 0, // Disable autoplay
                            isLoop: true,
                            children: imageUrls.map((url) {
                              return Image.network(
                                url,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          )
                        : Image.network(
                            'https://placeholder.com/300',
                            fit: BoxFit.cover,
                            width: double.infinity,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
