import 'package:calibrefit/core/utils/date_time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeUtils', () {
    group('isToday', () {
      test('returns true for now', () {
        expect(DateTimeUtils.isToday(DateTime.now()), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateTimeUtils.isToday(yesterday), isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(DateTimeUtils.isToday(tomorrow), isFalse);
      });
    });

    group('formatDuration', () {
      test('formats zero duration as 00:00', () {
        expect(DateTimeUtils.formatDuration(Duration.zero), equals('00:00'));
      });

      test('formats 90 seconds as 01:30', () {
        expect(
          DateTimeUtils.formatDuration(const Duration(seconds: 90)),
          equals('01:30'),
        );
      });

      test('formats 3661 seconds as 01:01 (minutes mod 60)', () {
        // 3661 s = 61 min 1 s, displayed as 01:01
        expect(
          DateTimeUtils.formatDuration(const Duration(seconds: 3661)),
          equals('01:01'),
        );
      });
    });

    group('relativeLabel', () {
      test('returns Today for current date', () {
        expect(DateTimeUtils.relativeLabel(DateTime.now()), equals('Today'));
      });

      test('returns Yesterday for one day ago', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateTimeUtils.relativeLabel(yesterday), equals('Yesterday'));
      });

      test('returns dd MMM for older dates', () {
        final date = DateTime(2025, 3, 5);
        expect(DateTimeUtils.relativeLabel(date), equals('5 Mar'));
      });
    });
  });
}
