import 'dart:async';
import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  void _submit() async {
    print('submit');
    final isValid = _form.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      //show error message
      print('LllLLLLLLLLLLL');
      print(_selectedImage);
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = await FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'password': _enteredPassword,
          'imageUrl': imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              width: 200,
              child: Image.asset('assets/images/chat.png'),
            ),
            Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                    key: _form,
                    child: Column(children: [
                      if (!_isLogin)
                        UserImagePicker(
                          onPickImage: (pickedImage) {
                            _selectedImage = pickedImage;
                          },
                        ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Please input a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      if (!_isLogin)
                        TextFormField(
                          decoration: InputDecoration(
                            label: Text('Username'),
                          ),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return 'Please enter at least 4 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredUsername = value!;
                          },
                        ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredPassword = value!;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (_isAuthenticating) const CircularProgressIndicator(),
                      if (!_isAuthenticating)
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            onPressed: _submit,
                            child: _isLogin ? Text('Login') : Text('Signup')),
                      if (!_isAuthenticating)
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: _isLogin
                                ? Text('Create an account')
                                : Text('I already have an account'))
                    ])),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
