import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fine_rock/presentation/screens/auth/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthController>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'User'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
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
      body: Center(
        child: Text('Welcome, ${user?.displayName ?? 'User'}!'),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthController>(context, listen: false);
    _nameController =
        TextEditingController(text: authProvider.user?.displayName);
  }

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final authProvider = Provider.of<AuthController>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      String? imageUrl;

      // Update profile picture
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child('${user.uid}.jpg');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      // Prepare data to update
      Map<String, dynamic> updateData = {
        'fullName': _nameController.text,
      };

      if (imageUrl != null) {
        updateData['profileImageUrl'] = imageUrl;
      }

      // Update Firestore
      await authProvider.updateUserData(user.uid, updateData);

      // Update Firebase Auth user
      await user.updateDisplayName(_nameController.text);
      if (imageUrl != null) {
        await user.updatePhotoURL(imageUrl);
      }

      // Refresh the user
      await authProvider.refreshUser();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthController>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/default_profile.png'))
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
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
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
