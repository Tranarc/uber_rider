import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:uber_clone/screens/auth/sign_in.dart';
import 'package:uber_clone/screens/auth/signup.dart';
import 'package:uber_clone/ui_reuse/constant.dart';
import 'package:uber_clone/ui_reuse/text_fields/my_text_button.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';

import '../../main.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _visible = true;

  bool isPasswordVisible = true;

  @override
  void dispose() {
    emailFocus.dispose();
    passFocus.dispose();
    phoneFocus.dispose();
    super.dispose();
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
      await registerNewUser(context);
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
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        Flexible(
                          child: Form(
                            key: _form,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Register",
                                  style: kHeadline,
                                ),
                                Text(
                                  "Create new account to get started.",
                                  style: kBodyText2,
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                TextFormField(
                                  style:
                                      kBodyText.copyWith(color: Colors.white),
                                  controller: userNameController,
                                  keyboardType: TextInputType.emailAddress,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(emailFocus);
                                  },
                                  validator: (val) {
                                    if (val!.length < 4) {
                                      return 'Username muss be at least 4';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: 'username',
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
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  style:
                                      kBodyText.copyWith(color: Colors.white),
                                  focusNode: emailFocus,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(phoneFocus);
                                  },
                                  validator: (val) {
                                    if (!val!.contains('@') ||
                                        !val.contains('.com')) {
                                      return 'Invalid Email';
                                    }
                                    return null;
                                  },
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: 'E-mail',
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
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  style:
                                      kBodyText.copyWith(color: Colors.white),
                                  focusNode: phoneFocus,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(passFocus);
                                  },
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return 'phone no is empty';
                                    }
                                    return null;
                                  },
                                  controller: phoneController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: 'phone',
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
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  style:
                                      kBodyText.copyWith(color: Colors.white),
                                  obscureText: isPasswordVisible,
                                  focusNode: passFocus,
                                  validator: (val) {
                                    if (val!.length < 6) {
                                      return 'password muss be at least 6';
                                    }
                                    return null;
                                  },
                                  controller: passController,
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
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: kBodyText,
                            ),
                            Text(
                              "Sign In",
                              style: kBodyText.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if (_isLoading)
                          CircularProgressIndicator()
                        else
                          MyTextButton(
                            buttonName: 'Register',
                            onTap: () => _submitData(),
                            bgColor: Colors.white,
                            textColor: Colors.black87,
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

  registerNewUser(BuildContext context) async {
    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passController.text)
            .catchError(
      (onError) {
        displayToast('error: $onError', context);
        print(onError);
      },
    ))
        .user;
    if (firebaseUser != null) {
      userRef.child(firebaseUser.uid);

      Map userData = {
        'email': emailController.text.trim(),
        'user': userNameController.text.trim(),
        'Phone': phoneController.text.trim(),
      };
      userRef.child(firebaseUser.uid).set(userData);
      displayToast('Congratulations Account has been created', context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignInPage()));
    } else {
      displayToast('User Account Cannot be created', context);
    }
  }
}
