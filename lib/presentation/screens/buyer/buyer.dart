import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/screens/home/home_privder.dart';

class BuyerScreen extends StatelessWidget {
  const BuyerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePrivder>(
      builder: (context, homeProvider, child) {
        return Flexible(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('category', isEqualTo: homeProvider.category)
                      .where('subCategory', isEqualTo: homeProvider.subCategory)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return ProductCard(
                          title: data['title'],
                          price: data['price'],
                          imageUrl: data['imageUrl'],
                          category: data['category'],
                          subCategory: data['subCategory'],
                        );
                      }).toList(),
                    );
                  },
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
  final String title;
  final double price;
  final String imageUrl;
  final String category;
  final String subCategory;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl,
              height: 200, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text('\$$price',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('Category: $category',
                    style: Theme.of(context).textTheme.bodySmall),
                Text('Subcategory: $subCategory',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
