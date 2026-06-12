# 运行与构建说明

当前主线是 PWA 静态网页应用，不需要 Flutter、Android Studio、Java 或 Android SDK。

## 本地运行

Windows 下可以双击项目根目录的：

```text
start-pwa.bat
```

脚本会自动选择端口、启动本地服务并打开浏览器。

手动运行方式：

```powershell
python -m http.server 4173 -d pwa
```

访问：

```text
http://localhost:4173
```

## 测试

```powershell
npm test
```

## 部署

直接部署 `pwa/` 目录即可。构建命令可以留空，输出目录设置为：

```text
pwa
```

## 关于 Flutter 原型

仓库中的 `lib/` 和旧 `test/*.dart` 是早期 Flutter 原型参考代码。当前 PWA 版本已经不依赖 Flutter 工具链。
