import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controller_assets.dart';
import '../../domain/models/waveform.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/edit_waveforms_channel_tabs.dart';
import '../widgets/edit_waveforms_common_waveforms_section.dart';
import '../widgets/edit_waveforms_preset_panel.dart';
import '../widgets/new_waveform_dialog.dart';

class EditWaveformsMainScreen extends ConsumerStatefulWidget {
  const EditWaveformsMainScreen({super.key});

  @override
  ConsumerState<EditWaveformsMainScreen> createState() =>
      _EditWaveformsMainScreenState();
}

class _EditWaveformsMainScreenState
    extends ConsumerState<EditWaveformsMainScreen> {
  static const _officialPresetNames = [
    '羽毛轻扫',
    '深海呼吸',
    '午后清风',
    '晨露微光',
    '溪流潺潺',
    '丝绒摩挲',
    '深海潜流',
    '耳鬓厮磨',
    '钟摆催眠',
    '琴弦共鸣',
    '惊涛骇浪',
    '陨石坠落',
  ];

  int _selectedChannelIndex = 0;

  List<List<Waveform>> get _swingWaveformPages => const [
    [
      Waveform(id: 1001, name: '羽毛轻扫', channel: WaveformChannel.swing),
      Waveform(id: 1002, name: '深海呼吸', channel: WaveformChannel.swing),
      Waveform(id: 1003, name: '午后清风', channel: WaveformChannel.swing),
      Waveform(id: 1004, name: '晨露微光', channel: WaveformChannel.swing),
    ],
    [
      Waveform(id: 1005, name: '溪流潺潺', channel: WaveformChannel.swing),
      Waveform(id: 1006, name: '丝绒摩挲', channel: WaveformChannel.swing),
      Waveform(id: 1007, name: '深海潜流', channel: WaveformChannel.swing),
      Waveform(id: 1008, name: '耳鬓厮磨', channel: WaveformChannel.swing),
    ],
    [
      Waveform(id: 1009, name: '钟摆催眠', channel: WaveformChannel.swing),
      Waveform(id: 1010, name: '琴弦共鸣', channel: WaveformChannel.swing),
      Waveform(id: 1011, name: '惊涛骇浪', channel: WaveformChannel.swing),
      Waveform(id: 1012, name: '陨石坠落', channel: WaveformChannel.swing),
    ],
  ];

  List<List<Waveform>> get _vibrationWaveformPages => const [
    [
      Waveform(id: 2001, name: '羽毛轻扫', channel: WaveformChannel.vibration),
      Waveform(id: 2002, name: '深海呼吸', channel: WaveformChannel.vibration),
      Waveform(id: 2003, name: '午后清风', channel: WaveformChannel.vibration),
      Waveform(id: 2004, name: '晨露微光', channel: WaveformChannel.vibration),
    ],
    [
      Waveform(id: 2005, name: '溪流潺潺', channel: WaveformChannel.vibration),
      Waveform(id: 2006, name: '丝绒摩挲', channel: WaveformChannel.vibration),
      Waveform(id: 2007, name: '深海潜流', channel: WaveformChannel.vibration),
      Waveform(id: 2008, name: '耳鬓厮磨', channel: WaveformChannel.vibration),
    ],
    [
      Waveform(id: 2009, name: '钟摆催眠', channel: WaveformChannel.vibration),
      Waveform(id: 2010, name: '琴弦共鸣', channel: WaveformChannel.vibration),
      Waveform(id: 2011, name: '惊涛骇浪', channel: WaveformChannel.vibration),
      Waveform(id: 2012, name: '陨石坠落', channel: WaveformChannel.vibration),
    ],
  ];

  List<List<Waveform>> get _currentCommonWaveformPages {
    return _selectedChannelIndex == 0
        ? _swingWaveformPages
        : _vibrationWaveformPages;
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

            colors: [Color(0xFF8C7ABF), Color.fromRGBO(250, 250, 250, 0.98)],
            stops: [0.0, 0.5167],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: SizedBox(
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '配置常用波形',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 75),
                child: EditWaveformsChannelTabs(
                  selectedIndex: _selectedChannelIndex,
                  onChanged: (index) {
                    setState(() {
                      _selectedChannelIndex = index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              EditWaveformsCommonWaveformsSection(
                pages: _currentCommonWaveformPages,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        
                        EditWaveformsPresetPanel(
                          officialPresetNames: _officialPresetNames,
                          onCreateTap: _showNewWaveformDialog,
                        ),
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                decoration: BoxDecoration(
                  color: ControllerAssets.editBgBackground,
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
                        label: '取消',
                        backgroundColor: const Color(0xFFD8D8DC),
                        textColor: const Color(0xFF777777),
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: '保存',
                        backgroundColor: ControllerAssets.accent,
                        textColor: Colors.white,
                        onTap: () => Navigator.of(context).maybePop(),
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

  Future<void> _showNewWaveformDialog() async {
    final waveformName = await NewWaveformDialog.show(context);
    if (!mounted || waveformName == null) {
      return;
    }

    await context.pushNamed(
      RouteNames.newWaveform,
      extra: {
        'initialName': waveformName,
        'channel':
            _selectedChannelIndex == 0
                ? WaveformChannel.swing
                : WaveformChannel.vibration,
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
