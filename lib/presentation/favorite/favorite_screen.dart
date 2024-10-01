import 'package:fine_rock/core/models/product_model.dart';
import 'package:fine_rock/core/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fine_rock/presentation/screens/buyer/buyer_product_detail_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load favorites. Please try again.')),
      );
    }
  }

  void _removeFromFavorites(String productId) {
    setState(() {
      _favoriteProducts.removeWhere((product) => product.id == productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(fontSize: 20.sp)),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favoriteProducts.isEmpty
                ? _buildEmptyState()
                : _buildFavoriteGrid(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80.w, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'No favorite products yet',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add some products to your favorites!',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.w,
      ),
      itemCount: _favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: _buildProductImage(product),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 14.sp, color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${product.category} - ${product.subCategory}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
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

  Widget _buildProductImage(Product product) {
    return product.imageUrls.isNotEmpty
        ? Image.network(
            product.imageUrls.first,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return _buildPlaceholderImage();
            },
          )
        : _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child:
          Icon(Icons.image_not_supported, color: Colors.grey[600], size: 40.w),
    );
  }

  void _navigateToProductDetail(Product product) async {
    final result = await Navigator.push(
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
          onFavoriteChanged: (isFavorite) {
            if (!isFavorite) {
              _removeFromFavorites(product.id);
            }
          },
        ),
      ),
    );
  }
}
