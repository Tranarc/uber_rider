import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:uber_clone/map_assistance/assistant_methods.dart';
import 'package:uber_clone/screens/main_screen.dart';
import 'package:uber_clone/screens/auth/signup.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';

class SignIn extends StatefulWidget {
  static const String routeName = 'Signin';

  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FocusNode passFocus = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool _isLoading = false;
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    passFocus.dispose();
    super.dispose();
  }

  bool _visible = true;

  @override
  initState() {
    //asynchronous delay
    if (this.mounted) {
      //checks if widget is still active and not disposed
      setState(() {
        //tells the widget builder to rebuild again because ui has updated
        _visible =
            false; //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
      });
    }

    super.initState();
  }

  Future<void> _submitData() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await signInNewUser(context);
    } catch (err) {
      final errMsg = 'Could not authenticate you at the moment';
      showErrDialog(errMsg, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            return OfflineBuilder(
              connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivity, Widget child) {
                final bool connected = connectivity != ConnectivityResult.none;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    child,
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      height: 32.0,
                      child: connected
                          ? Container()
                          : Visibility(
                              visible: connected ? _visible : _visible = true,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                color: connected
                                    ? Color(0xFF00EE44)
                                    : Color(0xFFEE4400),
                                child: connected
                                    ? Center(
                                        child: Text(
                                          "ONLINE",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "OFFLINE",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          SizedBox(
                                            width: 8.0,
                                          ),
                                          SizedBox(
                                            width: 12.0,
                                            height: 12.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                    ),
                  ],
                );
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Form(
                    key: _form,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        Image(
                          image: AssetImage("assets/images/logo.png"),
                          width: 350,
                          height: 320,
                          alignment: Alignment.center,
                        ),
                        Text(
                          'Login as a rider',
                          style:
                              TextStyle(fontFamily: "Semibold", fontSize: 24.0),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(passFocus);
                          },
                          validator: (val) {
                            if (!val!.contains('@') || !val.contains('.com')) {
                              return 'Invalid Email';
                            }
                            return null;
                          },
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(
                                fontSize: 14.0,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                              )),
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(
                          height: 1.0,
                        ),
                        TextFormField(
                          focusNode: passFocus,
                          validator: (val) {
                            if (val!.length < 6) {
                              return 'password muss be at least 6';
                            }
                            return null;
                          },
                          controller: passController,
                          obscureText: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: "password",
                              labelStyle: TextStyle(
                                fontSize: 14.0,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                              )),
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        if (_isLoading)
                          CircularProgressIndicator()
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.yellow, shape: StadiumBorder()),
                            onPressed: () => _submitData(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              height: 50,
                              child: Center(
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Semibold',
                                      color: Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 30,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, SignUp.routeName);
                          },
                          child: Text('Do not have an Account? Register Now'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  signInNewUser(BuildContext context) async {
    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailController.text, password: passController.text)
            .catchError(
      (onError) {
        displayToast('error: ' + onError.toString(), context);
        print(onError);
      },
    ))
        .user;
    if (firebaseUser != null) {
      Navigator.pushNamed(context, MainScreen.routeName);
      displayToast('Succefully Logged IN', context);
    } else {
      displayToast('User Account Cannot be Logged in', context);
    }
  }
}
