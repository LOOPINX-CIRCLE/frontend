import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Uri _buildUri(String endpoint) {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '${ApiConstants.baseUrl}$normalizedEndpoint';
    print('Building URI: $fullUrl');
    return Uri.parse(fullUrl);
  }

  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final requestHeaders = {
        ..._defaultHeaders(),
        if (headers != null) ...headers,
      };

      // Debug logging
      if (kDebugMode) {
        print('API Request: GET $uri');
        print('Headers: $requestHeaders');
      }

      final response = await _httpClient
          .get(
            uri,
            headers: requestHeaders,
          )
          .timeout(ApiConstants.defaultTimeout);

      // Debug logging
      if (kDebugMode) {
        print('API Response: Status ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      return _parseResponse(response);
    } on TimeoutException catch (error) {
      if (kDebugMode) {
        print('API Timeout Error: $error');
      }
      throw ApiException(
        message: 'The request timed out. Please check your internet connection and try again.',
        error: error,
      );
    } catch (error) {
      if (kDebugMode) {
        print('API Error: $error');
        print('Error Type: ${error.runtimeType}');
      }
      
      // Handle different error types
      final errorMessage = error.toString().toLowerCase();
      
      if (errorMessage.contains('socket') || errorMessage.contains('network') || errorMessage.contains('connection')) {
        throw ApiException(
          message: 'Unable to reach the server. Please check your network connection.',
          error: error,
        );
      } else if (errorMessage.contains('timeout') || errorMessage.contains('timed out')) {
        throw ApiException(
          message: 'The request timed out. Please check your internet connection and try again.',
          error: error,
        );
      } else if (errorMessage.contains('handshake') || errorMessage.contains('ssl') || errorMessage.contains('tls')) {
        throw ApiException(
          message: 'Secure connection failed. Please try again later.',
          error: error,
        );
      } else if (error is http.ClientException) {
        throw ApiException(message: error.message, error: error);
      } else {
        throw ApiException(
          message: 'An unexpected error occurred: ${error.toString()}',
          error: error,
        );
      }
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final requestBody = jsonEncode(body ?? <String, dynamic>{});
      final requestHeaders = {
        ..._defaultHeaders(),
        if (headers != null) ...headers,
      };

      // Use custom timeout if provided, otherwise use default
      final requestTimeout = timeout ?? ApiConstants.defaultTimeout;

      // Debug logging
      if (kDebugMode) {
        print('API Request: POST $uri');
        print('Headers: $requestHeaders');
        print('Body: $requestBody');
        print('Timeout: ${requestTimeout.inSeconds} seconds');
      }

      final response = await _httpClient
          .post(
            uri,
            headers: requestHeaders,
            body: requestBody,
          )
          .timeout(requestTimeout);

      // Debug logging
      print('API Response: Status ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _parseResponse(response);
    } on TimeoutException catch (error) {
      if (kDebugMode) {
        print('API Timeout Error: $error');
      }
      throw ApiException(
        message: 'The request timed out. Please check your internet connection and try again.',
        error: error,
      );
    } catch (error) {
      if (kDebugMode) {
        print('API Error: $error');
        print('Error Type: ${error.runtimeType}');
      }
      
      // Handle different error types
      final errorMessage = error.toString().toLowerCase();
      
      if (errorMessage.contains('socket') || errorMessage.contains('network') || errorMessage.contains('connection')) {
        throw ApiException(
          message: 'Unable to reach the server. Please check your network connection.',
          error: error,
        );
      } else if (errorMessage.contains('timeout') || errorMessage.contains('timed out')) {
        throw ApiException(
          message: 'The request timed out. Please check your internet connection and try again.',
          error: error,
        );
      } else if (errorMessage.contains('handshake') || errorMessage.contains('ssl') || errorMessage.contains('tls')) {
        throw ApiException(
          message: 'Secure connection failed. Please try again later.',
          error: error,
        );
      } else if (error is http.ClientException) {
        throw ApiException(message: error.message, error: error);
      } else {
        throw ApiException(
          message: 'An unexpected error occurred: ${error.toString()}',
          error: error,
        );
      }
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final statusCode = response.statusCode;

    Map<String, dynamic> decoded;

    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException catch (error) {
      throw ApiException(
        message: 'Invalid response received from the server.',
        statusCode: statusCode,
        error: error,
      );
    }

    // Check if the response indicates success (even if status code is 200)
    if (decoded.containsKey('success') && decoded['success'] == false) {
      // Extract error message from various possible fields (FastAPI uses 'detail', others use 'message')
      final errorMessage = decoded['detail']?.toString() ?? 
                           decoded['message']?.toString() ?? 
                           'Request failed';
      throw ApiException(
        message: errorMessage,
        statusCode: statusCode,
        error: decoded,
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    // Extract error message from various possible fields (FastAPI uses 'detail', others use 'message')
    final errorMessage = decoded['detail']?.toString() ?? 
                         decoded['message']?.toString() ?? 
                         'Request failed with status $statusCode';

    throw ApiException(
      message: errorMessage,
      statusCode: statusCode,
      error: decoded,
    );
  }

  void close() {
    _httpClient.close();
  }
}

