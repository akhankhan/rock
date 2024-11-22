import 'package:fine_rock/presentation/screens/forgot_password/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fine_rock/presentation/screens/auth/auth_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:animate_do/animate_do.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'Buyer';
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    if (_isLogin) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _showErrorSnackBar(String message) {
    print('Showing error SnackBar: $message'); // Debug log
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      SizedBox(height: 48.h),
                      _buildAuthCard(),
                      SizedBox(height: 24.h),
                      _buildToggleAuthModeButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Role',
          style: TextStyle(
            color: const Color(0xFF1E3C72).withOpacity(0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF1E3C72).withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Buyer'),
                  value: 'buyer',
                  groupValue: _selectedRole.toLowerCase(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  activeColor: const Color(0xFF1E3C72),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Seller'),
                  value: 'seller',
                  groupValue: _selectedRole.toLowerCase(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  activeColor: const Color(0xFF1E3C72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),
      ),
      child: CustomPaint(
        painter: BackgroundPainter(),
        child: Container(),
      ),
    );
  }

  Widget _buildLogo() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80.w,
            color: Colors.white,
          ),
          SizedBox(height: 16.h),
          Text(
            'Fine Rock',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Consumer<AuthController>(
      builder: (context, authProvider, child) {
        return FadeInUp(
          duration: const Duration(milliseconds: 800),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3C72),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  if (!_isLogin) ...[
                    _buildAnimatedTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildPhoneField(authProvider),
                    SizedBox(height: 16.h),
                  ],
                  _buildEmailField(),
                  SizedBox(height: 16.h),
                  _buildPasswordField(),
                  SizedBox(height: 24.h),
                  _buildRoleSelector(),
                  SizedBox(height: 24.h),
                  if (_isLogin) _buildAuthButton(authProvider),
                  if (_isLogin) ...[
                    SizedBox(height: 16.h),
                    _buildForgotPasswordButton(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return ElasticIn(
      duration: const Duration(milliseconds: 800),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Color(0xFF1E3C72)),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle:
              TextStyle(color: const Color(0xFF1E3C72).withOpacity(0.7)),
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF1E3C72)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF1E3C72),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(color: const Color(0xFF1E3C72).withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(color: const Color(0xFF1E3C72).withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF1E3C72)),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return ElasticIn(
      duration: const Duration(milliseconds: 800),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFF1E3C72)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: const Color(0xFF1E3C72).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: const Color(0xFF1E3C72)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(color: const Color(0xFF1E3C72).withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(color: const Color(0xFF1E3C72).withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF1E3C72)),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPhoneField(AuthController authProvider) {
    return ElasticIn(
      duration: const Duration(milliseconds: 800),
      child: IntlPhoneField(
        initialCountryCode: 'PK',
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle:
              TextStyle(color: const Color(0xFF1E3C72).withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(color: const Color(0xFF1E3C72).withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide:
                BorderSide(color: const Color(0xFF1E3C72).withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF1E3C72)),
          ),
        ),
        dropdownTextStyle: const TextStyle(color: Color(0xFF1E3C72)),
        style: const TextStyle(color: Color(0xFF1E3C72)),
        onChanged: (phone) {
          authProvider.phoneNumber = phone.completeNumber;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return _buildAnimatedTextField(
      controller: _emailController,
      label: 'Email',
      icon: Icons.email,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildAuthButton(AuthController authProvider) {
    return ElasticIn(
      duration: const Duration(milliseconds: 800),
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    if (_isLogin) {
                      await authProvider.login(
                        email: _emailController.text,
                        password: _passwordController.text,
                        role: _selectedRole,
                        context: context,
                        

                      );
                    } else {
                      await authProvider.signUp(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                        _selectedRole,
                      );
                    }
                    // Handle successful login/signup
                  } catch (e) {
                    _showErrorSnackBar(e.toString());
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF1E3C72),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.w,
                ),
              )
            : Text(
                _isLogin ? 'Login' : 'Sign Up',
                style: TextStyle(fontSize: 16.sp),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
        );
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(color: Color(0xFF1E3C72)),
      ),
    );
  }

  Widget _buildToggleAuthModeButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 800),
      child: TextButton(
        onPressed: _toggleAuthMode,
        child: Text(
          _isLogin ? 'Create an account' : 'I already have an account',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.7,
          size.width * 0.5, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
