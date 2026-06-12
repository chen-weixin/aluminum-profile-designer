enum FrameTemplateKind {
  rectangularRack,
  cabinetFrame,
  equipmentFrame,
}

enum MemberAxis { x, y, z }

enum BomKind { profile, connector, fastener }

class ProfileSpec {
  const ProfileSpec({
    required this.code,
    required this.name,
    required this.sizeMm,
    required this.slotWidthMm,
    required this.pricePerMeter,
  });

  final String code;
  final String name;
  final int sizeMm;
  final int slotWidthMm;
  final double pricePerMeter;
}

class ConnectorRule {
  const ConnectorRule({
    required this.code,
    required this.name,
    required this.railEndDeductionProfileWidths,
    required this.connectorPerNode,
    required this.boltsPerConnector,
    required this.connectorPrice,
    required this.boltPrice,
  });

  final String code;
  final String name;
  final int railEndDeductionProfileWidths;
  final int connectorPerNode;
  final int boltsPerConnector;
  final double connectorPrice;
  final double boltPrice;
}

class FrameProject {
  const FrameProject({
    required this.id,
    required this.name,
    required this.templateKind,
    required this.lengthMm,
    required this.widthMm,
    required this.heightMm,
    required this.shelfLevels,
    required this.profileCode,
    required this.connectorCode,
  });

  factory FrameProject.defaults() {
    return const FrameProject(
      id: 'default',
      name: '我的型材框架',
      templateKind: FrameTemplateKind.rectangularRack,
      lengthMm: 1200,
      widthMm: 600,
      heightMm: 800,
      shelfLevels: 2,
      profileCode: '3030',
      connectorCode: 'corner_bracket',
    );
  }

  factory FrameProject.fromJson(Map<String, Object?> json) {
    return FrameProject(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? '未命名项目',
      templateKind: FrameTemplateKind.values.firstWhere(
        (kind) => kind.name == json['templateKind'],
        orElse: () => FrameTemplateKind.rectangularRack,
      ),
      lengthMm: json['lengthMm'] as int? ?? 1200,
      widthMm: json['widthMm'] as int? ?? 600,
      heightMm: json['heightMm'] as int? ?? 800,
      shelfLevels: json['shelfLevels'] as int? ?? 2,
      profileCode: json['profileCode'] as String? ?? '3030',
      connectorCode: json['connectorCode'] as String? ?? 'corner_bracket',
    );
  }

  final String id;
  final String name;
  final FrameTemplateKind templateKind;
  final int lengthMm;
  final int widthMm;
  final int heightMm;
  final int shelfLevels;
  final String profileCode;
  final String connectorCode;

  FrameProject copyWith({
    String? id,
    String? name,
    FrameTemplateKind? templateKind,
    int? lengthMm,
    int? widthMm,
    int? heightMm,
    int? shelfLevels,
    String? profileCode,
    String? connectorCode,
  }) {
    return FrameProject(
      id: id ?? this.id,
      name: name ?? this.name,
      templateKind: templateKind ?? this.templateKind,
      lengthMm: lengthMm ?? this.lengthMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      shelfLevels: shelfLevels ?? this.shelfLevels,
      profileCode: profileCode ?? this.profileCode,
      connectorCode: connectorCode ?? this.connectorCode,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'templateKind': templateKind.name,
      'lengthMm': lengthMm,
      'widthMm': widthMm,
      'heightMm': heightMm,
      'shelfLevels': shelfLevels,
      'profileCode': profileCode,
      'connectorCode': connectorCode,
    };
  }
}

class Member {
  const Member({
    required this.id,
    required this.label,
    required this.axis,
    required this.profileCode,
    required this.netLengthMm,
    required this.cutLengthMm,
    required this.xMm,
    required this.yMm,
    required this.zMm,
  });

  final String id;
  final String label;
  final MemberAxis axis;
  final String profileCode;
  final int netLengthMm;
  final int cutLengthMm;
  final int xMm;
  final int yMm;
  final int zMm;
}

class BomItem {
  const BomItem({
    required this.kind,
    required this.code,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.lengthMm,
  });

  final BomKind kind;
  final String code;
  final String name;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final int? lengthMm;
}

class FrameDesign {
  const FrameDesign({
    required this.project,
    required this.profile,
    required this.connector,
    required this.members,
    required this.bom,
    required this.totalPrice,
  });

  final FrameProject project;
  final ProfileSpec profile;
  final ConnectorRule connector;
  final List<Member> members;
  final List<BomItem> bom;
  final double totalPrice;
}
