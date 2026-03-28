import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/http_constants.dart';

class Defaulthttpclient {
  Future<Map<String, dynamic>> post(
    String url,
    Map<String, String>? headers,
    Map<String, dynamic> json,
  ) async {
    final uri = Uri.parse(urlApi + url);
    final requestHeaders = {'Content-Type': 'application/json', ...?headers};

    var response = await http.post(
      uri,
      headers: requestHeaders,
      body: convert.jsonEncode(json),
    );

    if (response.statusCode > 199 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } else {
      throw Exception(
        "Erro Inesperado, status code: ${response.statusCode}! ${response.body}",
      );
    }
  }

  Future<dynamic> get(
    String url,
    Map<String, String>? headers,
    Map<String, dynamic> json,
  ) async {
    final uri = Uri.parse(urlApi + url);

    var response = await http.get(uri, headers: headers);
    print(response.body);

    if (response.statusCode > 199 && response.statusCode < 300) {
      //Sucesso
      var jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse;
    } else {
      //Algo fora do range de sucesso (200-299) ocorreu
      throw Exception(
        "Erro Inesperado, status code: ${response.statusCode}! ${response.body}",
      );
    }
  }

  Future<bool> delete(
    String url,
    Map<String, String>? headers,
    Map<String, dynamic> json,
  ) async {
    final uri = Uri.parse(urlApi + url);

    var response = await http.delete(uri, headers: headers);
    print(response.body);

    if (response.statusCode > 199 && response.statusCode < 300) {
      //Sucesso
      return true;
    } else {
      //Algo fora do range de sucesso (200-299) ocorreu
      throw Exception(
        "Erro Inesperado, status code: ${response.statusCode}! ${response.body}",
      );
    }
  }

  Future<bool> put(
    String url,
    Map<String, String>? headers,
    Map<String, dynamic> json,
  ) async {
    final uri = Uri.parse(urlApi + url);
    final requestHeaders = {'Content-Type': 'application/json', ...?headers};

    var response = await http.put(
      uri,
      headers: requestHeaders,
      body: convert.jsonEncode(json),
    );
    print(response.body);

    if (response.statusCode > 199 && response.statusCode < 300) {
      return true;
    } else {
      throw Exception(
        "Erro Inesperado, status code: ${response.statusCode}! ${response.body}",
      );
    }
  }
}
