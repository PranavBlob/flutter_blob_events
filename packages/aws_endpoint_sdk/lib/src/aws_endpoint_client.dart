import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Optional seam for tests / custom HTTP clients.
abstract class AwsEndpointClient {
  Future<void> postEvent({
    required String endpoint,
    required Map<String, dynamic> body,
  });
}

class HttpAwsEndpointClient implements AwsEndpointClient {
  @override
  Future<void> postEvent({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(endpoint));
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close();
      await response.drain<void>();
    } finally {
      client.close(force: false);
    }
  }
}

/// Console logging client for local demos / tests (no network).
class LoggingAwsEndpointClient implements AwsEndpointClient {
  @override
  Future<void> postEvent({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    // ignore: avoid_print
    print('[aws_endpoint] POST $endpoint ${jsonEncode(body)}');
  }
}

/// Swallows network errors in debug builds (matches legacy AwsSink behavior).
Future<void> postEventSafely({
  required AwsEndpointClient client,
  required String endpoint,
  required Map<String, dynamic> body,
  required String eventName,
}) async {
  try {
    await client.postEvent(endpoint: endpoint, body: body);
  } catch (error) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[aws_endpoint] Failed to send event "$eventName": $error');
    }
  }
}
