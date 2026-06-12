# 构建与发布说明

## Windows 构建 Android

1. 安装 Flutter SDK。
2. 安装 Android Studio 或 Android command-line tools。
3. 安装 JDK。
4. 执行：

```powershell
flutter doctor
flutter pub get
flutter test
flutter build apk --release
```

APK 输出路径通常是：

```text
build/app/outputs/flutter-apk/app-release.apk
```

## iOS 源码与打包

本项目是一套 Flutter 源码，iOS 工程需要在 macOS 上用 Flutter 生成或维护。

```bash
flutter create --platforms=ios .
flutter pub get
flutter build ios --release
```

真机安装和上架需要 Apple Developer 账号、Bundle ID、签名证书和描述文件。

## 如果当前目录缺少 `android/` 或 `ios/`

由于当前 Windows 环境没有 Flutter SDK，本次无法通过 `flutter create` 自动生成平台目录。安装 Flutter 后，在项目根目录执行：

```powershell
flutter create --platforms=android,ios .
```

这个命令会补齐 Android/iOS 原生壳工程，并保留现有 `lib/`、`test/`、`pubspec.yaml`。
