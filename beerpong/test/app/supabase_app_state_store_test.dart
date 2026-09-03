import 'dart:async';
import 'dart:convert';

import 'package:beerpong/app/data/app_state_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'starts the Supabase request even when persistence is not awaited',
    () async {
      final httpClient = _RecordingClient();
      final client = SupabaseClient(
        'https://example.test',
        'test-key',
        httpClient: httpClient,
      );
      await client.auth.signInWithPassword(
        email: 'player@example.test',
        password: 'password',
      );

      unawaited(SupabaseAppStateStore(client).save(const AppSnapshot.empty()));
      await Future<void>.delayed(Duration.zero);

    final request = httpClient.requests.singleWhere(
      (request) => request.url.path == '/rest/v1/app_snapshots',
    );
    expect(request.method, 'POST');
    },
  );
}

class _RecordingClient extends http.BaseClient {
  final requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.url.path == '/auth/v1/token') {
      return _response(request, {
        'access_token': 'test-access-token',
        'token_type': 'bearer',
        'expires_in': 3600,
        'refresh_token': 'test-refresh-token',
        'user': {
          'id': '11111111-1111-1111-1111-111111111111',
          'aud': 'authenticated',
          'role': 'authenticated',
          'email': 'player@example.test',
          'app_metadata': <String, Object>{},
          'user_metadata': <String, Object>{},
          'created_at': '2026-01-01T00:00:00.000Z',
        },
      });
    }
    if (request.url.path == '/rest/v1/app_snapshots') {
      return _response(request, <Object>[]);
    }
    throw StateError('Unexpected request: ${request.url}');
  }

  http.StreamedResponse _response(http.BaseRequest request, Object body) =>
      http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(body))),
        200,
        headers: const {'content-type': 'application/json'},
        request: request,
      );
}
