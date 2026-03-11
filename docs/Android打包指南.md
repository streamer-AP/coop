# Android APK 打包指南

## 前置要求

### 1. 安装 Android Studio

下载地址：https://developer.android.com/studio

安装后会自动配置 Android SDK。

### 2. 配置环境变量

在 `~/.zshrc` 或 `~/.bash_profile` 添加：

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

然后执行：
```bash
source ~/.zshrc
```

### 3. 验证安装

```bash
flutter doctor
```

应该显示 Android toolchain 已安装。

---

## 快速打包

### Debug APK（用于测试）

```bash
# 构建 Debug APK
flutter build apk --debug

# 生成位置
# build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK（需要签名）

```bash
# 构建 Release APK
flutter build apk --release

# 按架构分包（推荐，体积更小）
flutter build apk --split-per-abi
```

---

## 安装到设备

### 方法 1: 使用 Flutter 命令

```bash
# 连接设备后
flutter install

# 或指定设备
flutter devices
flutter install -d <device-id>
```

### 方法 2: 使用 ADB

```bash
# 安装 APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# 如果已安装，覆盖安装
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### 方法 3: 手动安装

将 APK 文件传输到手机，直接点击安装。

---

## Release 签名配置

Release 版本需要签名才能发布。

### 1. 生成密钥库

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

按提示输入密码和信息。

### 2. 创建签名配置文件

创建 `android/key.properties`：

```properties
storePassword=你的密码
keyPassword=你的密码
keyAlias=upload
storeFile=/Users/yan/upload-keystore.jks
```

**重要**: 将 `key.properties` 添加到 `.gitignore`，不要提交到 Git！

### 3. 配置 Gradle

编辑 `android/app/build.gradle.kts`，在 `android {` 之前添加：

```kotlin
// 加载签名配置
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

在 `android { ... }` 内添加：

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

### 4. 构建签名 APK

```bash
flutter build apk --release
```

---

## 体积优化

### 1. 按架构分包

```bash
flutter build apk --split-per-abi
```

会生成 3 个 APK：
- `app-armeabi-v7a-release.apk` (32位 ARM，老设备)
- `app-arm64-v8a-release.apk` (64位 ARM，主流设备)
- `app-x86_64-release.apk` (模拟器)

### 2. 启用代码混淆

编辑 `android/app/build.gradle.kts`：

```kotlin
buildTypes {
    getByName("release") {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

创建 `android/app/proguard-rules.pro`：

```
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
```

---

## 常见问题

### 1. 找不到 Android SDK

```bash
# 检查 ANDROID_HOME
echo $ANDROID_HOME

# 如果为空，配置环境变量
export ANDROID_HOME=$HOME/Library/Android/sdk
```

### 2. Gradle 构建失败

```bash
# 清理缓存
cd android
./gradlew clean

# 重新构建
cd ..
flutter build apk --debug
```

### 3. 查看 APK 信息

```bash
# 查看 APK 大小
ls -lh build/app/outputs/flutter-apk/

# 查看 APK 包名
aapt dump badging build/app/outputs/flutter-apk/app-debug.apk | grep package
```

### 4. 安装失败

```bash
# 卸载旧版本
adb uninstall com.example.omao_app

# 重新安装
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## 当前项目状态

✅ 已生成原生平台代码
✅ 已配置 Android 权限（音乐库、蓝牙、后台播放）
✅ 已配置 iOS 权限

⚠️ 需要安装 Android SDK 才能构建 APK

---

## 下一步

1. 安装 Android Studio
2. 运行 `flutter doctor` 验证环境
3. 执行 `flutter build apk --debug` 构建 APK
4. 使用 `adb install` 或手动安装到设备测试
