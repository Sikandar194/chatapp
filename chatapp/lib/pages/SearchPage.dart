import 'dart:developer';

import 'package:chatapp/main.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import 'ChatroomPage.dart';

class searchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const searchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  TextEditingController searchcontroller = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participents.${widget.userModel.uid}", isEqualTo: true)
        .where("participents.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      log("Chatroom Already Exist");
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participents: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
      log("Chatroom Created");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Search"),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              cursorColor: Colors.blueGrey,
              controller: searchcontroller,
              decoration: const InputDecoration(
                labelText: "Email Address",
                labelStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Colors.blueGrey,
                onPressed: () {
                  setState(() {});
                },
                child: const Text("Search")),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchcontroller.text)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.length > 0) {
                      Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;

                      UserModel searchedUser = UserModel.fromMap(userMap);

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatRoomModel =
                              await getChatroomModel(searchedUser);

                          if (chatRoomModel != null) {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChatRoomPage(
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseUser,
                                targetModel: searchedUser,
                                chatroom: chatRoomModel,
                              );
                            }));
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilepic!),
                          backgroundColor: Colors.grey,
                        ),
                        title: Text(searchedUser.fullname.toString()),
                        subtitle: Text(searchedUser.email.toString()),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      );
                    } else {
                      return const Text("No results found");
                    }
                  } else if (snapshot.hasError) {
                    return const Text("An error occured");
                  } else {
                    return const Text("No results found");
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              }),
            )
          ],
        ),
      )),
    );
  }
}
