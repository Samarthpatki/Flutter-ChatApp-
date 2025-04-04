import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chatapp_qualwebs_assignment/screens/profile_screen.dart';

import '../data/preference_helper.dart';
import '../data/sign_in_up_repo.dart';
import 'chat_screen.dart';
 class AllChatsScreen extends StatefulWidget {
  @override
  _AllChatsScreenState createState() => _AllChatsScreenState();
}

class ChatPreview {
  final String userId;
  final String name;
  final String profilePic;
  final String lastMessage;
  final int timestamp;
  final String senderId;
  final bool seen;

  ChatPreview({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.lastMessage,
    required this.timestamp,
    required this.senderId,
    required this.seen,
  });

  // Factory constructor to create a ChatPreview instance from a Map (Firebase snapshot)
  factory ChatPreview.fromMap(Map<String, dynamic> map) {
    return ChatPreview(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      senderId: map['senderId'] ?? '',
      seen: map['seen'] ?? true,
    );
  }

  // Convert ChatPreview instance to Map (for Firebase storage)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'profilePic': profilePic,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'senderId': senderId,
      'seen': seen,
    };
  }
}


class _AllChatsScreenState extends State<AllChatsScreen> {
  final DatabaseReference _recentChatsRef = FirebaseDatabase.instance.ref("recent_chats");
  List<ChatPreview> chatList = [];
  String? userId;
  String? userPic;
  PreferenceHelper preferenceHelper=PreferenceHelper();


  @override
  void initState() {
    super.initState();
    _loadUserData();
   }

  Future<void> _loadUserData() async {
    userId = await PreferenceHelper().getUserID();
    userPic = await PreferenceHelper().getUserPic();
    if (userId != null) {
      _fetchRecentChats(userId!);
    }
    setState(() {});
  }

  void _fetchRecentChats(String userId) {
    _recentChatsRef.child(userId).orderByChild("timestamp").onValue.listen((event) {
      List<ChatPreview> fetchedChats = [];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          var chat = ChatPreview.fromMap(Map<String, dynamic>.from(child.value as Map));
          fetchedChats.add(chat);
        }
        fetchedChats.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      setState(() {
        chatList = fetchedChats;
      });
    });
  }
  void searchUserQueryCall(
      String queryText,
      Function(UserProfile?) onSuccess,
      Function(String) onFailure,
      ) {

    DatabaseReference storageRef = FirebaseDatabase.instance.ref("profiles");
    print("Database URL: ${FirebaseDatabase.instance.databaseURL}");


    Query query;
    if (queryText.contains("@")) {
      print("incall");

      query = storageRef.orderByChild("email").equalTo(queryText);
    } else {
      query = storageRef.orderByChild("phone").equalTo(queryText);
    }

    query.get().then((snapshot) {
      if (snapshot.exists) {
        print("inexist");

        for (var userSnap in snapshot.children) {
          UserProfile user = UserProfile.fromSnapshot(userSnap);
          onSuccess(user);
          return;
        }
        onSuccess(null);
      } else {
        onSuccess(null);
      }
    }).catchError((error) {
      onFailure(error.toString());
    });
  }


  Future<void> _startChatActivity(ChatPreview chat) async {
    if (!mounted) return; // ensure widget is still active

    UserProfile userProfile = UserProfile(
      uid: chat.userId,
      name: chat.name,
      profilePic: chat.profilePic,
      email: "", // Fetch email if required
      phone: "", // Fetch phone if required
    );

    String? userid = await preferenceHelper.getUserID();
    if (!mounted) return; // ensure widget is still active

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(senderId:userid ?? "" ,receiverId: userProfile.uid,receiverName: userProfile.name,receiverPic: userProfile.profilePic,)),
    );
  }

  void _showSearchDialog() {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Search User"),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: "Enter email or phone"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String queryText = searchController.text.trim();
                if (queryText.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  // Implement search logic
                  searchUserQueryCall(queryText, (
                      user
                ){
                    if (user == null || !mounted) return;

                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen(senderId:userId??""  ,receiverId:user!.uid ,receiverName: user.name, receiverPic: user.profilePic, )));

                }, (
                    error
                  ){
                    if (!mounted) return;
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error $error")),
                    );

                  });
                }
              },
              child: Text("Search"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        toolbarHeight: 85,
        title: Text("Chats",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),

        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: userPic != null && userPic!.isNotEmpty
                    ? MemoryImage(base64Decode(userPic!))
                    : AssetImage("assets/images/profile.png") as ImageProvider,
              ),
            ),
          ),
        ],
      ),

      body: ListView.separated(
        itemCount: chatList.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          ChatPreview chat = chatList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: chat.profilePic.isNotEmpty
                  ? MemoryImage(base64Decode(chat.profilePic))
                  : AssetImage("assets/images/profile.png") as ImageProvider,
            ),
            title: Text(chat.name),
            subtitle: Text(chat.lastMessage),
            onTap: () => _startChatActivity(chat),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
