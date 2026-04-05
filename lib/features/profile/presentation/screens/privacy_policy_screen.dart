import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/omao_page_background.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OmaoPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('隐私政策'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Text(
            _policyText,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

const _policyText = '''
一、协议的接受与变更

1、请您在使用App服务或注册成为用户前充分阅读并理解本协议，当您开始使用App薰踏务或注册成为App用户时，即视为您签署了本协议，表明您自愿接受本协议项下全部条款的约束。

2、公司有权根据国家法律法规变化、更新App新功能之需要，不时地对本协议进行修改、更新，更新后的协议条款将在App相关页面予以公布，修改或更新后的协议一经公布立即生效并代替原协议条款，用户可在App中查阅最新条款。若您不接受修改后的条款，请立即停止访问或使用App并取消或注销已获取的服务。若您选择本协议修改后继续访问或使用App的，则视为您已接受并自愿遵守修改后的协议。

3、您与公司签署的本协议所列明的相关条款，并不能完全涵盖您与理想公司所有的权利与繁然务。因此，公司发布的其他各类规则等均视为本协议之补充协议，为本协议不可分割的组成部分，与本协议具有同等法律效力。

二、服务的内容与方式

1、App是一个内容获取、分享及传播的平台，为广大用户提供音视频点播、文稿阅读等多方面的服务。App未来将上线更多新功能及服务罗，除非另有明确规定定外，未来上线的新功能及新服务也适用于本协议。

2、公司有权根据国家法律法规变化、更新App新功能之需要，不时地对本协议进行修改、更新。
''';
