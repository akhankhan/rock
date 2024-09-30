import 'package:fine_rock/core/models/product_model.dart';
import 'package:fine_rock/core/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fine_rock/presentation/screens/buyer/buyer_product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final favoriteKeys =
          allKeys.where((key) => key.startsWith('favorite_')).toList();

      List<Product> favorites = [];
      for (String key in favoriteKeys) {
        bool isFavorite = prefs.getBool(key) ?? false;
        if (isFavorite) {
          String productId = key.substring(9); // Remove 'favorite_' prefix
          Product? product = await ProductService.getProductById(productId);
          if (product != null) {
            favorites.add(product);
          }
        }
      }

      setState(() {
        _favoriteProducts = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        _isLoading = false;
      });
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load favorites. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteProducts.isEmpty
              ? const Center(child: Text('No favorite products'))
              : ListView.builder(
                  itemCount: _favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = _favoriteProducts[index];
                    return ListTile(
                      leading: _buildProductImage(product),
                      title: Text(product.title),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              id: product.id,
                              title: product.title,
                              price: product.price,
                              imageUrls: product.imageUrls,
                              category: product.category,
                              subCategory: product.subCategory,
                              phoneNumber: product.phoneNumber,
                              description: product.description,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imageUrls.isNotEmpty) {
      return Image.network(
        product.imageUrls.first,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return const Icon(Icons.error);
        },
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        color: Colors.grey,
        child: const Icon(Icons.image_not_supported, color: Colors.white),
      );
    }
  }
}
