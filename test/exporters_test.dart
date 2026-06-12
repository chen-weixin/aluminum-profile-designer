import 'package:flutter_test/flutter_test.dart';
import 'package:aluminum_profile_designer/src/exporters.dart';
import 'package:aluminum_profile_designer/src/frame_calculator.dart';
import 'package:aluminum_profile_designer/src/models.dart';

void main() {
  test('project codec round trips frame project json', () {
    final project = FrameProject.defaults().copyWith(
      id: 'p1',
      name: '测试框架',
      lengthMm: 1500,
      widthMm: 700,
      heightMm: 900,
      shelfLevels: 4,
      profileCode: '4040',
      connectorCode: 'end_fastener',
    );

    final codec = const ProjectCodec();
    final decoded = codec.decodeProject(codec.encodeProject(project));

    expect(decoded.name, '测试框架');
    expect(decoded.lengthMm, 1500);
    expect(decoded.profileCode, '4040');
    expect(decoded.connectorCode, 'end_fastener');
  });

  test('bom csv includes profile rows and total price', () {
    final design = FrameCalculator().calculate(FrameProject.defaults());

    final csv = const BomCsvExporter().export(design);

    expect(csv, contains('类型,编码,名称,长度mm,数量,单位,单价,小计'));
    expect(csv, contains('型材,3030'));
    expect(csv, contains('合计'));
  });
}
