import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';

class LoginHttpService {

  final Defaulthttpclient _defaulthttpclient;
  LoginHttpService(this._defaulthttpclient);

  Future<bool> executarLogin({
    required String username,
    required String password,
  }) async {

    var passwordBytes = utf8.encode(password);
    var digest = sha1.convert(passwordBytes);
    String sha1HashPassword = digest.toString();
    try{
      Map<String, dynamic> userJson = await _defaulthttpclient.post("users/login/$username/$sha1HashPassword", null, {});

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("user", jsonEncode(userJson));
      return true;
    }catch (e){
      print("CAIU NO HTTP SERVICE: $e");
      rethrow;
    }
  }

}