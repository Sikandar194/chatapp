import 'dart:developer';

import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/CompleteProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/UIHelper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasscontroller = TextEditingController();

  void checkValues() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    String cpass = confirmpasscontroller.text.trim();

    if (email == "" || password == "" || cpass == "") {
      UIhelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all fields");
    } else if (password != cpass) {
      UIhelper.showAlertDialog(
          context, "Passwords do not match", "Passwords must match");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    UIhelper.showLoadingDialog(context, "Creating new Account...");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIhelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      UserModel newuser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newuser.toMap())
          .then((value) {
        log("new user created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              userModel: newuser, firebaseuser: credential!.user!);
        }));
      });
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
                  cursorColor: Colors.blueGrey,
                  obscureText: true,
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
                TextField(
                  controller: confirmpasscontroller,
                  cursorColor: Colors.blueGrey,
                  obscureText: true,
                  decoration: const InputDecoration(
                    label: Text("Confirm Password"),
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
                  child: const Text("Sign Up"),
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
              "Already have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Log In",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                )),
          ],
        ),
      ),
    );
  }
}
