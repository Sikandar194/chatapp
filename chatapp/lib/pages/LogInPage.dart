import 'dart:developer';

import 'package:chatapp/models/UIhelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/Home.dart';
import 'package:chatapp/pages/SignupPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasscontroller = TextEditingController();

  void checkValues() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();

    if (email == "" || password == "") {
      UIhelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all fields");
    } else {
      login(email, password);
    }
  }

  void login(email, password) async {
    UserCredential? credential;
    UIhelper.showLoadingDialog(context, "Logging In...");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIhelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userdata =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userdata.data() as Map<String, dynamic>);

      log("LogIn Successfull");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Chat App",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: emailcontroller,
                  cursorColor: Colors.blueGrey,
                  decoration: const InputDecoration(
                    label: Text("Email Address"),
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passwordcontroller,
                  obscureText: true,
                  cursorColor: Colors.blueGrey,
                  decoration: const InputDecoration(
                    label: Text("Password"),
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CupertinoButton(
                  color: Colors.blueGrey,
                  onPressed: () {
                    checkValues();
                  },
                  child: const Text("Log In"),
                )
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const SignUpPage();
                    }),
                  );
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                )),
          ],
        ),
      ),
    );
  }
}
