import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/provider/app_data.dart';
import 'package:uber_clone/sample_testpurpose-only.dart';
import 'package:uber_clone/screens/auth/intro.dart';
import 'package:uber_clone/screens/auth/login.dart';
import 'package:uber_clone/screens/main_screen.dart';
import 'package:uber_clone/screens/search_screen.dart';
import 'package:uber_clone/screens/auth/signup.dart';
import 'package:uber_clone/screens/splash_screen.dart';
import 'package:uber_clone/ui_reuse/constant.dart';
import 'package:uber_clone/ui_reuse/widgets/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  currentFirebaseUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp());
}

DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Init.instance.initialize(),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Splash());
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: AppData(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                textTheme:
                    GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
                scaffoldBackgroundColor: kBackgroundColor,
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              initialRoute: FirebaseAuth.instance.currentUser == null
                  ? WelcomePage.routeName
                  : MainScreen.routeName,
              routes: {
                SignIn.routeName: (context) => SignIn(),
                SignUp.routeName: (context) => SignUp(),
                MainScreen.routeName: (context) => MainScreen(),
                SearchScreen.routeName: (context) => SearchScreen(),
                WelcomePage.routeName: (context) => WelcomePage(),
                NewPage.routeName: (context) => NewPage(),
              },
            ),
          );
        }
      },
    );
  }
}
class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    await Future.delayed(const Duration(seconds: 3));
  }
}