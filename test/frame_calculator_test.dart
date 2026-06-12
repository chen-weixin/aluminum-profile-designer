import 'package:flutter_test/flutter_test.dart';
import 'package:aluminum_profile_designer/src/frame_calculator.dart';
import 'package:aluminum_profile_designer/src/models.dart';

void main() {
  group('FrameCalculator', () {
    test('generates a rectangular frame with four posts and rails per level', () {
      final project = FrameProject.defaults().copyWith(
        lengthMm: 1200,
        widthMm: 600,
        heightMm: 800,
        shelfLevels: 2,
        profileCode: '3030',
        connectorCode: 'corner_bracket',
      );

      final design = FrameCalculator().calculate(project);

      expect(design.members.where((m) => m.axis == MemberAxis.z), hasLength(4));
      expect(design.members.where((m) => m.axis == MemberAxis.x), hasLength(8));
      expect(design.members.where((m) => m.axis == MemberAxis.y), hasLength(8));
      expect(design.members, hasLength(20));
    });

    test('does not shorten rails when corner brackets are selected', () {
      final project = FrameProject.defaults().copyWith(
        lengthMm: 1000,
        widthMm: 500,
        heightMm: 700,
        profileCode: '2020',
        connectorCode: 'corner_bracket',
      );

      final design = FrameCalculator().calculate(project);
      final xRails = design.members.where((m) => m.axis == MemberAxis.x);
      final yRails = design.members.where((m) => m.axis == MemberAxis.y);

      expect(xRails.every((m) => m.cutLengthMm == 1000), isTrue);
      expect(yRails.every((m) => m.cutLengthMm == 500), isTrue);
    });

    test('shortens rails by two profile widths for end fastener connections', () {
      final project = FrameProject.defaults().copyWith(
        lengthMm: 1000,
        widthMm: 500,
        heightMm: 700,
        profileCode: '4040',
        connectorCode: 'end_fastener',
      );

      final design = FrameCalculator().calculate(project);
      final xRail = design.members.firstWhere((m) => m.axis == MemberAxis.x);
      final yRail = design.members.firstWhere((m) => m.axis == MemberAxis.y);

      expect(xRail.cutLengthMm, 920);
      expect(yRail.cutLengthMm, 420);
    });

    test('summarizes profile and connector BOM quantities', () {
      final project = FrameProject.defaults().copyWith(
        lengthMm: 1200,
        widthMm: 600,
        heightMm: 800,
        shelfLevels: 3,
        profileCode: '3030',
        connectorCode: 'inside_connector',
      );

      final design = FrameCalculator().calculate(project);
      final profileItems = design.bom.where((item) => item.kind == BomKind.profile);
      final connector = design.bom.firstWhere((item) => item.code == 'inside_connector');
      final screw = design.bom.firstWhere((item) => item.code == 'm6_socket_bolt');

      expect(profileItems.length, 3);
      expect(connector.quantity, 24);
      expect(screw.quantity, 48);
    });
  });
}
