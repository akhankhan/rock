import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/auth/auth_controller.dart';
import 'edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditProfileProvider(
        authController: Provider.of<AuthController>(context, listen: false),
      ),
      child: const _EditProfileContent(),
    );
  }
}

class _EditProfileContent extends StatelessWidget {
  const _EditProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditProfileProvider>(context);
    final user = provider.authController.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: provider.getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: provider.image != null
                    ? FileImage(provider.image!)
                    : (user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/default_profile.png'))
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: provider.nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: user?.email,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.updateProfile(context),
              child: provider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
