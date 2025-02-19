import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/UserModel.dart';

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:3000';

  Future<User> register(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return User.fromJson(responseBody);
      } else if (response.statusCode == 400) {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Format nomor telepon tidak valid');
      } else {
        throw Exception('Gagal melakukan registrasi');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: ${e.toString()}');
    }
  }
}
