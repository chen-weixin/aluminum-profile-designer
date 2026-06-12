import 'models.dart';

class FrameCalculator {
  FrameDesign calculate(FrameProject project) {
    final profile = profileSpecs[project.profileCode] ?? profileSpecs['3030']!;
    final connector = connectorRules[project.connectorCode] ?? connectorRules['corner_bracket']!;
    final levels = _levelHeights(project);
    final members = <Member>[
      ..._posts(project, profile),
      ..._rails(project, profile, connector, levels),
    ];
    final bom = _bom(project, profile, connector, members, levels.length);
    final totalPrice = bom.fold<double>(0, (sum, item) => sum + item.totalPrice);

    return FrameDesign(
      project: project,
      profile: profile,
      connector: connector,
      members: members,
      bom: bom,
      totalPrice: totalPrice,
    );
  }

  List<int> _levelHeights(FrameProject project) {
    final count = project.shelfLevels.clamp(2, 12);
    if (count == 1) {
      return [0];
    }
    final step = project.heightMm / (count - 1);
    return List<int>.generate(count, (index) => (step * index).round());
  }

  List<Member> _posts(FrameProject project, ProfileSpec profile) {
    final corners = <({int x, int y, String label})>[
      (x: 0, y: 0, label: '左前立柱'),
      (x: project.lengthMm, y: 0, label: '右前立柱'),
      (x: 0, y: project.widthMm, label: '左后立柱'),
      (x: project.lengthMm, y: project.widthMm, label: '右后立柱'),
    ];

    return [
      for (var i = 0; i < corners.length; i++)
        Member(
          id: 'post-$i',
          label: corners[i].label,
          axis: MemberAxis.z,
          profileCode: profile.code,
          netLengthMm: project.heightMm,
          cutLengthMm: project.heightMm,
          xMm: corners[i].x,
          yMm: corners[i].y,
          zMm: 0,
        ),
    ];
  }

  List<Member> _rails(
    FrameProject project,
    ProfileSpec profile,
    ConnectorRule connector,
    List<int> levels,
  ) {
    final deduction = connector.railEndDeductionProfileWidths * profile.sizeMm * 2;
    final xCutLength = (project.lengthMm - deduction).clamp(profile.sizeMm, project.lengthMm).toInt();
    final yCutLength = (project.widthMm - deduction).clamp(profile.sizeMm, project.widthMm).toInt();
    final rails = <Member>[];

    for (final z in levels) {
      rails.addAll([
        Member(
          id: 'x-front-$z',
          label: '前横梁 ${z}mm',
          axis: MemberAxis.x,
          profileCode: profile.code,
          netLengthMm: project.lengthMm,
          cutLengthMm: xCutLength,
          xMm: 0,
          yMm: 0,
          zMm: z,
        ),
        Member(
          id: 'x-back-$z',
          label: '后横梁 ${z}mm',
          axis: MemberAxis.x,
          profileCode: profile.code,
          netLengthMm: project.lengthMm,
          cutLengthMm: xCutLength,
          xMm: 0,
          yMm: project.widthMm,
          zMm: z,
        ),
        Member(
          id: 'y-left-$z',
          label: '左侧梁 ${z}mm',
          axis: MemberAxis.y,
          profileCode: profile.code,
          netLengthMm: project.widthMm,
          cutLengthMm: yCutLength,
          xMm: 0,
          yMm: 0,
          zMm: z,
        ),
        Member(
          id: 'y-right-$z',
          label: '右侧梁 ${z}mm',
          axis: MemberAxis.y,
          profileCode: profile.code,
          netLengthMm: project.widthMm,
          cutLengthMm: yCutLength,
          xMm: project.lengthMm,
          yMm: 0,
          zMm: z,
        ),
      ]);
    }

    return rails;
  }

  List<BomItem> _bom(
    FrameProject project,
    ProfileSpec profile,
    ConnectorRule connector,
    List<Member> members,
    int levelCount,
  ) {
    final grouped = <int, int>{};
    for (final member in members) {
      grouped.update(member.cutLengthMm, (count) => count + 1, ifAbsent: () => 1);
    }

    final items = <BomItem>[
      for (final entry in grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)))
        BomItem(
          kind: BomKind.profile,
          code: profile.code,
          name: '${profile.name} 型材 ${entry.key}mm',
          lengthMm: entry.key,
          quantity: entry.value,
          unit: '根',
          unitPrice: profile.pricePerMeter * entry.key / 1000,
          totalPrice: profile.pricePerMeter * entry.key / 1000 * entry.value,
        ),
    ];

    final connectionNodes = levelCount * 4;
    final connectorQty = connectionNodes * connector.connectorPerNode;
    final boltQty = connectorQty * connector.boltsPerConnector;
    items.addAll([
      BomItem(
        kind: BomKind.connector,
        code: connector.code,
        name: connector.name,
        quantity: connectorQty,
        unit: '个',
        unitPrice: connector.connectorPrice,
        totalPrice: connectorQty * connector.connectorPrice,
      ),
      BomItem(
        kind: BomKind.fastener,
        code: 'm6_socket_bolt',
        name: 'M6 内六角螺丝',
        quantity: boltQty,
        unit: '颗',
        unitPrice: connector.boltPrice,
        totalPrice: boltQty * connector.boltPrice,
      ),
    ]);

    return items;
  }
}

const profileSpecs = <String, ProfileSpec>{
  '2020': ProfileSpec(
    code: '2020',
    name: '欧标 2020',
    sizeMm: 20,
    slotWidthMm: 6,
    pricePerMeter: 18,
  ),
  '3030': ProfileSpec(
    code: '3030',
    name: '欧标 3030',
    sizeMm: 30,
    slotWidthMm: 8,
    pricePerMeter: 32,
  ),
  '4040': ProfileSpec(
    code: '4040',
    name: '欧标 4040',
    sizeMm: 40,
    slotWidthMm: 8,
    pricePerMeter: 52,
  ),
};

const connectorRules = <String, ConnectorRule>{
  'corner_bracket': ConnectorRule(
    code: 'corner_bracket',
    name: '外置角码连接',
    railEndDeductionProfileWidths: 0,
    connectorPerNode: 2,
    boltsPerConnector: 2,
    connectorPrice: 2.8,
    boltPrice: 0.18,
  ),
  'inside_connector': ConnectorRule(
    code: 'inside_connector',
    name: '内置连接件',
    railEndDeductionProfileWidths: 0,
    connectorPerNode: 2,
    boltsPerConnector: 2,
    connectorPrice: 3.6,
    boltPrice: 0.22,
  ),
  'end_fastener': ConnectorRule(
    code: 'end_fastener',
    name: '端面连接件',
    railEndDeductionProfileWidths: 1,
    connectorPerNode: 2,
    boltsPerConnector: 1,
    connectorPrice: 4.2,
    boltPrice: 0.25,
  ),
};
