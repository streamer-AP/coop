import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/controller_providers.dart';
import '../../domain/models/waveform.dart';

class WaveformEditorScreen extends ConsumerStatefulWidget {
  final Waveform? existingWaveform;

  const WaveformEditorScreen({super.key, this.existingWaveform});

  @override
  ConsumerState<WaveformEditorScreen> createState() =>
      _WaveformEditorScreenState();
}

class _WaveformEditorScreenState extends ConsumerState<WaveformEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;

  static const _maxPages = 4;
  static const _pageMs = 8000;
  static const _stepMs = 1000;
  static const _minValue = 15;
  static const _maxValue = 100;

  int _enabledPages = 1;
  late List<List<_KeyframePoint>> _swingPages;
  late List<List<_KeyframePoint>> _vibrationPages;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _maxPages, vsync: this);

    final waveform = widget.existingWaveform;
    _nameController = TextEditingController(text: waveform?.name ?? '');

    if (waveform != null) {
      _enabledPages = max(1, (waveform.durationMs / _pageMs).ceil());
      _swingPages = _buildPages(waveform.keyframes, true);
      _vibrationPages = _buildPages(waveform.keyframes, false);
    } else {
      _swingPages = List.generate(_maxPages, (_) => _defaultPage());
      _vibrationPages = List.generate(_maxPages, (_) => _defaultPage());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<List<_KeyframePoint>> _buildPages(
    List<WaveformKeyframe> keyframes,
    bool isSwing,
  ) {
    final pages = List.generate(_maxPages, (_) => <_KeyframePoint>[]);

    for (final kf in keyframes) {
      final pageIndex = kf.timeMs ~/ _pageMs;
      final localMs = kf.timeMs % _pageMs;
      if (pageIndex < _maxPages) {
        pages[pageIndex].add(
          _KeyframePoint(
            timeMs: localMs,
            value: isSwing ? kf.swingValue : kf.vibrationValue,
          ),
        );
      }
    }

    for (var i = 0; i < _maxPages; i++) {
      if (pages[i].isEmpty) {
        pages[i] = _defaultPage();
      }
      pages[i].sort((a, b) => a.timeMs.compareTo(b.timeMs));
    }

    return pages;
  }

  List<_KeyframePoint> _defaultPage() {
    return List.generate(
      (_pageMs / _stepMs).ceil() + 1,
      (i) => _KeyframePoint(timeMs: i * _stepMs, value: _minValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingWaveform != null ? '编辑波形' : '新建波形',
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _nameController,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: '波形名称',
                hintText: '最多5个汉字',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ),
          _buildPageTabs(),
          Expanded(child: _buildEditor()),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildPageTabs() {
    return Row(
      children: [
        Expanded(
          child: TabBar(
            controller: _tabController,
            tabs: List.generate(_maxPages, (i) {
              final enabled = i < _enabledPages;
              return Tab(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: enabled ? null : AppColors.textHint,
                  ),
                ),
              );
            }),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _enabledPages < _maxPages
              ? () => setState(() {
                    _enabledPages++;
                  })
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _enabledPages > 1
              ? () => setState(() {
                    _enabledPages--;
                    if (_tabController.index >= _enabledPages) {
                      _tabController.animateTo(_enabledPages - 1);
                    }
                  })
              : null,
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return TabBarView(
      controller: _tabController,
      children: List.generate(_maxPages, (pageIndex) {
        if (pageIndex >= _enabledPages) {
          return const Center(
            child: Text(
              '此页面未启用',
              style: TextStyle(color: AppColors.textHint),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '摇摆',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: _WaveformChart(
                  points: _swingPages[pageIndex],
                  color: AppColors.primary,
                  onUpdate: (points) => setState(() {
                    _swingPages[pageIndex] = points;
                  }),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '震动',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: _WaveformChart(
                  points: _vibrationPages[pageIndex],
                  color: AppColors.secondary,
                  onUpdate: (points) => setState(() {
                    _vibrationPages[pageIndex] = points;
                  }),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton.icon(
            onPressed: _resetCurrentPage,
            icon: const Icon(Icons.refresh),
            label: const Text('重置本页'),
          ),
          if (widget.existingWaveform != null)
            OutlinedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text(
                '删除',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  void _resetCurrentPage() {
    setState(() {
      final page = _tabController.index;
      _swingPages[page] = _defaultPage();
      _vibrationPages[page] = _defaultPage();
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入波形名称')),
      );
      return;
    }

    final keyframes = <WaveformKeyframe>[];
    for (var page = 0; page < _enabledPages; page++) {
      final baseMs = page * _pageMs;
      final swingPoints = _swingPages[page];
      final vibPoints = _vibrationPages[page];

      final allTimes = <int>{};
      for (final p in swingPoints) {
        allTimes.add(p.timeMs);
      }
      for (final p in vibPoints) {
        allTimes.add(p.timeMs);
      }
      final sortedTimes = allTimes.toList()..sort();

      for (final t in sortedTimes) {
        final swing = _valueAtTime(swingPoints, t);
        final vibration = _valueAtTime(vibPoints, t);
        keyframes.add(
          WaveformKeyframe(
            timeMs: baseMs + t,
            swingValue: swing,
            vibrationValue: vibration,
          ),
        );
      }
    }

    final waveform = Waveform(
      id: widget.existingWaveform?.id ?? 0,
      name: name,
      durationMs: _enabledPages * _pageMs,
      isBuiltIn: false,
      keyframes: keyframes,
    );

    final repo = ref.read(controllerRepositoryProvider);
    await repo.saveWaveform(waveform);
    ref.invalidate(waveformsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除波形'),
        content: const Text('确定要删除这个波形吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.existingWaveform != null) {
      final repo = ref.read(controllerRepositoryProvider);
      await repo.deleteWaveform(widget.existingWaveform!.id);
      ref.invalidate(waveformsProvider);
      if (mounted) Navigator.of(context).pop();
    }
  }

  int _valueAtTime(List<_KeyframePoint> points, int timeMs) {
    if (points.isEmpty) return _minValue;
    if (points.length == 1) return points.first.value;

    for (var i = 0; i < points.length - 1; i++) {
      if (timeMs >= points[i].timeMs && timeMs <= points[i + 1].timeMs) {
        final range = points[i + 1].timeMs - points[i].timeMs;
        if (range == 0) return points[i].value;
        final t = (timeMs - points[i].timeMs) / range;
        return (points[i].value +
                (points[i + 1].value - points[i].value) * t)
            .round()
            .clamp(_minValue, _maxValue);
      }
    }

    return points.last.value;
  }
}

class _KeyframePoint {
  final int timeMs;
  int value;

  _KeyframePoint({required this.timeMs, required this.value});
}

class _WaveformChart extends StatefulWidget {
  final List<_KeyframePoint> points;
  final Color color;
  final ValueChanged<List<_KeyframePoint>> onUpdate;

  const _WaveformChart({
    required this.points,
    required this.color,
    required this.onUpdate,
  });

  @override
  State<_WaveformChart> createState() => _WaveformChartState();
}

class _WaveformChartState extends State<_WaveformChart> {
  static const _minValue = 15;
  static const _maxValue = 100;
  static const _pageMs = 8000;

  int? _activePointIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) => _onDragStart(details, constraints),
          onPanUpdate: (details) => _onDragUpdate(details, constraints),
          onPanEnd: (_) => _activePointIndex = null,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _WaveformPainter(
              points: widget.points,
              color: widget.color,
              activeIndex: _activePointIndex,
            ),
          ),
        );
      },
    );
  }

  void _onDragStart(DragStartDetails details, BoxConstraints constraints) {
    final x = details.localPosition.dx;
    final y = details.localPosition.dy;

    double minDist = double.infinity;
    int? closest;

    for (var i = 0; i < widget.points.length; i++) {
      final px = widget.points[i].timeMs / _pageMs * constraints.maxWidth;
      final py = (1 - (widget.points[i].value - _minValue) /
              (_maxValue - _minValue)) *
          constraints.maxHeight;
      final dist = sqrt(pow(x - px, 2) + pow(y - py, 2));
      if (dist < minDist && dist < 30) {
        minDist = dist;
        closest = i;
      }
    }

    _activePointIndex = closest;
    if (closest != null) {
      _updateValue(details.localPosition.dy, constraints);
    }
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_activePointIndex != null) {
      _updateValue(details.localPosition.dy, constraints);
    }
  }

  void _updateValue(double dy, BoxConstraints constraints) {
    if (_activePointIndex == null) return;
    final normalized = 1 - (dy / constraints.maxHeight).clamp(0, 1);
    final value =
        (_minValue + normalized * (_maxValue - _minValue)).round().clamp(
              _minValue,
              _maxValue,
            );
    setState(() {
      widget.points[_activePointIndex!].value = value;
    });
    widget.onUpdate(widget.points);
  }
}

class _WaveformPainter extends CustomPainter {
  final List<_KeyframePoint> points;
  final Color color;
  final int? activeIndex;

  static const _minValue = 15;
  static const _maxValue = 100;
  static const _pageMs = 8000;

  _WaveformPainter({
    required this.points,
    required this.color,
    this.activeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final activePointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = points[i].timeMs / _pageMs * size.width;
      final y = (1 - (points[i].value - _minValue) /
              (_maxValue - _minValue)) *
          size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(
      points.last.timeMs / _pageMs * size.width,
      size.height,
    );
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      final x = points[i].timeMs / _pageMs * size.width;
      final y = (1 - (points[i].value - _minValue) /
              (_maxValue - _minValue)) *
          size.height;

      canvas.drawCircle(
        Offset(x, y),
        i == activeIndex ? 8 : 5,
        i == activeIndex ? activePointPaint : pointPaint,
      );
    }

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (var i = 0; i <= 8; i++) {
      final x = i / 8 * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}

