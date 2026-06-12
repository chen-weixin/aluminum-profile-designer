# 铝合金型材 DIY 设计器

一个面向铝合金型材 DIY 用户的开源设计工具。目标是让用户在手机、平板或电脑上快速设计常见框架、层架、柜架和设备机架，并自动生成下料清单和 BOM。

项目当前准备从 Flutter 原生 App 方案调整为 **PWA 优先**：先做成可部署到网上的静态网页应用，降低开发、部署和使用门槛。后续效果验证稳定后，再考虑封装成 Android APK 或 iOS App。

## 为什么改成 PWA

- 不需要安装 Flutter、Android Studio、Java 等大型工具链。
- 服务器要求很低，只需要静态网页托管。
- 手机浏览器可以添加到主屏幕，接近 App 使用体验。
- 计算、预览、保存和导出都在浏览器本地完成。
- 后续可以平滑部署到 GitHub Pages、Cloudflare Pages、Vercel、Netlify 或普通 Nginx 静态站点。

## 第一版目标

- 支持 `2020`、`3030`、`4040` 常见型材规格。
- 支持矩形框架、层架、柜架、设备机架等常见结构。
- 输入长、宽、高、层数、型材规格和连接方式后自动生成结构。
- 提供轻量 3D/轴测预览，优先保证手机上流畅可用。
- 自动生成型材下料清单、连接件、螺丝和基础成本估算。
- 支持项目本地保存、JSON 导入导出和 CSV BOM 导出。
- 支持 PWA 安装和离线缓存。

## 当前仓库状态

仓库里已有一版 Flutter 原型源码，包含核心数据模型、框架计算、BOM 汇总和测试用例。但由于本机不适合安装大型移动端工具链，后续主线建议迁移到 `pwa/` 静态网页应用。

现有 Flutter 原型可作为业务逻辑参考：

- `lib/src/models.dart`：项目、型材、连接件、构件、BOM 数据模型。
- `lib/src/frame_calculator.dart`：框架生成、扣减规则、BOM 汇总。
- `lib/src/exporters.dart`：项目 JSON 与 BOM CSV 导出。
- `test/`：核心计算和导出测试。

## 推荐目录规划

```text
pwa/
  index.html
  styles.css
  app.js
  manifest.json
  service-worker.js
docs/
  ARCHITECTURE.md
  DEPLOYMENT.md
  ROADMAP.md
```

## 部署方式

PWA 版本完成后，只需要部署 `pwa/` 里的静态文件即可。

可选平台：

- GitHub Pages
- Cloudflare Pages
- Vercel
- Netlify
- Nginx 静态站点
- 阿里云 OSS / 腾讯云 COS 静态网站

正式使用建议启用 HTTPS，因为 PWA 安装和离线缓存通常需要安全来源。

## 开源协议

本项目计划使用 MIT License，方便个人、商业和二次开发使用。详见 [LICENSE](LICENSE)。
