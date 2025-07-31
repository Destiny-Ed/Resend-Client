import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resend_client/src/utils.dart';
import 'models.dart';
import 'exceptions.dart';

/// Client for interacting with the Resend Email API.
class ResendClient {
  final String apiKey;

  /// Creates a [ResendClient] with a required [apiKey].
  /// Optionally accepts a [baseUrl] (defaults to Resend API endpoint) .
  ResendClient({required this.apiKey});

  // Creates a variable for [client]
  final _client = http.Client();

  /// Sends a single email using the Resend API.
  ///
  /// Takes an [EmailRequest] object and returns the API response as a [Map].
  /// Throws a [ResendException] if the request fails.
  Future<Map<String, dynamic>> sendEmail(EmailRequest email) async {
    return _postRequest('/emails', email.toJson());
  }

  /// Schedules an email to be sent at a specific time.
  ///
  /// Takes an [EmailRequest] with a [scheduledAt] field and returns the API response.
  /// Throws a [ResendException] if the request fails.
  Future<Map<String, dynamic>> scheduleEmail(EmailRequest email) async {
    if (email.scheduledAt == null) {
      throw ArgumentError('scheduledAt is required for scheduling emails.');
    }
    return _postRequest('/emails', email.toJson());
  }

  /// Reschedules a previously scheduled email.
  ///
  /// Takes an [emailId] and a new [scheduledAt] time (ISO 8601 or natural language).
  /// Returns the API response as a [Map].
  /// Throws a [ResendException] if the request fails.
  Future<Map<String, dynamic>> rescheduleEmail({
    required String emailId,
    required String scheduledAt,
  }) async {
    return _patchRequest('/emails/$emailId', {'scheduled_at': scheduledAt});
  }

  /// Cancels a scheduled email.
  ///
  /// Takes an [emailId] and returns the API response as a [Map].
  /// Throws a [ResendException] if the request fails.
  Future<Map<String, dynamic>> cancelEmail(String emailId) async {
    return _postRequest('/emails/$emailId/cancel', {});
  }

  /// Sends a batch of emails (up to 100) in a single API call.
  ///
  /// Takes a list of [EmailRequest] objects and returns the API response as a [Map].
  /// Throws a [ResendException] if the request fails.
  Future<Map<String, dynamic>> sendBatchEmails(
    List<EmailRequest> emails,
  ) async {
    if (emails.length > 100) {
      throw ArgumentError('Batch emails cannot exceed 100 per request.');
    }
    return _postRequest(
      '/emails/batch',
      emails.map((e) => e.toJson()).toList(),
    );
  }

  /// Retrieves details of a single email by its ID.
  ///
  /// Takes an [emailId] and returns the API response as a [Map].
  /// Throws a [ResendException] if the request fails.
  Future<Map<String, dynamic>> retrieveEmail(String emailId) async {
    return _getRequest('/emails/$emailId');
  }

  /// Internal method to handle POST requests.
  Future<Map<String, dynamic>> _postRequest(String path, dynamic body) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ResendException('$e');
    }
  }

  /// Internal method to handle PATCH requests.
  Future<Map<String, dynamic>> _patchRequest(String path, dynamic body) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ResendException('$e');
    }
  }

  /// Internal method to handle GET requests.
  Future<Map<String, dynamic>> _getRequest(String path) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ResendException('Network error: $e');
    }
  }

  /// Handles HTTP response and throws exceptions for error codes.
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final errorResponse = (jsonDecode(response.body) as Map<String, dynamic>);
    throw ResendException(
      errorResponse["error"] ?? "",
      statusCode: errorResponse["statusCode"] ?? 0,
    );
  }

  /// Headers for API requests.
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  /// Closes the underlying HTTP client to free resources.
  void dispose() {
    _client.close();
  }
}
