// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instgram/resources/auth_methods.dart';
import 'package:instgram/utils/colors.dart';
import 'package:instgram/utils/utils.dart';
import 'package:instgram/widgets/text_field_input.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout.dart';
import '../responsive/web_screen_layout.dart';
import 'login_screen.dart';

class SigupScreen extends StatefulWidget {
  const SigupScreen({super.key});

  @override
  State<SigupScreen> createState() => _SigupScreenState();
}

class _SigupScreenState extends State<SigupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Uint8List? _image;
  bool _isLoadng = false;
  void selectImage() async {
    Uint8List image = await pickImage(ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  signUp() async {
    setState(() {
      _isLoadng = true;
    });
    String res = await AuthMethods().signUpUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        file: _image!);
    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout()),
      ));
    }
    setState(() {
      _isLoadng = false;
    });
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flexible(flex: 2, child: Container()),
                // const Spacer(),
                SvgPicture.asset(
                  'assets/ic_instagram.svg',
                  color: primaryColor,
                  height: 64,
                ),
                const SizedBox(height: 64),
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_image!))
                            : const CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage(
                                    'https://i.pinimg.com/736x/f1/0f/f7/f10ff70a7155e5ab666bcdd1b45b726d.jpg'),
                              ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(
                              Icons.add_a_photo,
                              color: secondaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      controller: _usernameController,
                      hintText: 'Enter your Username',
                      inputType: TextInputType.text,
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      controller: _emailController,
                      hintText: 'Enter your Email',
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      controller: _passwordController,
                      hintText: 'Enter your Password',
                      isPassword: true,
                      inputType: TextInputType.text,
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      controller: _bioController,
                      hintText: 'Enter your Bio',
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    _isLoadng
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : InkWell(
                            onTap: signUp,
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                color: blueColor,
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 12),
                // Flexible(flex: 2, child: Container()),
                // const Spacer(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text('Already have an account? '),
                    ),
                    GestureDetector(
                      onTap: navigateToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          'Login.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
