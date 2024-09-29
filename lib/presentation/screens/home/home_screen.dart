import 'package:fine_rock/presentation/screens/buyer/add_product/add_product.dart';
import 'package:fine_rock/presentation/screens/buyer/buyer.dart';
import 'package:fine_rock/presentation/screens/home/home_privder.dart';
import 'package:fine_rock/presentation/screens/seller/seller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/screens/auth/auth_controller.dart';

import '../../edit_profile/edit_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthController>(context);
    final user = authProvider.userModel;

    return ChangeNotifierProvider(
      create: (context) => HomePrivder(),
      child: Consumer<HomePrivder>(
        builder: (context, provider, child) => Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              PopupMenuButton<Role>(
                initialValue: provider.selectedRole,
                onSelected: (Role role) {
                  provider.setRole(role);
                },
                itemBuilder: (context) => [
                  PopupMenuItem<Role>(
                    value: Role.buyer,
                    child: Row(
                      children: [
                        const Text('Buyer'),
                        const Spacer(),
                        if (provider.selectedRole == Role.buyer)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              width: 15,
                              height: 15,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem<Role>(
                    value: Role.seller,
                    child: Row(
                      children: [
                        const Text('Seller'),
                        const Spacer(),
                        if (provider.selectedRole == Role.seller)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              width: 15,
                              height: 15,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user?.fullName ?? 'User'),
                  accountEmail: Text(user?.email ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Logout'),
                  onTap: () {
                    authProvider.logout();
                  },
                ),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.selectedRole == Role.buyer) const BuyerScreen(),
              if (provider.selectedRole == Role.seller) const SellerScreen(),
            ],
          ),
          floatingActionButton: provider.selectedRole == Role.seller
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProductScreen()));
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }
}
