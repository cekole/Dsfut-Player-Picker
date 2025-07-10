import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../config/secrets.dart';

class DsfutApiService {
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'User-Agent': 'DSFUT-Flutter-App/1.0',
  };

  // Generate MD5 signature for API authentication
  static String _generateSignature(int timestamp) {
    final input = '${ApiConfig.partnerId}${ApiConfig.secretKey}$timestamp';
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // Generate Basic Auth header for transaction status
  static String _generateBasicAuth() {
    final credentials = '${ApiConfig.partnerId}:${ApiConfig.secretKey}';
    final bytes = utf8.encode(credentials);
    return base64Encode(bytes);
  }

  // Pop a player from the board
  static Future<ApiResponse> popPlayer({
    String console = 'ps',
    int? minBuy,
    int? maxBuy,
    int? takeAfter,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(timestamp);

      var url =
          '${ApiConfig.baseUrl}/${ApiConfig.gameYear}/$console/${ApiConfig.partnerId}/$timestamp/$signature';

      // Add query parameters if provided
      final queryParams = <String, String>{};
      if (minBuy != null) queryParams['min_buy'] = minBuy.toString();
      if (maxBuy != null) queryParams['max_buy'] = maxBuy.toString();
      if (takeAfter != null) queryParams['take_after'] = takeAfter.toString();

      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url += '?$query';
      }

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        return ApiResponse(
          error: 'http_error',
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return ApiResponse(error: 'network_error', message: 'Network error: $e');
    }
  }

  // Get current prices
  static Future<Prices?> getPrices() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/${ApiConfig.gameYear}/prices'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Prices.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('Error fetching prices: $e');
      return null;
    }
  }

  // Check transaction status
  static Future<TransactionStatus?> getTransactionStatus(
    int transactionId,
  ) async {
    try {
      final basicAuth = _generateBasicAuth();
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/${ApiConfig.gameYear}/transaction/status/$transactionId',
            ),
            headers: {...headers, 'Authorization': 'Basic $basicAuth'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TransactionStatus.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        return TransactionStatus(status: 0, amount: 0.0, error: 'Unauthorized');
      }
      return null;
    } catch (e) {
      print('Error checking transaction status: $e');
      return null;
    }
  }

  // Get all players (from the JSON endpoint you mentioned)
  static Future<List<DetailedPlayer>?> getAllPlayers() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/json/players'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData
              .map((playerJson) => DetailedPlayer.fromJson(playerJson))
              .toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching all players: $e');
      return null;
    }
  }

  // Get individual player by resource ID
  static Future<DetailedPlayerInfo?> getPlayerById(
    String console,
    int resourceId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/$console/getPlayer/${ApiConfig.partnerId}/$resourceId',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final playerData = Map<String, dynamic>.from(jsonData);
        return DetailedPlayerInfo.fromJson(playerData);
      }
      return null;
    } catch (e) {
      print('Error fetching player by ID: $e');
      return null;
    }
  }
}
