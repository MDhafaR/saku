import 'dart:isolate';

void main() async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse(
      'package:flutter_local_notifications/flutter_local_notifications.dart',
    ),
  );
  print(uri);
}
