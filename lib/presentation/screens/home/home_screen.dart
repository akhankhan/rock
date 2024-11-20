import 'package:fine_rock/core/models/user_model.dart';
import 'package:fine_rock/presentation/favorite/favorite_screen.dart';
import 'package:fine_rock/presentation/screens/buyer/add_product/add_product.dart';
import 'package:fine_rock/presentation/screens/buyer/buyer.dart';
import 'package:fine_rock/presentation/screens/home/home_provider.dart';
import 'package:fine_rock/presentation/screens/seller/seller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/screens/auth/auth_controller.dart';
import '../../edit_profile/edit_profile_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthController>(context);
    final user = authProvider.userModel;

    return ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: Consumer<HomeProvider>(
        builder: (context, provider, child) => Scaffold(
          appBar: _buildAppBar(context, provider),
          drawer: _buildDrawer(context, user, authProvider),
          body: _buildBody(provider),
          floatingActionButton: _buildFloatingActionButton(context, provider),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, HomeProvider provider) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text('Fine Rock',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
      actions: [
        _buildRoleToggle(provider, context),
      ],
    );
  }

  Widget _buildRoleToggle(HomeProvider provider, context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButton<Role>(
        value: provider.selectedRole,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        underline: Container(height: 2, color: Colors.white),
        onChanged: (Role? newValue) {
          provider.setRole(newValue!);
        },
        items: Role.values.map<DropdownMenuItem<Role>>((Role value) {
          return DropdownMenuItem<Role>(
            value: value,
            child: Text(value.toString().split('.').last.toUpperCase()),
          );
        }).toList(),
        dropdownColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context, UserModel? user, AuthController authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? 'User',
                style: TextStyle(fontSize: 18.sp)),
            accountEmail:
                Text(user?.email ?? '', style: TextStyle(fontSize: 14.sp)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.profileImageUrl != null
                  ? NetworkImage(user!.profileImageUrl!)
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColorLight
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen())),
          ),
          _buildDrawerItem(
            icon: Icons.favorite,
            title: 'Favorite',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesScreen())),
          ),
          _buildDrawerItem(
            icon: Icons.exit_to_app,
            title: 'Logout',
            onTap: () => authProvider.logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      onTap: onTap,
    );
  }

  Widget _buildBody(HomeProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: provider.selectedRole == Role.buyer
          ? const BuyerScreen()
          : const SellerScreen(),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, HomeProvider provider) {
    return provider.selectedRole == Role.seller
        ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddProductScreen()));
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        : null;
  }
}
