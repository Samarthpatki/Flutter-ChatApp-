import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profilePic;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePic,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePic': profilePic,
    };
  }

  factory UserProfile.fromJson(Map<dynamic, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePic: json['profilePic'] ?? '',
    );
  }
  factory UserProfile.fromSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
    return UserProfile(
      uid: snapshot.key ?? "",
      name: data["name"] ?? "",
      email: data["email"] ?? "",
      phone: data["phone"] ?? "",
      profilePic: data["profilePic"] ?? "",
    );
  }

}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("profiles");

  Future<void> signUpUser(
      {required String name,
        required String email,
        required String phone,
        required String password,
        String? profilePic,
        required VoidCallback onSuccess,
        required Function(String) onFailure}) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;
      UserProfile user =
      UserProfile(uid: uid, name: name, email: email, phone: phone, profilePic: profilePic ?? "");

      await _dbRef.child(uid).set(user.toJson());
      onSuccess();
    } catch (error) {
      onFailure(error.toString());
    }
  }

  Future<void> signInUser(
      {required String emailOrPhone,
        required String password,
        required Function(UserProfile) onSuccess,
        required Function(String) onFailure}) async {
    try {
      if (emailOrPhone.contains("@")) {
        UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(email: emailOrPhone, password: password);
        _fetchUserDetails(userCredential.user!.uid, onSuccess, onFailure);
      } else {
        _dbRef.orderByChild("phone").equalTo(emailOrPhone).once().then((event) {
          DataSnapshot snapshot = event.snapshot;
          if (snapshot.value != null) {
            Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
            userData.forEach((key, value) async {
              String email = value["email"];
              try {
                UserCredential userCredential =
                await _auth.signInWithEmailAndPassword(email: email, password: password);
                _fetchUserDetails(userCredential.user!.uid, onSuccess, onFailure);
              } catch (error) {
                onFailure("Login Failed");
              }
            });
          } else {
            onFailure("Phone number not registered");
          }
        }).catchError((error) {
          onFailure("Database error: ${error.toString()}");
        });
      }
    } catch (error) {
      onFailure(error.toString());
    }
  }

  void _fetchUserDetails(
      String userId, Function(UserProfile) onSuccess, Function(String) onFailure) {
    _dbRef.child(userId).get().then((snapshot) {
      if (snapshot.exists) {
        onSuccess(UserProfile.fromJson(snapshot.value as Map<dynamic, dynamic>));
      } else {
        onFailure("User details not found");
      }
    }).catchError((error) {
      onFailure("Failed to fetch user details");
    });
  }
}
