# OMAO v2 - Claude Code 项目指南

## 项目概述

Flutter 蓝牙硬件配套 APP，包含 Live2D 角色交互（Unity）、音频播放（共鸣）、蓝牙设备控制。

## 关键命令

```bash
flutter pub get                                          # 安装依赖
dart run build_runner build --delete-conflicting-outputs  # 代码生成
flutter analyze                                          # 静态分析
flutter test                                             # 运行测试
```

## 架构规范

- **分层**: core/ (基础设施) → features/ (功能域) → shared/ (共享 UI)
- **Feature 内部**: data/ → domain/ → application/ → presentation/
- **domain/ 零外部依赖**: 仅纯 Dart 模型 + Repository 抽象接口
- **状态管理**: Riverpod + riverpod_generator（`@riverpod` / `@Riverpod` 注解）
- **keepAlive providers**: appDatabase, dio, auth, bleConnectionManager, bleSignalArbitrator, unityBridge, permission
- **autoDispose providers**: player, playlist, subtitle, waveformEditor, storyProgress, collectionDetail, profile
- **数据库**: 单 drift 数据库，DAO 按功能域分拆

## 代码风格

- 使用单引号
- 必须加尾逗号（trailing commas）
- 使用 const 构造函数
- 禁止 print（使用 AppLogger）
- 生成文件（*.g.dart, *.freezed.dart）不提交到 git

## 蓝牙信号优先级

story（剧情）> resonance（同步共鸣）> preset（预设波形）

## 重要文档

- 技术架构决策: docs/技术架构决策.md
- 需求文档: 需求文档/

## UI 还原方法论（Figma → Flutter）

### 流程

1. **获取 Figma 设计** — 使用 `get_design_context` 或 `get_screenshot` 工具获取目标节点的截图和代码
2. **提取关键参数** — 从 Figma 生成的 React+Tailwind 代码中提取：颜色值、渐变、字体大小/粗细、间距、圆角、透明度、布局结构
3. **对比当前实现** — 截图对比 Figma 设计与真机效果，定位差异
4. **逐项修改** — 按 Figma 参数逐个修正 Flutter 代码中的常量值

### 常见陷阱

- **渐变方向/颜色**：Figma 的 `from-[#xxx] to-[#yyy]` 注意方向（topCenter、centerLeft 等），不要凭感觉写
- **透明度**：Figma 中 `rgba(234,234,234,0.3)` 不是纯白，要用 `Color(0xFFEAEAEA).withValues(alpha: 0.3)`
- **浮层布局**：MiniPlayer 等常驻底部组件应用 `Stack` + `Positioned` 浮在列表上方，不要放在 `Column` 中占位
- **光效/纹理范围**：Figma 中的渐变和光效通常只覆盖屏幕顶部一小部分（150~200px），不要全屏铺开
- **ref 生命周期**：BottomSheet/ActionSheet 中 `Navigator.pop()` 后 `ConsumerWidget` 的 ref 立即失效。必须在 pop 前读出所有 provider 值，传参给后续 dialog
- **外键清理**：drift 数据库 `PRAGMA foreign_keys = ON` 时，删除父表记录前必须先删所有子表引用（subtitles、signalFiles、scriptFiles、crossRef、playlistItems）

### ADB 真机测试

- 小米/HyperOS 设备需开启「USB调试（安全设置）」才能用 `adb shell input tap`
- 某些设备即使开启也无法注入触控事件，需改用手动测试 + ADB 截图验证
- `adb exec-out screencap -p > file.png` 截图
- `adb logcat -s flutter` 查看 Flutter 错误日志
- `FilePicker` 在 Android 上会将文件复制到 cache 目录，同目录判断不能依赖 `dirname` 相等
