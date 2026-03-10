# OMAO v2

蓝牙硬件设备配套 APP，核心功能围绕 Live2D 角色交互、音频播放（共鸣）、蓝牙设备控制三大模块展开。

## 技术栈

| 层面 | 选型 |
|------|------|
| 主框架 | Flutter 3.41+ |
| Live2D 渲染 | Unity（原生容器切换） |
| 状态管理 | Riverpod + riverpod_generator |
| 本地数据库 | SQLite + drift |
| 音频引擎 | just_audio + audio_service |
| 蓝牙 | flutter_blue_plus |
| 网络 | dio |
| 路由 | go_router |

## 项目结构

```
lib/
├── main.dart                  # 入口
├── app.dart                   # MaterialApp.router
├── core/                      # 公共基础设施
│   ├── bluetooth/             # BLE 连接/发信/仲裁
│   ├── database/              # drift 数据库/表/DAO
│   ├── network/               # dio + 拦截器
│   ├── platform/              # 原生桥接 & Unity 通信
│   ├── router/                # 路由 + 权限守卫
│   ├── theme/                 # 主题/颜色/字体
│   ├── crypto/                # AES 解密
│   ├── logging/               # 日志
│   ├── storage/               # 文件/缓存/下载
│   └── utils/
├── features/                  # 功能域模块
│   ├── auth/                  # 登录/注册/实名认证
│   ├── permission/            # 权限码/设备绑定
│   ├── resonance/             # 共鸣播放器/合集/字幕
│   ├── controller/            # 波形控制/编辑
│   ├── story/                 # 剧情/Unity 中转/回忆
│   ├── home/                  # 主页导航
│   └── profile/               # 个人中心
└── shared/                    # 共享 UI 组件
```

每个 feature 内部分层：

```
feature/
├── data/                      # Repository 实现
├── domain/                    # 模型 + Repository 抽象接口
├── application/               # 业务逻辑 + Riverpod providers
└── presentation/              # 页面 + 组件
```

## 开发环境

- Flutter >= 3.41.0
- Dart >= 3.11.0
- Android 10+ / iOS 15+

## 快速开始

```bash
# 安装依赖
flutter pub get

# 代码生成（freezed / drift / riverpod_generator）
dart run build_runner build --delete-conflicting-outputs

# 静态分析
flutter analyze

# 运行测试
flutter test

# 运行应用
flutter run
```

## 代码生成

项目使用 `build_runner` 生成以下代码：

- **freezed** — 不可变模型类（`*.freezed.dart`）
- **json_serializable** — JSON 序列化（`*.g.dart`）
- **drift** — 数据库表/DAO（`*.g.dart`）
- **riverpod_generator** — Provider 声明（`*.g.dart`）

生成文件已加入 `.gitignore`，clone 后需执行 `dart run build_runner build`。

## 文档

- [技术架构决策](docs/技术架构决策.md)
