# 架构说明

## 总体方向

项目主线采用 PWA 静态网页应用。服务器只负责分发静态文件，所有设计计算、预览、保存和导出都在浏览器本地完成。

## 模块划分

- `pwa/index.html`：移动端应用结构，包含设计、3D、清单、项目四个页面。
- `pwa/styles.css`：手机优先的界面样式。
- `pwa/js/catalog.js`：型材规格和连接件规则。
- `pwa/js/calculator.js`：根据项目参数生成构件和 BOM。
- `pwa/js/exporters.js`：项目 JSON 和 BOM CSV 导出。
- `pwa/js/storage.js`：localStorage 本地项目保存。
- `pwa/js/preview.js`：Canvas 轴测预览。
- `pwa/js/app.js`：UI 状态、表单绑定、页面渲染和用户操作。

## 数据流

```text
用户输入参数
  -> FrameProject
  -> calculateFrame()
  -> Members + BOM
  -> Preview / BOM Table / Export / Storage
```

## 设计边界

第一版只处理矩形框架和水平层架。计算逻辑独立于 UI，后续可以在不改界面的情况下增加更多型材、连接件和算料规则。
