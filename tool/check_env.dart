import 'dart:io';

void main() {
  final secret = Platform.environment['DEMO_SECRET'];
  if (secret == null || secret.isEmpty) {
    stderr.writeln('Environment variable DEMO_SECRET is required but missing.');
    exitCode = 1;
  } else {
    stdout.writeln('DEMO_SECRET present (length: ${secret.length}).');
  }
}
