import 'dart:convert';

import 'models.dart';

class ProjectCodec {
  const ProjectCodec();

  String encodeProject(FrameProject project) {
    return const JsonEncoder.withIndent('  ').convert(project.toJson());
  }

  FrameProject decodeProject(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('项目文件格式不正确');
    }
    return FrameProject.fromJson(decoded);
  }
}

class BomCsvExporter {
  const BomCsvExporter();

  String export(FrameDesign design) {
    final rows = <List<String>>[
      ['类型', '编码', '名称', '长度mm', '数量', '单位', '单价', '小计'],
      for (final item in design.bom)
        [
          _kindLabel(item.kind),
          item.code,
          item.name,
          item.lengthMm?.toString() ?? '',
          item.quantity.toString(),
          item.unit,
          item.unitPrice.toStringAsFixed(2),
          item.totalPrice.toStringAsFixed(2),
        ],
      ['', '', '', '', '', '', '合计', design.totalPrice.toStringAsFixed(2)],
    ];

    return rows.map((row) => row.map(_escape).join(',')).join('\n');
  }

  String _kindLabel(BomKind kind) {
    return switch (kind) {
      BomKind.profile => '型材',
      BomKind.connector => '连接件',
      BomKind.fastener => '紧固件',
    };
  }

  String _escape(String value) {
    if (!value.contains(',') && !value.contains('"') && !value.contains('\n')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}

class ProjectRepository {
  ProjectRepository({FrameProject? initialProject}) : _projects = [initialProject ?? FrameProject.defaults()];

  final List<FrameProject> _projects;

  List<FrameProject> list() => List.unmodifiable(_projects);

  void save(FrameProject project) {
    final index = _projects.indexWhere((item) => item.id == project.id);
    if (index == -1) {
      _projects.add(project);
    } else {
      _projects[index] = project;
    }
  }

  FrameProject duplicate(FrameProject project) {
    final duplicated = project.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${project.name} 副本',
    );
    save(duplicated);
    return duplicated;
  }
}
