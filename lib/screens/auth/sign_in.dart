import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:uber_clone/screens/auth/sign_up.dart';
import 'package:uber_clone/screens/auth/signup.dart';
import 'package:uber_clone/ui_reuse/constant.dart';
import 'package:uber_clone/ui_reuse/text_fields/my_text_button.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';

import '../main_screen.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
  bool isPasswordVisible = true;

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
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: SafeArea(
        //to make page scrollable
        child: Builder(builder: (BuildContext contexg) {
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
                                          style: TextStyle(color: Colors.white),
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
            child: CustomScrollView(
              reverse: true,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Form(
                            key: _form,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back",
                                  style: kHeadline,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "You've been missed!",
                                  style: kBodyText2,
                                ),
                                SizedBox(
                                  height: 60,
                                ),
                                TextFormField(
                                  style:
                                      kBodyText.copyWith(color: Colors.white),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(passFocus);
                                  },
                                  validator: (val) {
                                    if (!val!.contains('@') ||
                                        !val.contains('.com')) {
                                      return 'Invalid Email';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: 'email',
                                    hintStyle: kBodyText,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    errorStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  style:
                                      kBodyText.copyWith(color: Colors.white),
                                  focusNode: passFocus,
                                  validator: (val) {
                                    if (val!.length < 6) {
                                      return 'password muss be at least 6';
                                    }
                                    return null;
                                  },
                                  controller: passController,
                                  obscureText: isPasswordVisible,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    suffixIcon: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: IconButton(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onPressed: () {
                                          setState(() {
                                            isPasswordVisible =
                                                !isPasswordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: 'password',
                                    hintStyle: kBodyText,
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Dont't have an account? ",
                              style: kBodyText,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Register',
                                style: kBodyText.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        if (_isLoading)
                          CircularProgressIndicator()
                        else
                          MyTextButton(
                            buttonName: 'Sign In',
                            onTap: () => _submitData(),
                            bgColor: Colors.white,
                            textColor: Colors.black87,
                          ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
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
