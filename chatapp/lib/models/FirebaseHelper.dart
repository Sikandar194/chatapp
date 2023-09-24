import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelbyId(String uid) async {
    UserModel? usermodel;
    DocumentSnapshot docsnapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docsnapshot.data() != null) {
      usermodel = UserModel.fromMap(docsnapshot.data() as Map<String, dynamic>);
    }
    return usermodel;
  }
}
