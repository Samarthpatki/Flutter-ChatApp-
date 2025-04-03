
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper{

  static const String _isLoggedInKey = "IS_LOGGED_IN";
  static const String _userNameKey = "USER_NAME";
  static const String _userIDKey = "USER_ID";
  static const String _userEmailKey = "USER_EMAIL";
  static const String _userPhoneKey = "USER_PHONE";
  static const String _userPicKey = "USER_PIC";

  // Save Logged In Status
  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save User Name
  Future<void> saveUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Save User ID
  Future<void> saveUserID(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIDKey, uid);
  }

  Future<String?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIDKey);
  }

  // Save User Email
  Future<void> saveUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Save User Phone Number
  Future<void> saveUserPhone(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhoneKey, phone);
  }

  Future<String?> getUserPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  // Save User Profile Picture
  Future<void> saveUserPic(String profilePic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPicKey, profilePic);
  }

  Future<String?> getUserPic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPicKey);
  }

  // Clear all user data
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }



}