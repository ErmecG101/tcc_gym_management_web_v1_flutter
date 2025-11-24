import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/http_constants.dart';

class Defaulthttpclient {

  Future<Map<String,dynamic>> post(String url,Map<String, String>? headers, Map<String,dynamic> json)async{

    final uri = Uri.parse(urlApi+url);

    var response = await http.post(uri, headers: headers, body: json);
    
    if(response.statusCode >199 && response.statusCode < 300){//Sucesso
      var jsonResponse = convert.jsonDecode(response.body) as Map<String,dynamic>;
      return jsonResponse;
    }else{//Algo fora do range de sucesso (200-299) ocorreu
      throw Exception("Erro Inesperado, status code: ${response.statusCode}! ${response.body}");
    }
  }

}