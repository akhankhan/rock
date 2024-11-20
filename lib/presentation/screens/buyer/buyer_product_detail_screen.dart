import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:fine_rock/core/utils/whatsapp_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../cart/cart_provider.dart';
import '../../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String subCategory;
  final String phoneNumber;
  final String description;
  final Function(bool)? onFavoriteChanged;

  const ProductDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrls,
    required this.category,
    required this.subCategory,
    required this.phoneNumber,
    this.description = '',
    this.onFavoriteChanged,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isLoading = true;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isFavorite = _prefs.getBool('favorite_${widget.id}') ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    final newState = !_isFavorite;
    setState(() {
      _isFavorite = newState;
    });

    try {
      await _prefs.setBool('favorite_${widget.id}', newState);
      widget.onFavoriteChanged?.call(newState);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = !newState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return cart.itemCount > 0
                        ? Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16.w,
                              minHeight: 16.w,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ImageSlideshow(
                  width: double.infinity,
                  height: 300,
                  initialPage: 0,
                  indicatorColor: Colors.white,
                  indicatorBackgroundColor: Colors.white.withOpacity(0.4),
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  autoPlayInterval: widget.imageUrls.length > 1 ? 3000 : 0,
                  isLoop: widget.imageUrls.length > 1,
                  children: widget.imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                        );
                      },
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${widget.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Chip(
                        label: Text(widget.category),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Category', widget.category),
                  _buildDetailRow('Subcategory', widget.subCategory),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      WhatsAppLauncher.launch(widget.phoneNumber, context);
                    },
                    icon: SvgPicture.asset(
                      "assets/whatsapp.svg",
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                    label: const Text('Contact Seller'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final cart = Provider.of<CartProvider>(context, listen: false);
          cart.addItem(
            productId: widget.id,
            title: widget.title,
            price: widget.price,
            imageUrl: widget.imageUrls.first,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Added to cart'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  cart.removeItem(widget.id);
                },
              ),
            ),
          );
        },
        label: const Text('Add to Cart'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
