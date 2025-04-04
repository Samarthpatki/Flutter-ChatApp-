import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chatapp_qualwebs_assignment/data/preference_helper.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
   final String senderId;
  final String receiverId;
  final String receiverName;
  final String receiverPic;

  ChatScreen({required this.senderId, required this.receiverId , required this.receiverName,required this.receiverPic });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}



class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _messageController = TextEditingController();
  DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child("chats");
  DatabaseReference _recentChatRef = FirebaseDatabase.instance.ref().child("recent_chats");
  String chatId="";
  String imageMsg="";
  PreferenceHelper preferenceHelper= PreferenceHelper();
  final ScrollController _scrollController = ScrollController(); // Add this

  @override
  void initState() {
    super.initState();

    chatId = generateChatId(widget.senderId, widget.receiverId);
    print("Chat id "+chatId);
    _chatRef = FirebaseDatabase.instance.ref().child("chats").child(chatId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    _chatRef.onChildAdded.listen((event) {
      _scrollToBottom2();
    });


  }

  void _scrollToBottom() {
    // if (_scrollController.hasClients) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // }

    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

  }

  void _scrollToBottom2() {
    Future.delayed(Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 50),
          curve: Curves.easeOut,
        );
      }
    });
  }

    String formatTimestamp(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.hour}:${date.minute < 10 ? '0' + date.minute.toString() : date.minute} ${date.hour >= 12 ? 'PM' : 'AM'}";
  }

  String generateChatId(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId]..sort();
    return ids.join("_");
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && imageMsg.isEmpty) return;
    String messageId = _chatRef.push().key!;
    String textMessage = _messageController.text;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    _chatRef.child(messageId).set({
      'messageId': messageId,
      'message': _messageController.text,
      'image_msg':imageMsg,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'timestamp': timestamp,
      'seen': false,
    }).then((_) async {


      String lastMessage = textMessage.isNotEmpty ? textMessage : "Photo";
      String? senderName= await preferenceHelper.getUserName();
      String? senderPic = await preferenceHelper.getUserPic();
      updateRecentChats(
        senderId: widget.senderId,
        senderName: senderName,
        senderPic: senderPic,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
        receiverPic: widget.receiverPic,
        lastMessage: lastMessage,
        timestamp: timestamp,
      );




    });
    _scrollToBottom2();
    _messageController.clear();
  }
  void updateRecentChats({
    required String senderId,
    required String? senderName,
    required String? senderPic,
    required String receiverId,
    required String receiverName,
    required String receiverPic,
    required String lastMessage,
    required int timestamp,
  }) {
    Map<String, dynamic> senderChat = {
      'userId': receiverId,
      'name': receiverName,
      'profilePic': receiverPic,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'senderId': senderId,
      'seen': false,
    };

    Map<String, dynamic> receiverChat = {
      'userId': senderId,
      'name': senderName,
      'profilePic': senderPic,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'senderId': receiverId,
      'seen': false,
    };

    _recentChatRef.child(senderId).child(receiverId).set(senderChat);
    _recentChatRef.child(receiverId).child(senderId).set(receiverChat);
  }



