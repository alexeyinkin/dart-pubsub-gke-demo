// Run: GOOGLE_APPLICATION_CREDENTIALS='../keys/capitalizer.json' dart lib/main.dart

import 'dart:convert';
import 'dart:io';

import 'package:gcloud/pubsub.dart';
import 'package:googleapis_auth/auth_io.dart';

const _subscriptionName = 'input-sub';
const _topicName = 'output';

Future<void> main() async {
  final projectId = Platform.environment['PROJECT'];
  print('Project ID: $projectId');

  if (projectId == null || projectId == '') {
    throw Exception('Set PROJECT environment variable.');
  }

  final pubsub = PubSub(
    await clientViaApplicationDefaultCredentials(scopes: PubSub.SCOPES),
    projectId,
  );

  final inputSubscription = await pubsub.lookupSubscription(_subscriptionName);
  final outputTopic = await pubsub.lookupTopic(_topicName);
  print('Looked up: $inputSubscription, $outputTopic');

  while (true) {
    print('Pulling.');

    final event = await inputSubscription.pull();
    print('Event: $event');

    if (event == null) {
      print('Idle.');
    } else {
      final text = event.message.asString;
      print('Message received: $text');

      final data = jsonDecode(text) as Map<String, dynamic>;
      final value = data['value']?.toString() ?? '';

      final response = {...data, 'value': value.toUpperCase()};

      await outputTopic.publish(Message.withString(jsonEncode(response)));
      await event.acknowledge();
    }

    await Future.delayed(const Duration(seconds: 5));
  }
}
