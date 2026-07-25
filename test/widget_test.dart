import 'package:flutter_test/flutter_test.dart';
import 'package:hajj_app/services/help_service.dart';

void main() {
  group('Help conversation lifecycle', () {
    test('messages are locked until an officer accepts the request', () {
      expect(
        HelpService.statusAllowsMessaging(HelpService.statusRequested),
        isFalse,
      );
      expect(
        HelpService.statusAllowsMessaging(HelpService.statusAccepted),
        isTrue,
      );
      expect(
        HelpService.statusAllowsMessaging(HelpService.statusOnTheWay),
        isTrue,
      );
      expect(
        HelpService.statusAllowsMessaging(HelpService.statusArrived),
        isTrue,
      );
      expect(
        HelpService.statusAllowsMessaging(HelpService.statusRejected),
        isFalse,
      );
      expect(
        HelpService.statusAllowsMessaging(HelpService.statusClosed),
        isFalse,
      );
    });

    test('rejected and closed conversations are final', () {
      expect(
        HelpService.statusIsFinal(HelpService.statusRequested),
        isFalse,
      );
      expect(
        HelpService.statusIsFinal(HelpService.statusAccepted),
        isFalse,
      );
      expect(
        HelpService.statusIsFinal(HelpService.statusOnTheWay),
        isFalse,
      );
      expect(
        HelpService.statusIsFinal(HelpService.statusArrived),
        isFalse,
      );
      expect(
        HelpService.statusIsFinal(HelpService.statusRejected),
        isTrue,
      );
      expect(
        HelpService.statusIsFinal(HelpService.statusClosed),
        isTrue,
      );
    });
  });
}
