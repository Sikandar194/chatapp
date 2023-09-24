import 'dart:developer';
import 'dart:io';
import 'package:chatapp/models/UIhelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseuser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseuser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullNamecController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedfile = await ImagePicker().pickImage(source: source);
    if (pickedfile != null) {
      cropImage(pickedfile);
    }
  }

  void cropImage(XFile file) async {
    File? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 5);
    if (croppedImage != null) {
      setState(() {
        imageFile = croppedImage;
      });
    }
  }

  void showimageOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.photo),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                )
              ],
            ),
          );
        });
  }

  void checkeValues() {
    String fullname = fullNamecController.text.trim();

    if (fullname == "") {
      UIhelper.showAlertDialog(context, "Incomplete Data",
          "Please write your name & add your Prifile Pic.");
    } else if (imageFile == null) {
      UIhelper.showAlertDialog(context, "Incomplete Data",
          "Please write your name & add your Prifile Pic.");
    } else {
      uploadData();
    }
  }

  uploadData() async {
    UIhelper.showLoadingDialog(context, "Uploading Data...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    String fullname = fullNamecController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(
            userModel: widget.userModel, firebaseUser: widget.firebaseuser);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile",
            style: TextStyle(color: Colors.blueGrey)),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
              onPressed: () {
                showimageOptions();
              },
              padding: const EdgeInsets.all(0),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
                backgroundImage:
                    (imageFile != null) ? FileImage(imageFile!) : null,
                child: (imageFile == null)
                    ? const Icon(
                        Icons.person,
                        size: 60,
                      )
                    : null,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: fullNamecController,
              cursorColor: Colors.blueGrey,
              decoration: const InputDecoration(
                label: Text("Full Name"),
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CupertinoButton(
              color: Colors.blueGrey,
              onPressed: () {
                checkeValues();
              },
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.blueGrey),
              ),
            )
          ],
        ),
      )),
    );
  }
}
