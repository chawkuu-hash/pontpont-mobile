import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/shop_data.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Public Backend URL (from AppConfig)
  String _baseUrl = AppConfig.publicBaseUrl;

  String get baseUrl => _baseUrl;
  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Active Session / User ID header if logged in
  String? currentUserId;

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (currentUserId != null) {
      headers['x-user-id'] = currentUserId!;
    }
    return headers;
  }

  /// GET /api/shop - Fetch all products, categories, announcements, and theme
  Future<ShopData> fetchShopData() async {
    final uri = Uri.parse('$_baseUrl/api/shop');
    try {
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return ShopData.fromJson(body);
      } else {
        throw Exception('Server Error: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception(
        'Backend server သို့ ချိတ်ဆက်၍ မရပါ ($baseUrl)။ \n'
        '1. အင်တာနက်လိုင်း ကောင်းမွန်မှု ရှိမရှိ စစ်ဆေးပါ။\n'
        '2. Public Backend URL မှန်ကန်မှု ရှိမရှိ စစ်ဆေးပါ (App Settings တွင် URL ပြောင်းနိုင်ပါသည်)။',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/shop (CREATE_ORDER) - Submit a new order
  Future<Map<String, dynamic>> submitOrder({
    required String customerName,
    required String phone,
    required String city,
    required String address,
    required String paymentMethod,
    required List<CartItem> cartItems,
    String? transactionRef,
    String? note,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/shop');

    final itemsPayload = cartItems.map((ci) {
      return {
        'productId': ci.product.id,
        'nameEn': ci.product.nameEn,
        'nameMm': ci.product.nameMm,
        'price': ci.unitPrice,
        'quantity': ci.quantity,
        'selectedColor': ci.selectedColor.name,
        'image': ci.product.image,
      };
    }).toList();

    final payload = {
      'action': 'CREATE_ORDER',
      'order': {
        'customerName': customerName,
        'phone': phone,
        'city': city,
        'address': address,
        'paymentMethod': paymentMethod,
        'transactionRef': transactionRef,
        'note': note,
        'items': itemsPayload,
      },
    };

    final response = await http
        .post(
          uri,
          headers: _buildHeaders(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['error'] ?? 'Order submission failed';
      throw Exception(errorMsg);
    }
  }

  /// POST /api/shop (LOGIN) - User authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/api/shop');
    final response = await http
        .post(
          uri,
          headers: _buildHeaders(),
          body: jsonEncode({
            'action': 'LOGIN',
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 12));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['ok'] == true) {
      final user = data['user'];
      currentUserId = user['id'];
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }
}
