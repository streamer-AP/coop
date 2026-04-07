import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_page_background.dart';
import '../../application/providers/profile_providers.dart';
import '../widgets/avatar_picker_sheet.dart';
import '../widgets/glowing_avatar.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _nicknameController;
  static const _maxLength = 8;
  bool _didSeedNicknameFromProfile = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    if (profile != null) {
      _nicknameController.text = _normalizeNickname(profile.nickname);
      _didSeedNicknameFromProfile = true;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final loadedNickname = _normalizeNickname(
      profileAsync.valueOrNull?.nickname,
    );
    if (!_didSeedNicknameFromProfile && loadedNickname.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didSeedNicknameFromProfile) {
          return;
        }
        _nicknameController.value = TextEditingValue(
          text: loadedNickname,
          selection: TextSelection.collapsed(offset: loadedNickname.length),
        );
        _didSeedNicknameFromProfile = true;
      });
    }

    return OmaoPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcons.icon(
                      AppIcons.arrowLeft,
                      size: 20,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ),
          ),
          leadingWidth: 56,
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                '保存',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => _showAvatarPicker(context),
                child: Column(
                  children: [
                    GlowingAvatar(
                      imageUrl: profileAsync.valueOrNull?.avatarUrl,
                      size: 96,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '编辑头像',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '用户名',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                maxLength: _maxLength,
                decoration: InputDecoration(
                  counterText: '',
                  suffixText: '${_nicknameController.text.length}/$_maxLength',
                  suffixStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    final currentNickname = _normalizeNickname(
      ref.read(profileNotifierProvider).valueOrNull?.nickname,
    );
    if (nickname.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    if (nickname == currentNickname) {
      Navigator.of(context).pop();
      return;
    }
    try {
      await ref.read(profileNotifierProvider.notifier).updateNickname(nickname);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? '用户名更新失败' : message)),
      );
    }
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => AvatarPickerSheet(
            onGallerySelected: () => _pickImage(ImageSource.gallery),
            onCameraSelected: () => _pickImage(ImageSource.camera),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      try {
        await ref
            .read(profileNotifierProvider.notifier)
            .updateAvatar(image.path);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('头像更新成功')));
      } catch (e) {
        if (!mounted) return;
        final message = '$e'.replaceFirst('Exception: ', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.isEmpty ? '头像更新失败' : message)),
        );
      }
    }
  }

  String _normalizeNickname(String? nickname) {
    return nickname?.trim() ?? '';
  }
}
