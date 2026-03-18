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
