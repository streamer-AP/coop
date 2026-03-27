import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/controller_providers.dart';
import '../../domain/models/waveform.dart';
import '../widgets/new_waveform_editor_card.dart';

class NewWaveformScreen extends ConsumerStatefulWidget {
  const NewWaveformScreen({
    required this.initialName,
    required this.channel,
    super.key,
  });

  final String initialName;
  final String channel;

  @override
  ConsumerState<NewWaveformScreen> createState() => _NewWaveformScreenState();
}

class _NewWaveformScreenState extends ConsumerState<NewWaveformScreen> {
  static const _pageCount = 4;
  static const _pageSeconds = 8;
  static const _controllerCount = 8;

  late final TextEditingController _nameController;

  final List<List<int>> _pageValues = List.generate(
    _pageCount,
    (_) => List<int>.filled(_controllerCount, 0),
  );
  final List<bool> _pageEnabled = [true, false, false, false];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB7A5D8), Color(0xFFF7F6FB)],
            stops: [0.0, 0.88],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 10),
              _buildNameField(),
              const SizedBox(height: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: NewWaveformEditorCard(
                    pageIndex: _currentPage,
                    isEnabled: _pageEnabled[_currentPage],
                    values: _pageValues[_currentPage],
                    onToggleEnabled: _toggleCurrentPageEnabled,
                    onReset: _resetCurrentPage,
                    onPreviousPage: _goPreviousPage,
                    onNextPage: _goNextPage,
                    onValueChanged: (index, value) {
                      setState(() {
                        _pageValues[_currentPage][index] = value;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomActionButton(
                        label: '删除波形',
                        enabled: false,
                        backgroundColor: const Color(0xFFD8D8DC),
                        textColor: const Color(0xFF8E8E95),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BottomActionButton(
                        label: '保存波形',
                        enabled: true,
                        backgroundColor: Colors.transparent,
                        textColor: Colors.white,
                        onTap: _save,
                        useGradient: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const Text(
              '自定义波形',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                maxLength: 5,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                style: const TextStyle(
                  color: Color(0xFF1F1F24),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                decoration: const InputDecoration(
                  hintText: '请输入名称',
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _nameController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_nameController.text.length}/5',
                      style: const TextStyle(
                        color: Color(0xB3B4B4BA),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_nameController.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(_nameController.clear),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB9B9BF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCurrentPageEnabled() {
    if (_currentPage == 0 && !_pageEnabled[_currentPage]) {
      return;
    }

    if (_currentPage == 0) {
      return;
    }

    setState(() {
      _pageEnabled[_currentPage] = !_pageEnabled[_currentPage];
    });
  }

  void _resetCurrentPage() {
    setState(() {
      for (var page = 0; page < _pageCount; page++) {
        _pageValues[page] = List<int>.filled(_controllerCount, 0);
      }
    });
  }

  void _goPreviousPage() {
    if (_currentPage == 0) {
      return;
    }
    _switchToPage(_currentPage - 1);
  }

  void _goNextPage() {
    if (_currentPage >= _pageCount - 1 || !_pageEnabled[_currentPage]) {
      return;
    }
    _switchToPage(_currentPage + 1);
  }

  void _switchToPage(int targetPage) {
    setState(() {
      _currentPage = targetPage;
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
    for (var page = 0; page < _pageCount; page++) {
      for (var second = 0; second < _controllerCount; second++) {
        keyframes.add(
          WaveformKeyframe(
            timeMs: page * _pageSeconds * 1000 + second * 1000,
            value: _pageValues[page][second],
          ),
        );
      }
    }

    final waveform = Waveform(
      id: 0,
      name: name,
      channel: widget.channel,
      durationMs: _pageCount * _pageSeconds * 1000,
      isBuiltIn: false,
      keyframes: keyframes,
    );

    final repo = ref.read(controllerRepositoryProvider);
    await repo.saveWaveform(waveform);
    ref.invalidate(waveformsProvider);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.enabled,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.useGradient = false,
  });

  final String label;
  final bool enabled;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            gradient: useGradient ? AppColors.purpleButtonGradient : null,
            color: useGradient ? null : backgroundColor,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
