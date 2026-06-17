import 'package:flutter_assignment/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client client;

  ApiClient(this.client);

  Future<http.Response> get(Uri uri) async {
    return await client.get(uri, headers: ApiConstants.headers);
  }
}
