import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/Home.dart';
import 'package:chatapp/pages/LogInPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    UserModel? currentusermodel =
        await FirebaseHelper.getUserModelbyId(currentUser.uid);

    if (currentusermodel != null) {
      runApp(MyAppLoggedIn(
          usermodel: currentusermodel, firebaseUser: currentUser));

      // runApp(const MyApp());
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.dark,
      // theme: ThemeData(
      //   // Define the default brightness and colors.
      //   brightness: Brightness.light,
      // ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel usermodel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {super.key, required this.usermodel, required this.firebaseUser});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: usermodel, firebaseUser: firebaseUser),
    );
  }
}
