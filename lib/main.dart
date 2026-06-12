import 'package:flutter/material.dart';

import 'src/exporters.dart';
import 'src/frame_calculator.dart';
import 'src/models.dart';

void main() {
  runApp(const AluminumProfileDesignerApp());
}

class AluminumProfileDesignerApp extends StatelessWidget {
  const AluminumProfileDesignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '型材 DIY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E6B57)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
      ),
      home: const DesignerHomePage(),
    );
  }
}

class DesignerHomePage extends StatefulWidget {
  const DesignerHomePage({super.key});

  @override
  State<DesignerHomePage> createState() => _DesignerHomePageState();
}

class _DesignerHomePageState extends State<DesignerHomePage> {
  final _calculator = FrameCalculator();
  final _repository = ProjectRepository();
  final _projectCodec = const ProjectCodec();
  final _csvExporter = const BomCsvExporter();
  final _importController = TextEditingController();
  int _tabIndex = 0;
  FrameProject _project = FrameProject.defaults();
  Member? _selectedMember;

  FrameDesign get _design => _calculator.calculate(_project);

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  void _updateProject(FrameProject project) {
    setState(() {
      _project = project;
      _selectedMember = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DesignPage(project: _project, onChanged: _updateProject),
      PreviewPage(
        design: _design,
        selectedMember: _selectedMember,
        onMemberSelected: (member) => setState(() => _selectedMember = member),
      ),
      BomPage(design: _design, csv: _csvExporter.export(_design)),
      ProjectPage(
        project: _project,
        projects: _repository.list(),
        projectJson: _projectCodec.encodeProject(_project),
        onSave: () {
          _repository.save(_project);
          _showMessage('项目已保存到当前会话');
        },
        onDuplicate: () => _updateProject(_repository.duplicate(_project)),
        onLoad: _updateProject,
        importController: _importController,
        onImport: () {
          try {
            _updateProject(_projectCodec.decodeProject(_importController.text));
            _showMessage('项目已导入');
          } on FormatException catch (error) {
            _showMessage(error.message);
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('铝型材 DIY 设计'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '￥${_design.totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.tune), label: '设计'),
          NavigationDestination(icon: Icon(Icons.view_in_ar), label: '3D'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: '清单'),
          NavigationDestination(icon: Icon(Icons.folder_copy), label: '项目'),
        ],
      ),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class DesignPage extends StatelessWidget {
  const DesignPage({required this.project, required this.onChanged, super.key});

  final FrameProject project;
  final ValueChanged<FrameProject> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('结构参数', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _NumberField(
          label: '长度 mm',
          value: project.lengthMm,
          min: 200,
          max: 6000,
          step: 50,
          onChanged: (value) => onChanged(project.copyWith(lengthMm: value)),
        ),
        _NumberField(
          label: '宽度 mm',
          value: project.widthMm,
          min: 200,
          max: 3000,
          step: 50,
          onChanged: (value) => onChanged(project.copyWith(widthMm: value)),
        ),
        _NumberField(
          label: '高度 mm',
          value: project.heightMm,
          min: 200,
          max: 3000,
          step: 50,
          onChanged: (value) => onChanged(project.copyWith(heightMm: value)),
        ),
        _NumberField(
          label: '水平层数',
          value: project.shelfLevels,
          min: 2,
          max: 8,
          step: 1,
          onChanged: (value) => onChanged(project.copyWith(shelfLevels: value)),
        ),
        const SizedBox(height: 16),
        Text('型材与连接', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: [
            for (final spec in profileSpecs.values)
              ButtonSegment(value: spec.code, label: Text(spec.code)),
          ],
          selected: {project.profileCode},
          onSelectionChanged: (selected) => onChanged(project.copyWith(profileCode: selected.first)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: project.connectorCode,
          decoration: const InputDecoration(labelText: '连接方式', border: OutlineInputBorder()),
          items: [
            for (final connector in connectorRules.values)
              DropdownMenuItem(value: connector.code, child: Text(connector.name)),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(project.copyWith(connectorCode: value));
            }
          },
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          IconButton(
            onPressed: value <= min ? null : () => onChanged((value - step).clamp(min, max).toInt()),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 72,
            child: Text('$value', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton(
            onPressed: value >= max ? null : () => onChanged((value + step).clamp(min, max).toInt()),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

class PreviewPage extends StatelessWidget {
  const PreviewPage({
    required this.design,
    required this.selectedMember,
    required this.onMemberSelected,
    super.key,
  });

  final FrameDesign design;
  final Member? selectedMember;
  final ValueChanged<Member> onMemberSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTapUp: (_) {
              if (design.members.isNotEmpty) {
                final next = selectedMember == null
                    ? design.members.first
                    : design.members[(design.members.indexOf(selectedMember!) + 1) % design.members.length];
                onMemberSelected(next);
              }
            },
            child: CustomPaint(
              painter: FramePreviewPainter(design: design, selectedMember: selectedMember),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Text(
            selectedMember == null
                ? '点按预览区可依次查看构件'
                : '${selectedMember!.label}：${selectedMember!.profileCode}，切割 ${selectedMember!.cutLengthMm}mm',
          ),
        ),
      ],
    );
  }
}

class FramePreviewPainter extends CustomPainter {
  FramePreviewPainter({required this.design, required this.selectedMember});

  final FrameDesign design;
  final Member? selectedMember;

  @override
  void paint(Canvas canvas, Size size) {
    final project = design.project;
    final scale = [
      size.width / (project.lengthMm + project.widthMm * 0.65 + 160),
      size.height / (project.heightMm + project.widthMm * 0.45 + 180),
    ].reduce((a, b) => a < b ? a : b);
    final origin = Offset(size.width * 0.18, size.height * 0.72);
    final paint = Paint()
      ..strokeWidth = design.profile.sizeMm * scale
      ..strokeCap = StrokeCap.square
      ..color = const Color(0xFF4E5964);
    final selectedPaint = Paint()
      ..strokeWidth = (design.profile.sizeMm * scale) + 4
      ..strokeCap = StrokeCap.square
      ..color = const Color(0xFFD97706);

    for (final member in design.members) {
      final start = _project(member.xMm, member.yMm, member.zMm, origin, scale);
      final end = switch (member.axis) {
        MemberAxis.x => _project(member.xMm + member.netLengthMm, member.yMm, member.zMm, origin, scale),
        MemberAxis.y => _project(member.xMm, member.yMm + member.netLengthMm, member.zMm, origin, scale),
        MemberAxis.z => _project(member.xMm, member.yMm, member.zMm + member.netLengthMm, origin, scale),
      };
      canvas.drawLine(start, end, member.id == selectedMember?.id ? selectedPaint : paint);
    }
  }

  Offset _project(int x, int y, int z, Offset origin, double scale) {
    return Offset(
      origin.dx + x * scale + y * scale * 0.45,
      origin.dy - z * scale + y * scale * 0.32,
    );
  }

  @override
  bool shouldRepaint(covariant FramePreviewPainter oldDelegate) {
    return oldDelegate.design != design || oldDelegate.selectedMember != selectedMember;
  }
}

class BomPage extends StatelessWidget {
  const BomPage({required this.design, required this.csv, super.key});

  final FrameDesign design;
  final String csv;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('下料与 BOM', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final item in design.bom)
          Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text('${item.quantity}${item.unit}${item.lengthMm == null ? '' : ' · ${item.lengthMm}mm'}'),
              trailing: Text('￥${item.totalPrice.toStringAsFixed(2)}'),
            ),
          ),
        const SizedBox(height: 12),
        SelectableText('CSV 导出内容\n\n$csv'),
      ],
    );
  }
}

class ProjectPage extends StatelessWidget {
  const ProjectPage({
    required this.project,
    required this.projects,
    required this.projectJson,
    required this.onSave,
    required this.onDuplicate,
    required this.onLoad,
    required this.importController,
    required this.onImport,
    super.key,
  });

  final FrameProject project;
  final List<FrameProject> projects;
  final String projectJson;
  final VoidCallback onSave;
  final VoidCallback onDuplicate;
  final ValueChanged<FrameProject> onLoad;
  final TextEditingController importController;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(onPressed: onSave, icon: const Icon(Icons.save), label: const Text('保存当前项目')),
        OutlinedButton.icon(onPressed: onDuplicate, icon: const Icon(Icons.copy), label: const Text('复制项目')),
        const SizedBox(height: 16),
        Text('已保存项目', style: Theme.of(context).textTheme.titleLarge),
        for (final saved in projects)
          ListTile(
            title: Text(saved.name),
            subtitle: Text('${saved.lengthMm} x ${saved.widthMm} x ${saved.heightMm}mm · ${saved.profileCode}'),
            onTap: () => onLoad(saved),
          ),
        const SizedBox(height: 16),
        Text('项目 JSON 导出', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SelectableText(projectJson),
        const SizedBox(height: 16),
        TextField(
          controller: importController,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: '粘贴项目 JSON 后导入',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: onImport, icon: const Icon(Icons.upload_file), label: const Text('导入项目')),
      ],
    );
  }
}
