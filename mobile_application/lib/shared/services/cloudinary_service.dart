import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Service for interacting with Cloudinary
/// Handles fetching resource lists (videos/images) from Cloudinary folders
class CloudinaryService {
  static String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static String get folder => dotenv.env['CLOUDINARY_FOLDER'] ?? 'bytes';

  /// Fetch all resources (videos and images) from the configured folder
  /// Uses Cloudinary Search API which requires API key and secret
  static Future<List<Map<String, dynamic>>> listResources() async {
    try {
      if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Cloudinary configuration incomplete in .env');
        }
        return [];
      }

      final basicAuth = 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';
      
      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/resources/search'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'expression': 'folder:$folder',
          'max_results': 100,
          'sort_by': [{'created_at': 'desc'}],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = List<Map<String, dynamic>>.from(data['resources']);
        
        if (kDebugMode) {
          print('✅ Found ${resources.length} resources in Cloudinary folder: $folder');
        }
        
        return resources;
      } else {
        if (kDebugMode) {
          print('❌ Cloudinary Search API error: ${response.statusCode} ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error listing Cloudinary resources: $e');
      }
      return [];
    }
  }

  /// Generate a display URL for a Cloudinary public ID
  /// Can be used for transformations if needed
  static String getSecureUrl(String publicId, {String? resourceType}) {
    return 'https://res.cloudinary.com/$cloudName/${resourceType ?? "video"}/upload/$publicId';
  }
}
