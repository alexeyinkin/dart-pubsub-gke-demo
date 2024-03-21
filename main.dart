import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';

Future<void> main() async {
  print(File(Platform.environment['GOOGLE_APPLICATION_CREDENTIALS']!).readAsStringSync());
  await clientViaApplicationDefaultCredentials(scopes: []);
}
