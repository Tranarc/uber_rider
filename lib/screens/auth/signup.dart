import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/main.dart';
import 'package:uber_clone/screens/auth/login.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';

class SignUp extends StatefulWidget {
  static const String routeName = 'SignUp';

  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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

  bool? isPasswordVisible;


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
      body: Builder(
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
        child: SingleChildScrollView  (
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
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
                    style: TextStyle(fontFamily: "Semibold", fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    controller: userNameController,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(emailFocus);
                    },
                    validator: (val) {
                      if (val!.length < 4) {
                        return 'Username muss be at least 4';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: "Username",
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
                    focusNode: emailFocus,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(phoneFocus);
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
                    focusNode: phoneFocus,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passFocus);
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
                        labelText: "phone no",
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
                    obscureText: isPasswordVisible!,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: (){
                              setState(() {
                                isPasswordVisible = isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              isPasswordVisible! ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                        ),

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
                      onPressed: () =>  _submitData(),
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            'SignUp',
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
                      Navigator.pushNamed(context, SignIn.routeName);
                    },
                    child: Text(' have an Account Already? Login Now'),
                  ),
                ],
              ),
            ),
          ),
        ));
        },
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
    } else {
      displayToast('User Account Cannot be created', context);
    }
  }
}

displayToast(String msg, BuildContext context) {
  Fluttertoast.showToast(
    msg: msg,
    backgroundColor: Colors.black,
  );
}