void _showMessageOptions(String messageId, String message ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Edit"),
            onTap: () => _editMessage(messageId,message),
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Delete"),
            onTap: () => _deleteMessage(messageId),
          ),
        ],
      ),
    );
  }

  void _editMessage(String messageId, String message ) {
    Navigator.pop(context);
    TextEditingController editController = TextEditingController(text:message);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Message"),
          content: TextField(controller: editController),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () async {
                _chatRef.child(messageId).update({'message': editController.text}).then((_) async {
              String updatedMessage = editController.text.trim();
              if (updatedMessage.isNotEmpty)   {
              // Fetch all messages from Firebase
              DataSnapshot snapshot = (await _chatRef.get());
              if (snapshot.value != null) {
              Map<dynamic, dynamic> messagesMap = snapshot.value as Map<dynamic, dynamic>;

              // Convert to sorted list based on timestamp
              List<Map<String, dynamic>> chatMessages = messagesMap.entries.map((entry) {
              return Map<String, dynamic>.from(entry.value);
              }).toList();
              chatMessages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp']));

              // Check if the edited message is the last one
              Map<String, dynamic> lastMessage = chatMessages.last;
              if (lastMessage['messageId'] == messageId) {
              // Fetch sender info from preferences
              String? senderName = await preferenceHelper.getUserName();
              String? senderPic = await preferenceHelper.getUserPic();

              // Update recent chats with the new last message
              updateRecentChats(
              senderId: widget.senderId,
              senderName: senderName,
              senderPic: senderPic,
              receiverId: widget.receiverId,
              receiverName: widget.receiverName,
              receiverPic: widget.receiverPic,
              lastMessage: updatedMessage, // ✅ Update with the new message
              timestamp: lastMessage['timestamp'],
              );
        }
        }}


                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // void _deleteMessage(String messageId) {
  //   Navigator.pop(context);
  //   _chatRef.child(messageId).remove();
  // }
  void _deleteMessage(String messageId) async {
    Navigator.pop(context);

    // Fetch all messages from Firebase
    DataSnapshot snapshot = (await _chatRef.get());
    if (snapshot.value != null) {
      Map<dynamic, dynamic> messagesMap = snapshot.value as Map<dynamic, dynamic>;

      // Convert to sorted list based on timestamp
      List<Map<String, dynamic>> chatMessages = messagesMap.entries.map((entry) {
        return Map<String, dynamic>.from(entry.value);
      }).toList();
      chatMessages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp']));

      // Find the message to be deleted
      int indexToDelete = chatMessages.indexWhere((msg) => msg['messageId'] == messageId);

      if (indexToDelete != -1) {
        bool isLastMessage = (indexToDelete == chatMessages.length - 1);

        // Remove message from Firebase
        await _chatRef.child(messageId).remove();

        if (isLastMessage) {
          if (chatMessages.length > 1) {
            // Get the new last message
            Map<String, dynamic> newLastMessage = chatMessages[chatMessages.length - 2];

            // Fetch sender info
            String? senderName = await preferenceHelper.getUserName();
            String? senderPic = await preferenceHelper.getUserPic();

            // Update recent chats with the new last message
            updateRecentChats(
              senderId: widget.senderId,
              senderName: senderName,
              senderPic: senderPic,
              receiverId: widget.receiverId,
              receiverName: widget.receiverName,
              receiverPic: widget.receiverPic,
              lastMessage: newLastMessage['message'], // ✅ Set new last message
              timestamp: newLastMessage['timestamp'],
            );
          } else {
            // No messages left, clear recent chat
            updateRecentChats(
              senderId: widget.senderId,
              senderName: widget.senderId, // Needed to retain reference
              senderPic: "",
              receiverId: widget.receiverId,
              receiverName: widget.receiverId, // Needed to retain reference
              receiverPic: "",
              lastMessage: "", // ✅ No message left
              timestamp: 0,
            );
          }
        }
      }
    }
  }


  void showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Image"),
          actions: [
            TextButton(
              onPressed: () => pickImage(ImageSource.camera, context),
              child: Text("Take Photo"),
            ),
            TextButton(
              onPressed: () => pickImage(ImageSource.gallery, context),
              child: Text("Choose from Gallery"),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    Navigator.pop(context);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String base64Image = await convertToBase64(imageFile);
      imageMsg = base64Image;
      _messageController.clear();
      _sendMessage();

    }

   }

  Future<String> convertToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  // String formatTimestamp(int timestamp) {
  //   DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //   return DateFormat('hh:mm a').format(date); // e.g., "08:30 PM"
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(

            children: [
              // Profile Image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2), // Black Border
                ),
                child: ClipOval(
                  child: widget.receiverPic.isNotEmpty
                      ? Image.memory(
                    base64Decode(widget.receiverPic),
                    fit: BoxFit.cover,
                    width: 40,
                      height: 40,
                  )
                      : Image.asset("assets/images/profile.png"), // Default icon
                ),
              ),
              SizedBox(width: 10), // Spacing
              Text(widget.receiverName, style: TextStyle(fontSize: 18)),
            ],
          ),


      ),
      body: Column(
        children: [
          Expanded(

            child: StreamBuilder(
              stream: _chatRef.onValue,  // Fetch messages for this chatId
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return Center(child: Text("No messages yet"));
                }

                // Extract messages map correctly
                Map<dynamic, dynamic> messagesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                print("messagesmap"+ messagesMap.values.toString());
                // Convert Firebase messages to a sorted list
                List<Map<String, dynamic>> chatMessages = messagesMap.entries.map((entry) {
                  return Map<String, dynamic>.from(entry.value); // Convert each message to a Map
                }).toList();

                // Sort messages by timestamp
                chatMessages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp']));

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> message = chatMessages[index];
                    bool isSender = message['senderId'] == widget.senderId;

                    // String formattedTime = DateFormat('hh:mm a').format(
                    //     DateTime.fromMillisecondsSinceEpoch(message['timestamp']));


                    return Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () {
                          if (isSender) _showMessageOptions(message['messageId'] ,message['message']);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSender ? Colors.blue[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(message['message']!=null && message['message'] != "")
                                Text(message['message'] ?? ""),

                              if(message['image_msg']!=null && message['image_msg'] != "")
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(message['image_msg']),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (message['timestamp'] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 3,),
                                    Text(
                                      formatTimestamp(message['timestamp']),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),


                            ],
                          ),


                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child:
                  Container(
                        decoration: BoxDecoration(
                                color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                  ),
                  ],
                          ) ,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                    child:                   TextField(
                      controller: _messageController,
                      decoration: InputDecoration(hintText: "Type a message",border: InputBorder.none),
                    ),

                    ) ,
                ),
                IconButton(onPressed:(){
                  showImagePickerDialog(context);

                } , icon: Icon(Icons.camera_alt_rounded)),
                SizedBox(width: 10,),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }





}
