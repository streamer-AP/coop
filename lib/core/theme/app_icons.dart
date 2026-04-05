import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized SVG icon paths from `assets/figma/icons/`.
class AppIcons {
  AppIcons._();

  static const _base = 'assets/figma/icons';

  // Navigation
  static const arrowLeft = '$_base/arrow-left.svg';
  static const arrowRight = '$_base/arrow-right.svg';

  // Actions
  static const more = '$_base/more.svg';
  static const more1 = '$_base/more-1.svg';
  static const close = '$_base/close.svg';
  static const close2 = '$_base/close2.svg';
  static const search01 = '$_base/search-01.svg';
  static const arrowRotateLeft01 = '$_base/arrow-rotate-left-01.svg';

  // Player controls
  static const skipBack = '$_base/skip-back.svg';
  static const skipForward = '$_base/skip-forward.svg';
  static const play = '$_base/play.svg';
  static const pause = '$_base/pause.svg';
  static const play2 = '$_base/play2.svg';
  static const shuffle = '$_base/shuffle.svg';
  static const refresh1 = '$_base/refresh-1.svg';
  static const refresh2 = '$_base/refresh-2.svg';
  static const playlist = '$_base/Playlist.svg';
  static const note = '$_base/note.svg';

  // Sort
  static const sort = '$_base/排序.svg';
  static const sortUp = '$_base/升序排序_sort-amount-up-1.svg';
  static const sortDown = '$_base/降序排序_sort-amount-down-1.svg';
  static const sortAlphaAZ = '$_base/字母顺序_alphabetical-sorting-1.svg';
  static const sortAlphaZA = '$_base/字母倒序_alphabetical-sorting-two-1.svg';

  // Add / Remove / Edit
  static const add = '$_base/添加.svg';
  static const add1 = '$_base/添加-1.svg';
  static const add2 = '$_base/添加-2.svg';
  static const add3 = '$_base/添加-3.svg';
  static const delete = '$_base/删除按钮.svg';
  static const rename = '$_base/重命名.svg';
  static const edit = '$_base/编辑.svg';

  // Import / Export
  static const importIcon = '$_base/导入.svg';
  static const exportIcon = '$_base/导出.svg';
  static const changeCover = '$_base/修改封面.svg';

  // Media
  static const subtitle = '$_base/字幕.svg';
  static const translate = '$_base/翻译.svg';
  static const file = '$_base/文件.svg';
  static const archive = '$_base/压缩包.svg';

  // Device controls
  static const settings = '$_base/设置.svg';
  static const swing = '$_base/摇摆.svg';
  static const vibration = '$_base/震动.svg';
  static const deviceLink = '$_base/验证激活.svg';
  static const linkBroken = '$_base/Frame-427320904.svg';
  static const tripleArrowRight = '$_base/Frame-427320905.svg';
  static const switchPreset = '$_base/switch-preset.svg';

  // Profile
  static const album = '$_base/相册.svg';
  static const camera = '$_base/相机.svg';
  static const user = '$_base/user.svg';
  static const accountSecurity = '$_base/账号安全.svg';
  static const iphone = '$_base/iphone.svg';
  static const lock = '$_base/lock.svg';
  static const logout = '$_base/logout.svg';
  static const phoneCall = '$_base/phone-call.svg';
  static const send01 = '$_base/send-01.svg';
  static const infoCircle = '$_base/information-circle-contained.svg';
  static const fileEdit = '$_base/file-edit.svg';
  static const fileEye = '$_base/file-eye.svg';
  static const notificationSquare = '$_base/notification-square-02.svg';
  static const box = '$_base/box.svg';

  // Check / Status
  static const check = '$_base/选中.svg';
  static const success = '$_base/成功.svg';
  static const fail = '$_base/失败.svg';
  static const circleCheck = '$_base/circle-选中.svg';
  static const circleUnchecked = '$_base/circle-未选中.svg';
  static const circleAdded = '$_base/circle-已被添加.svg';

  /// Helper to build an [SvgPicture.asset] with common defaults.
  static Widget icon(String assetPath, {double? size, Color? color}) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Helper to render exported SVG assets with their original colors.
  static Widget asset(
    String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(assetPath, width: width, height: height, fit: fit);
  }
}
