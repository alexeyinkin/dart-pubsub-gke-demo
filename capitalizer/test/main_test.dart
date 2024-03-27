// Run: GOOGLE_APPLICATION_CREDENTIALS='../keys/capitalizer.json' dart test

import 'dart:convert';
import 'dart:io';

import 'package:gcloud/pubsub.dart';
import 'package:test/test.dart';
import 'package:wif_workaround/wif_workaround.dart' as w;

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
      await w.clientViaApplicationDefaultCredentials(scopes: PubSub.SCOPES),
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
