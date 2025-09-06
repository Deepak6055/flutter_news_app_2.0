import 'package:http/http.dart' as http;
import 'package:new_applicatoon_demo/common/constants.dart';

class ApiService {
  var client = http.Client();
  String endpoint = Constants.API_BASE_URL + Constants.API_PREFIX;
  String apiKey = Constants.API_KEY;

  Map<String, String> headers = {
    "Content-Type": "application/json; charset=UTF-8",
    "Accept": "application/json"
  };

  /// Get top headlines
  Future<http.Response> getTopHeadlines({String lang = "en", int max = 10}) {
    return client.get(
      Uri.parse('$endpoint/top-headlines?lang=$lang&max=$max&token=$apiKey'),
      headers: headers,
    );
  }

  /// Search all news (equivalent to getEverything)
  Future<http.Response> getEverything(String keyword, int page,
      {String lang = "en", int max = 10}) {
    return client.get(
      Uri.parse(
          '$endpoint/search?q=$keyword&lang=$lang&max=$max&page=$page&token=$apiKey'),
      headers: headers,
    );
  }
}
