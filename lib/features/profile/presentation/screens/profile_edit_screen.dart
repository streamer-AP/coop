import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    if (profile != null) {
      _nicknameController.text = profile.nickname ?? '';
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

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.profileBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                '保存',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
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
                  suffixText:
                      '${_nicknameController.text.length}/$_maxLength',
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

  void _save() {
    final nickname = _nicknameController.text.trim();
    if (nickname.isNotEmpty) {
      ref.read(profileNotifierProvider.notifier).updateNickname(nickname);
    }
    Navigator.of(context).pop();
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AvatarPickerSheet(
        onGallerySelected: () {
          // TODO: implement image picker
        },
        onCameraSelected: () {
          // TODO: implement camera
        },
      ),
    );
  }
}
