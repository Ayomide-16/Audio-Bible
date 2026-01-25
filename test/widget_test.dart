// Basic Flutter widget test for Audio Bible app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:audio_bible/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: AudioBibleApp()));

    // Wait for app to load
    await tester.pumpAndSettle();

    // Verify app title appears somewhere
    expect(find.text('Audio Bible'), findsWidgets);
  });
}
