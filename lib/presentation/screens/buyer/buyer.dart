import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fine_rock/core/utils/whatsapp_launcher.dart';
import 'package:fine_rock/presentation/screens/buyer/buyer_product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/screens/home/home_privder.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePrivder>(
      builder: (context, homeProvider, child) {
        return Flexible(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: homeProvider.category,
                        items: homeProvider.categorySubcategoryMap.keys
                            .map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          homeProvider.setCategory(newValue);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: homeProvider.subCategory,
                        items: homeProvider
                                .categorySubcategoryMap[homeProvider.category]
                                ?.map((String subcategory) {
                              return DropdownMenuItem<String>(
                                value: subcategory,
                                child: Text(subcategory),
                              );
                            }).toList() ??
                            [],
                        onChanged: (String? newValue) {
                          homeProvider.setSubCategory(newValue);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Implement refresh logic
                  },
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('category', isEqualTo: homeProvider.category)
                        .where('subCategory',
                            isEqualTo: homeProvider.subCategory)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No products found'));
                      }

                      List<DocumentSnapshot> filteredDocs = snapshot.data!.docs
                          .where((doc) => doc['title']
                              .toString()
                              .toLowerCase()
                              .contains(_searchQuery))
                          .toList();

                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = filteredDocs[index];
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          double price = 0;
                          if (data['price'] != null) {
                            if (data['price'] is num) {
                              price = (data['price'] as num).toDouble();
                            } else if (data['price'] is String) {
                              price = double.tryParse(data['price']) ?? 0;
                            }
                          }

                          List<String> imageUrls = [];
                          if (data['imageUrls'] != null &&
                              data['imageUrls'] is List) {
                            imageUrls = List<String>.from(data['imageUrls']);
                          } else if (data['imageUrl'] != null) {
                            imageUrls = [data['imageUrl']];
                          }

                          return ProductCard(
                            id: data['id'] ?? '',
                            title: data['title'] ?? 'No Title',
                            price: price,
                            imageUrls: imageUrls,
                            category: data['category'] ?? 'No Category',
                            subCategory:
                                data['subCategory'] ?? 'No Subcategory',
                            phoneNumber: data['phoneNumber'] ?? '',
                            description: data['description'] ?? '',
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrls.isNotEmpty
                      ? imageUrls[0]
                      : 'https://placeholder.com/300',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$category - $subCategory',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
