import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

/// Guards the splash animation asset. The `.lottie` file is a zip archive, so a
/// bad export fails at decode time rather than at compile time.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('splash .lottie decodes and matches the splash timing', () async {
    final bytes = File(
      'assets/animations/gonow_splash.lottie',
    ).readAsBytesSync();
    final composition = await LottieComposition.fromBytes(bytes);

    expect(composition.duration.inMilliseconds, 1400);
    expect(composition.bounds.width, 336);
    expect(composition.bounds.height, 336);

    // Must finish before SplashScreen._redirect() navigates at 1600ms.
    expect(composition.duration.inMilliseconds, lessThan(1600));
  });
}
