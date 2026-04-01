import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omao_app/features/controller/controller_assets.dart';

import '../../application/providers/controller_providers.dart';
import '../../domain/models/waveform.dart';
import '../widgets/new_waveform_editor_card.dart';

class NewWaveformScreen extends ConsumerStatefulWidget {
  const NewWaveformScreen({
    required this.initialName,
    required this.channel,
    this.existingWaveform,
    super.key,
  });

  final String initialName;
  final WaveformChannel channel;
  final Waveform? existingWaveform;

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
    if (widget.existingWaveform != null) {
      _restoreExistingWaveform(widget.existingWaveform!);
    }
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
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [Color(0xFF8C7ABF), Color.fromRGBO(250, 250, 250, 0.98)],
            stops: [0.0, 0.6],
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6FB),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFDFDFDF).withValues(alpha: 0.5),
                    ),
                  ),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: '删除波形',
                        backgroundColor: const Color(0xFFD9D9DA),
                        textColor: const Color(0xFF777777),
                        onTap: _delete,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: '保存波形',
                        backgroundGradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFA89AE9), Color(0xFF543A99)],
                          stops: [0.0608, 0.8518],
                          transform: GradientRotation(4.314),
                        ),
                        textColor: Colors.white,
                        onTap: _save,
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _handleBackPressed,
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
            Text(
              widget.existingWaveform != null ? '编辑波形' : '自定义波形',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                  fontSize: 16,
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
                        color: Color(0xFFC0C0C0),
                        fontSize: 13,
                      ),
                    ),
                    if (_nameController.text.isNotEmpty) ...[
                      const SizedBox(width: 12),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入波形名称')));
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
      id: widget.existingWaveform?.id ?? 0,
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

  void _restoreExistingWaveform(Waveform waveform) {
    final pageValues = List.generate(
      _pageCount,
      (_) => List<int>.filled(_controllerCount, 0),
    );
    final pageEnabled = [true, false, false, false];

    for (final keyframe in waveform.keyframes) {
      final pageIndex = keyframe.timeMs ~/ (_pageSeconds * 1000);
      final secondIndex = (keyframe.timeMs % (_pageSeconds * 1000)) ~/ 1000;
      if (pageIndex < 0 || pageIndex >= _pageCount) {
        continue;
      }
      if (secondIndex < 0 || secondIndex >= _controllerCount) {
        continue;
      }
      pageValues[pageIndex][secondIndex] = keyframe.value;
      if (keyframe.value != 0) {
        pageEnabled[pageIndex] = true;
      }
    }

    for (var i = 0; i < _pageCount; i++) {
      _pageValues[i] = pageValues[i];
      _pageEnabled[i] = i == 0 ? true : pageEnabled[i];
    }
  }

  Future<void> _delete() async {
    final confirmed = await _showConfirmDialog(
      title: '提示',
      message: '确定要删除自定义波形吗？',
      confirmLabel: '删除',
      cancelLabel: '取消',
      confirmResult: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final existing = widget.existingWaveform;
    if (existing != null) {
      final repo = ref.read(controllerRepositoryProvider);
      await repo.deleteWaveform(existing.id);
      ref.invalidate(waveformsProvider);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleBackPressed() async {
    final shouldLeave = await _showConfirmDialog(
      title: '提示',
      message: '波形尚未保存，是否返回上一页？',
      confirmLabel: '确认返回',
      cancelLabel: '继续编辑',
      confirmResult: true,
    );
    if (shouldLeave && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required bool confirmResult,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Container(
            height: 252,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ControllerAssets.waveformBg),
                fit: BoxFit.fill,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(38, 60, 38, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0XFF6A53A7),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6F6F76),
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        label: cancelLabel,
                        backgroundColor: const Color(0xFFD9D9DA),
                        textColor: const Color(0xFF797979),
                        onTap: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildDialogButton(
                        label: confirmLabel,
                        backgroundColor: const Color(0xFF6A53A7),
                        textColor: Colors.white,
                        onTap: () => Navigator.of(dialogContext).pop(confirmResult),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  Widget _buildDialogButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 42,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.backgroundColor,
    this.backgroundGradient,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(999),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label, style: TextStyle(color: textColor, fontSize: 15)),
        ),
      ),
    );
  }
}
