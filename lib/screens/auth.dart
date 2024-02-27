import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = false;
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
    }
    print(_enteredEmail);
    print(_enteredPassword);
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
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.length > 6) {
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
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          onPressed: _submit,
                          child: _isLogin ? Text('Login') : Text('Signup')),
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
