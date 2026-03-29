import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller_assets.dart';
import '../../application/providers/controller_providers.dart';
import '../../domain/models/favorite_slot.dart';
import '../../domain/models/waveform.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/omao_toast.dart';
import '../widgets/edit_waveforms_channel_tabs.dart';
import '../widgets/edit_waveforms_common_waveforms_section.dart';
import '../widgets/edit_waveforms_preset_panel.dart';
import '../widgets/new_waveform_dialog.dart';

class EditWaveformsMainScreen extends ConsumerStatefulWidget {
  const EditWaveformsMainScreen({
    this.initialChannel = WaveformChannel.swing,
    super.key,
  });

  final WaveformChannel initialChannel;

  @override
  ConsumerState<EditWaveformsMainScreen> createState() =>
      _EditWaveformsMainScreenState();
}

class _EditWaveformsMainScreenState
    extends ConsumerState<EditWaveformsMainScreen> {
  late int _selectedChannelIndex =
      widget.initialChannel == WaveformChannel.swing ? 0 : 1;
  final List<int> _selectedCommonPageIndices = [0, 0];
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final favoriteSlotsAsync = ref.watch(favoriteSlotsProvider);
    final waveformsAsync = ref.watch(waveformsProvider);

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
        child: favoriteSlotsAsync.when(
          loading: () => const SafeArea(child: Center()),
          error: (error, _) => SafeArea(
            child: Center(
              child: Text(
                '常用波形加载失败',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          data: (favoriteSlots) => waveformsAsync.when(
            loading: () => const SafeArea(child: Center()),
            error: (error, _) => SafeArea(
              child: Center(
                child: Text(
                  '波形数据加载失败',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            data: (waveforms) {
              final currentChannel = _selectedChannelIndex == 0
                  ? WaveformChannel.swing
                  : WaveformChannel.vibration;
              final currentCommonPageIndex =
                  _selectedCommonPageIndices[_selectedChannelIndex];
              final currentChannelSlots = favoriteSlots
                  .where((slot) => slot.channel == currentChannel)
                  .toList();
              final configuredWaveformIds = currentChannelSlots
                  .map((slot) => slot.waveformId)
                  .toSet();
              final officialPresets = _buildOfficialPresets(
                currentChannel,
                waveforms,
              );
              final customPresets = _buildCustomPresets(
                currentChannel,
                waveforms,
              );
              final pages = _buildCurrentCommonWaveformPages(
                favoriteSlots,
                waveforms,
              );

              return SafeArea(
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
                      pages: pages,
                      initialPageIndex: currentCommonPageIndex,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedCommonPageIndices[_selectedChannelIndex] =
                              index;
                        });
                      },
                      onRemoveTap:
                          (pageIndex, itemIndex, _) =>
                              _removeCurrentPageSlot(
                                channel: currentChannel,
                                pageIndex: pageIndex,
                                itemIndex: itemIndex,
                                favoriteSlots: favoriteSlots,
                              ),
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
                                officialPresets: officialPresets,
                                customPresets: customPresets,
                                configuredWaveformIds: configuredWaveformIds,
                                onOfficialPresetTap:
                                    (waveform) => _addWaveformToCurrentPage(
                                      channel: currentChannel,
                                      waveform: waveform,
                                      favoriteSlots: favoriteSlots,
                                    ),
                                onCustomPresetAddTap:
                                    (waveform) => _addWaveformToCurrentPage(
                                      channel: currentChannel,
                                      waveform: waveform,
                                      favoriteSlots: favoriteSlots,
                                    ),
                                onCustomPresetTap:
                                    (waveform) => _openCustomWaveformEditor(
                                      waveform,
                                    ),
                                onCreateTap: _showNewWaveformDialog,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
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
                              backgroundColor: const Color(0xFFD9D9DA),
                              textColor: const Color(0xFF777777),
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              label: '保存',
                              backgroundGradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFA89AE9),
                                  Color(0xFF543A99),
                                ],
                                stops: [0.0608, 0.8518],
                                transform: GradientRotation(4.314),
                              ),
                              textColor: Colors.white,
                              onTap: () => _saveCurrentChannelConfig(
                                currentChannel: currentChannel,
                                pages: pages,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<List<Waveform>> _buildCurrentCommonWaveformPages(
    List<FavoriteSlot> slots,
    List<Waveform> waveforms,
  ) {
    return _selectedChannelIndex == 0
        ? _buildWaveformPages(WaveformChannel.swing, slots, waveforms)
        : _buildWaveformPages(WaveformChannel.vibration, slots, waveforms);
  }

  List<List<Waveform>> _buildWaveformPages(
    WaveformChannel channel,
    List<FavoriteSlot> slots,
    List<Waveform> waveforms,
  ) {
    return List.generate(3, (pageIndex) {
      final pageSlots = slots
          .where((slot) => slot.channel == channel && slot.page == pageIndex)
          .toList()
        ..sort((a, b) => a.index.compareTo(b.index));

      final slotByIndex = {for (final slot in pageSlots) slot.index: slot};

      return List.generate(4, (itemIndex) {
        final slot = slotByIndex[itemIndex];
        if (slot == null) {
          return Waveform(
            id: pageIndex * 100 + itemIndex,
            name: '',
            channel: channel,
          );
        }

        return _findWaveform(slot.waveformId, waveforms) ??
            Waveform(
              id: slot.waveformId,
              name: '',
              channel: channel,
            );
      });
    });
  }

  List<Waveform> _buildOfficialPresets(
    WaveformChannel channel,
    List<Waveform> waveforms,
  ) {
    return waveforms
        .where((waveform) => waveform.channel == channel && waveform.isBuiltIn)
        .toList();
  }

  List<Waveform> _buildCustomPresets(
    WaveformChannel channel,
    List<Waveform> waveforms,
  ) {
    return waveforms
        .where((waveform) => waveform.channel == channel && !waveform.isBuiltIn)
        .toList();
  }

  Waveform? _findWaveform(int waveformId, List<Waveform> waveforms) {
    for (final waveform in waveforms) {
      if (waveform.id == waveformId) {
        return waveform;
      }
    }
    return null;
  }

  Future<void> _saveCurrentChannelConfig({
    required WaveformChannel currentChannel,
    required List<List<Waveform>> pages,
  }) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final endpoint = currentChannel == WaveformChannel.swing
          ? ApiEndpoints.saveSwing
          : ApiEndpoints.saveVibration;
      final payload = _buildWaveformSavePayload(pages);
      final json = await apiClient.post(endpoint, data: payload);
      final code = json['code'] as int?;
      if (code != 200 && code != 0) {
        throw Exception(
          json['message'] as String? ?? json['msg'] as String? ?? '保存失败',
        );
      }

      if (!mounted) {
        return;
      }

      OmaoToast.show(context, '保存成功', isSuccess: true);
      Navigator.of(context).maybePop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      OmaoToast.show(
        context,
        error.toString().replaceFirst('Exception: ', ''),
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          
        });
      }
    }
  }

  Map<String, dynamic> _buildWaveformSavePayload(List<List<Waveform>> pages) {
    final flatWaveforms = pages.expand((page) => page).toList();
    final payload = <String, dynamic>{};

    for (var i = 0; i < 12; i++) {
      final waveform = flatWaveforms[i];
      payload['waveform${i + 1}'] = waveform.name.trim().isEmpty
          ? ''
          : waveform.name.trim();
    }

    payload['optionalWaveformsData'] = List.generate(
      flatWaveforms.length,
      (index) => _buildOptionalWaveformData(flatWaveforms[index]),
    );

    return payload;
  }

  Map<String, dynamic> _buildOptionalWaveformData(Waveform waveform) {
    final name = waveform.name.trim();
    if (name.isEmpty) {
      return {};
    }

    final sliderValue = List.generate(
      4,
      (pageIndex) => _buildSliderPageData(waveform, pageIndex),
    ).where((page) => page.isNotEmpty).toList();

    return {
      'waveformName': name,
      if (sliderValue.isNotEmpty) 'sliderValue': sliderValue,
    };
  }

  Map<String, dynamic> _buildSliderPageData(
    Waveform waveform,
    int pageIndex,
  ) {
    final enabledPages = math.max(1, (waveform.durationMs / 8000).ceil());
    if (pageIndex >= enabledPages) {
      return {};
    }

    final pageStartMs = pageIndex * 8000;
    final values = List<int>.filled(8, 0);
    var hasValue = false;

    final pageKeyframes = waveform.keyframes
        .where(
          (keyframe) =>
              keyframe.timeMs >= pageStartMs &&
              keyframe.timeMs < pageStartMs + 8000,
        )
        .toList()
      ..sort((a, b) => a.timeMs.compareTo(b.timeMs));

    for (final keyframe in pageKeyframes) {
      final relativeMs = keyframe.timeMs - pageStartMs;
      final valueIndex = relativeMs ~/ 1000;
      if (valueIndex < 0 || valueIndex >= values.length) {
        continue;
      }
      values[valueIndex] = keyframe.value;
      hasValue = true;
    }

    if (!hasValue) {
      return {};
    }

    return {
      'value1': values[0],
      'value2': values[1],
      'value3': values[2],
      'value4': values[3],
      'value5': values[4],
      'value6': values[5],
      'value7': values[6],
      'value8': values[7],
    };
  }

  Future<void> _addWaveformToCurrentPage({
    required WaveformChannel channel,
    required Waveform waveform,
    required List<FavoriteSlot> favoriteSlots,
  }) async {
    final repo = ref.read(controllerRepositoryProvider);
    final channelSlots = favoriteSlots.where((slot) => slot.channel == channel);
    final currentPageIndex = _selectedCommonPageIndices[_selectedChannelIndex];
    final totalCount = channelSlots.length;
    if (totalCount >= 12) {
      OmaoToast.show(context, '常用波形最多只能配置12个', isSuccess: false);
      return;
    }

    final currentPageSlots = channelSlots
        .where((slot) => slot.page == currentPageIndex)
        .toList();
    if (currentPageSlots.length >= 4) {
      OmaoToast.show(context, '当前页最多只能配置4个波形', isSuccess: false);
      return;
    }

    await repo.setFavoriteSlot(
      FavoriteSlot(
        channel: channel,
        page: currentPageIndex,
        index: currentPageSlots.length,
        waveformId: waveform.id,
      ),
    );
    ref.invalidate(favoriteSlotsProvider);
  }

  Future<void> _removeCurrentPageSlot({
    required WaveformChannel channel,
    required int pageIndex,
    required int itemIndex,
    required List<FavoriteSlot> favoriteSlots,
  }) async {
    final channelSlots = favoriteSlots.where((slot) => slot.channel == channel);
    if (channelSlots.length <= 1) {
      OmaoToast.show(context, '常用波形至少保留1个', isSuccess: false);
      return;
    }

    final repo = ref.read(controllerRepositoryProvider);
    await repo.removeFavoriteSlot(
      channel: channel,
      page: pageIndex,
      index: itemIndex,
    );
    ref.invalidate(favoriteSlotsProvider);
  }

  Future<void> _openCustomWaveformEditor(Waveform waveform) async {
    await _openNewWaveformScreen(
      initialName: waveform.name,
      channel: waveform.channel,
      existingWaveform: waveform,
    );
  }

  Future<void> _showNewWaveformDialog() async {
    final waveformName = await NewWaveformDialog.show(context);
    if (!mounted || waveformName == null) {
      return;
    }

    await _openNewWaveformScreen(
      initialName: waveformName,
      channel: _selectedChannelIndex == 0
          ? WaveformChannel.swing
          : WaveformChannel.vibration,
    );
  }

  Future<void> _openNewWaveformScreen({
    required String initialName,
    required WaveformChannel channel,
    Waveform? existingWaveform,
  }) async {
    // await context.pushNamed(
    //   RouteNames.newWaveform,
    //   extra: {
    //     'initialName': initialName,
    //     'channel': channel.name,
    //     if (existingWaveform != null) 'existingWaveform': existingWaveform,
    //   },
    // );
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
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
