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
| 本地存储 | shared_preferences |

## 功能模块

| 模块 | 说明 | 状态 |
|------|------|------|
| 登录/注册 | 验证码登录、密码登录、注册、忘记密码、密码设置 | 已完成 |
| 实名认证 | 身份证+姓名认证，年龄校验，认证守卫拦截 | 已完成 |
| 主页导航 | 3-Tab（主页/消息/我的），自定义深色胶囊 TabBar | 已完成 |
| 消息 | 消息列表、详情、全部已读、未读红点 | 已完成 |
| 个人中心 | 头像/昵称编辑、账号安全、修改密码、修改手机号、建议反馈、联系我们、协议、注销 | 已完成 |
| 共鸣播放器 | 音频列表/合集、播放器（封面/字幕/进度/控制）、MiniPlayerBar、导入/导出 | 已完成 |
| 控制器 | 波形编辑/预设/常用槽位 | 骨架 |
| 剧情 | 故事场景/检查点/Unity 交互 | 骨架 |
| 蓝牙 | BLE 连接/信号发送/仲裁 | 骨架 |

## 项目结构

```
lib/
├── main.dart                  # 入口
├── app.dart                   # MaterialApp.router
├── core/                      # 公共基础设施
│   ├── bluetooth/             # BLE 连接/发信/仲裁
│   ├── database/              # drift 数据库/表/DAO
│   ├── network/               # dio + 拦截器 + token 自动附加
│   ├── platform/              # 原生桥接 & Unity 通信
│   ├── router/                # 路由 + auth guard + 公开路由白名单
│   ├── theme/                 # 主题/颜色/字体/渐变
│   ├── crypto/                # AES-256-GCM 解密
│   ├── logging/               # 日志
│   ├── storage/               # 文件管理 + token 持久化
│   └── utils/
├── features/                  # 功能域模块
│   ├── auth/                  # 登录/注册/实名认证/验证码
│   ├── permission/            # 权限码/设备绑定
│   ├── resonance/             # 共鸣播放器/合集/字幕/导入导出
│   ├── controller/            # 波形控制/编辑
│   ├── story/                 # 剧情/Unity 中转/回忆
│   ├── home/                  # 主页导航
│   ├── message/               # 消息通知
│   └── profile/               # 个人中心
└── shared/                    # 共享 UI 组件
    └── widgets/               # TabBar/按钮/验证码输入/PIN码/Toast
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
- JDK 17（Android 构建需要，JDK 25 不兼容 AGP 8.11）
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

# 构建 APK（需指定 JDK 17）
JAVA_HOME=/path/to/jdk17 flutter build apk --debug

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

## API 对接

- 认证接口：登录/注册/验证码/密码重置 → `AuthRepositoryImpl`
- 实名认证：`POST /userAccounts/realNameVerify` → `VerificationGuard`
- 用户信息：`GET /auth/getCurrentUserInfo` → token 自动恢复登录态
- Token 管理：`AuthInterceptor` 自动附加 Bearer token，401 自动清除

接口文档：[Apifox](https://app.apifox.com/project/7391709)

## 文档

- [技术架构决策](docs/技术架构决策.md)
- [APP 接口](docs/APP接口.md)
- [实名认证接口](docs/实名认证接口更新，关于未成年后认证的处理.md)
- [需求文档](需求文档/)
