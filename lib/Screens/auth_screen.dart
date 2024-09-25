import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/Screens/to_do.dart';

import '../Widgets/custom_button.dart';
import '../Widgets/custom_textfield.dart';

enum Auth { signin, signup }

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Auth _auth = Auth.signin;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> signUpUser() async {
    if (_signUpFormKey.currentState!.validate()) {
      try {
        // Create user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String? imageUrl;
        if (_image != null) {
          // Upload profile image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profilePics/${userCredential.user!.uid}');
          UploadTask uploadTask = storageRef.putFile(_image!);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Save user details in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'profilePic': imageUrl ?? '', // Save profile image URL
        }).catchError((error) {
          print('Error writing user document: $error');
        });

        // Navigate to MainScaffold (home screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TodoScreen(
              setState: () {
                return setState(() {});
              },
            ),
          ),
        );
      } catch (e) {
        print('Error signing up: $e');
      }
    }
  }

  Future<void> signInUser() async {
    if (_signInFormKey.currentState!.validate()) {
      try {
        // Sign in with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Navigate to MainScaffold (home screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TodoScreen(
              setState: () {
                return setState(() {});
              },
            ),
          ),
        );
      } catch (e) {
        print('Error signing in: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            children: [
              const Text(
                'To Do',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                tileColor: _auth == Auth.signup ? Colors.white10 : Colors.white,
                title: const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
                leading: Radio(
                  activeColor: Colors.orange,
                  value: Auth.signup,
                  groupValue: _auth,
                  onChanged: (Auth? val) {
                    setState(() {
                      _auth = val!;
                    });
                  },
                ),
              ),
              if (_auth == Auth.signup)
                Form(
                  key: _signUpFormKey,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: Colors.white10,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 30,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Name',
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          onTap: signUpUser,
                          text: 'Sign Up',
                        ),
                      ],
                    ),
                  ),
                ),
              ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                tileColor: _auth == Auth.signin ? Colors.white10 : Colors.white,
                title: const Text(
                  'Sign-In',
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
                leading: Radio(
                  activeColor: Colors.orange,
                  value: Auth.signin,
                  groupValue: _auth,
                  onChanged: (Auth? val) {
                    setState(() {
                      _auth = val!;
                    });
                  },
                ),
              ),
              if (_auth == Auth.signin)
                Form(
                  key: _signInFormKey,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: Colors.white10,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          onTap: signInUser,
                          text: 'Sign In',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
