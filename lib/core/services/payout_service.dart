import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:text_code/core/constants/api_constants.dart';
import 'package:text_code/core/network/api_client.dart';
import 'package:text_code/core/network/api_exception.dart';
import 'package:text_code/core/services/auth_service.dart';

class PayoutService {
  final ApiClient _apiClient;

  PayoutService({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? ApiClient();

  /// Create a new bank account for the authenticated user
  /// 
  /// Parameters:
  /// - bankName: Name of the bank (e.g., "State Bank of India")
  /// - accountNumber: Bank account number (8-30 digits, only digits)
  /// - ifscCode: IFSC code (11 characters, format: AAAA0XXXXXX)
  /// - accountHolderName: Name as registered with bank
  /// - isPrimary: Set as primary account (only one primary per user)
  /// 
  /// Returns: Map with success status and response data
  Future<Map<String, dynamic>> createBankAccount({
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    bool isPrimary = false,
  }) async {
    try {
      final authService = AuthService();
      final token = await authService.getStoredToken();

      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Authentication required',
          statusCode: 401,
        );
      }

      // Validate inputs
      if (!_validateAccountNumber(accountNumber)) {
        throw ApiException(
          message: 'Account number must contain only digits (8-30 characters)',
          statusCode: 400,
        );
      }

      if (!_validateIFSCCode(ifscCode)) {
        throw ApiException(
          message: 'Invalid IFSC code format. Must be 11 characters: 4 letters, 0, then 6 alphanumeric',
          statusCode: 400,
        );
      }

      // Clean and prepare the request body
      final requestBody = {
        'bank_name': bankName.trim(),
        'account_number': accountNumber.trim().replaceAll(RegExp(r'\s'), ''),
        'ifsc_code': ifscCode.trim().toUpperCase().replaceAll(RegExp(r'\s'), ''),
        'account_holder_name': accountHolderName.trim(),
        'is_primary': isPrimary,
      };

      if (kDebugMode) {
        print('🏦 Creating bank account...');
        print('📝 Bank Name: ${requestBody['bank_name']}');
        print('📝 Account Number: ${requestBody['account_number']}');
        print('📝 IFSC Code: ${requestBody['ifsc_code']}');
        print('📝 Account Holder: ${requestBody['account_holder_name']}');
        print('📝 Is Primary: ${requestBody['is_primary']}');
      }

      final response = await _apiClient.post(
        '/payouts/bank-accounts',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('✅ Bank account created successfully');
      }

      return {
        'success': true,
        'message': 'Bank account created successfully',
        'data': response,
      };
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('💥 Exception in createBankAccount: $e');
      }
      throw ApiException(
        message: 'Failed to create bank account: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Validate account number - must be 8-30 digits
  bool _validateAccountNumber(String accountNumber) {
    final cleaned = accountNumber.replaceAll(RegExp(r'\s'), '');
    final isDigitsOnly = RegExp(r'^\d+$').hasMatch(cleaned);
    final isValidLength = cleaned.length >= 8 && cleaned.length <= 30;
    return isDigitsOnly && isValidLength;
  }

  /// Validate IFSC code - must be 11 characters: 4 letters, 0, then 6 alphanumeric
  bool _validateIFSCCode(String ifscCode) {
    final cleaned = ifscCode.replaceAll(RegExp(r'\s'), '').toUpperCase();
    return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(cleaned);
  }
}
