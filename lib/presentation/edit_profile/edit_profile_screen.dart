import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/models/user_model.dart';
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
    final user = provider.authController.userModel;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Edit Profile',
              speed: const Duration(milliseconds: 100),
            ),
          ],
          isRepeatingAnimation: false,
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, provider, user),
            20.verticalSpace,
            _buildProfileForm(context, provider, user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, EditProfileProvider provider, UserModel? user) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Center(
        child: GestureDetector(
          onTap: provider.getImage,
          child: Stack(
            children: [
              Hero(
                tag: 'profileImage',
                child: CircleAvatar(
                  radius: 60.r,
                  backgroundImage: provider.image != null
                      ? FileImage(provider.image!)
                      : (user?.profileImageUrl != null &&
                                  user!.profileImageUrl!.isNotEmpty
                              ? NetworkImage(user.profileImageUrl!)
                              : const AssetImage('assets/default_profile.png'))
                          as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt,
                      size: 20.w, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm(
      BuildContext context, EditProfileProvider provider, UserModel? user) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildTextField(
            controller: provider.nameController,
            label: 'Name',
            icon: Icons.person,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: provider.phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            initialValue: user?.email,
            label: 'Email',
            icon: Icons.email,
            enabled: false,
          ),
          SizedBox(height: 32.h),
          _buildUpdateButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        filled: !enabled,
      ),
      keyboardType: keyboardType,
      enabled: enabled,
    );
  }

  Widget _buildUpdateButton(
      BuildContext context, EditProfileProvider provider) {
    return ElevatedButton(
      onPressed:
          provider.isLoading ? null : () => provider.updateProfile(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
      child: provider.isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.w,
              ),
            )
          : Text(
              'Update Profile',
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
            ),
    );
  }
}
