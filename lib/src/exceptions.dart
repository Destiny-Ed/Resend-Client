/// Base exception for Resend API errors.
class ResendException implements Exception {
  final String message;
  final int? statusCode;

  /// Creates a [ResendException] with a [message] and optional [statusCode].
  const ResendException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ResendException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when the rate limit is exceeded.
class ResendRateLimitException extends ResendException {
  /// Creates a [ResendRateLimitException] with a [message] and optional [statusCode].
  const ResendRateLimitException(super.message, {super.statusCode});
}
