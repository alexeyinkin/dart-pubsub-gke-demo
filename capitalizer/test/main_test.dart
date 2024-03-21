// Run: GOOGLE_APPLICATION_CREDENTIALS='../keys/capitalizer.json' dart test

import 'dart:convert';
import 'dart:io';

import 'package:gcloud/pubsub.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
// import 'package:process/process.dart';
import 'package:test/test.dart';

const _topicName = 'input';
const _subscriptionName = 'output-sub';

void main() {
  test('Publish and read the result', () async {
    final projectId = Platform.environment['PROJECT'];
    print('Project ID: $projectId');

    if (projectId == null) {
      throw Exception('Set PROJECT environment variable.');
    }

    print(File(Platform.environment['GOOGLE_APPLICATION_CREDENTIALS']!)
        .readAsStringSync());
    final pubsub = PubSub(
      //await clientViaApplicationDefaultCredentials(scopes: PubSub.SCOPES),
      await _getClient(),
      projectId,
    );

    final inputTopic = await pubsub.lookupTopic(_topicName);
    final outputSubscription =
        await pubsub.lookupSubscription(_subscriptionName);

    print('Purging the output subscription.');
    while (true) {
      final event = await outputSubscription.pull(wait: false);
      if (event == null) {
        break;
      }
      print(event.message.asString);
      await event.acknowledge();
    }

    const input = {'a': 'b', 'value': 'abc'};
    const expected = {'a': 'b', 'value': 'ABC'};

    inputTopic.publish(Message.withString(jsonEncode(input)));

    final event = await outputSubscription.pull();
    print('Event: $event');

    if (event == null) {
      fail('Did not get the output message.');
    }

    await event.acknowledge();
    final text = event.message.asString;
    final actual = jsonDecode(text) as Map<String, dynamic>;

    expect(actual, expected);
  });
}

Future<http.Client> _getClient() async {
  try {
    return await clientViaApplicationDefaultCredentials(scopes: PubSub.SCOPES);
    // return await clientViaMetadataServer();
  } on ServerRequestFailedException catch (ex) {
    print(ex.toString());
    print(ex.responseContent);
    return await _getWorkloadIdentityFederationClient();
    // rethrow;
  }
}

Future<http.Client> _getWorkloadIdentityFederationClient() async {
  final process = await Process.run('gcloud', ['auth', 'print-access-token']);

  if (process.exitCode != 0) {
    throw Exception(
      'Command failed with exit code ${process.exitCode}: ${process.stderr}',
    );
  }

  final accessToken = process.stdout as String;
  print(accessToken.length);

  var authClient = authenticatedClient(
    http.Client(),
    AccessCredentials(
      AccessToken('Bearer', accessToken, DateTime.now().add(Duration(hours: 1))),
      null, // Refresh token is null because we are manually setting the access token
      //['https://www.googleapis.com/auth/cloud-platform'], // Scopes
      PubSub.SCOPES,
    ),
  );

  print(authClient);
  return authClient;
}
