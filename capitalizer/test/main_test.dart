// Run: GOOGLE_APPLICATION_CREDENTIALS='../keys/pubsub.json' dart test

import 'dart:convert';
import 'dart:io';

import 'package:gcloud/pubsub.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:test/test.dart';

const _topicName = 'input';
const _subscriptionName = 'output-sub';

void main() {
  test('Publish and read result', () async {
    final projectId = Platform.environment['PROJECT_ID'];
    print('Project ID: $projectId');

    if (projectId == null) {
      throw Exception('Set PROJECT_ID environment variable.');
    }

    final pubsub = PubSub(
      await clientViaApplicationDefaultCredentials(scopes: PubSub.SCOPES),
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
