# 铝合金型材 DIY 设计器

一个轻量的铝合金型材 DIY 设计工具，面向手机、平板和电脑浏览器。第一版采用 **PWA 静态网页应用**：不需要后端、不需要数据库、不需要安装 Flutter 或 Android Studio。

在线部署后，用户可以在浏览器里输入框架尺寸、型材规格和连接方式，查看轴测预览，并导出下料清单和 BOM。

## 当前可用功能

- 支持 `2020`、`3030`、`4040` 型材。
- 支持矩形框架和水平层架。
- 支持外置角码、内置连接件、端面连接件。
- 自动生成型材下料、连接件、螺丝和基础成本估算。
- Canvas 轴测预览，点按可查看构件。
- 项目保存到浏览器本地。
- 支持项目 JSON 导入/导出。
- 支持 BOM CSV 导出。
- 支持 PWA manifest 和 service worker 离线缓存。

## 本地运行

项目不需要安装依赖。需要本机有 Python 或其他静态服务器。

Windows 下可以直接双击：

```text
start-pwa.bat
```

脚本会启动本地服务并自动打开浏览器。

也可以手动运行：

```powershell
python -m http.server 4173 -d pwa
```

然后打开：

```text
http://localhost:4173
```

## 测试

测试使用 Node.js 内置测试运行器，不需要下载第三方包。

```powershell
npm test
```

## 部署

部署 `pwa/` 目录即可。可用平台包括：

- GitHub Pages
- Cloudflare Pages
- Vercel
- Netlify
- Nginx 静态站点
- 阿里云 OSS / 腾讯云 COS 静态网站

正式使用建议开启 HTTPS，因为 PWA 安装和 service worker 离线缓存通常需要安全来源。

## 目录

- `pwa/`：可部署的 PWA 静态应用。
- `pwa/js/calculator.js`：框架生成、扣减规则、BOM 汇总。
- `pwa/js/exporters.js`：JSON 和 CSV 导出。
- `pwa/js/storage.js`：浏览器本地项目保存。
- `pwa/js/preview.js`：Canvas 轴测预览。
- `test/*.test.mjs`：PWA 核心逻辑测试。
- `lib/`：早期 Flutter 原型，仅作为业务逻辑参考。

## 暂不支持

- 自由 CAD 建模。
- 斜撑和异形角度。
- 板材、台面、门板计算。
- 开孔加工图。
- 账号、云同步、多人协作。

## 开源协议

MIT License。详见 [LICENSE](LICENSE)。
