# 架构说明

## 总体方向

项目主线采用 PWA 静态网页应用。服务器只负责分发静态文件，所有设计计算、预览、保存和导出都在浏览器本地完成。

## 模块划分

- `profiles`：型材规格库，包含规格、槽宽、价格等。
- `connectors`：连接规则，包含扣减逻辑和配件数量。
- `calculator`：根据项目参数生成构件和 BOM。
- `preview`：Canvas 轴测预览。
- `storage`：localStorage 本地项目保存。
- `exporters`：JSON 项目导入导出、CSV BOM 导出。
- `ui`：手机优先的设计、预览、清单、项目页面。

## 数据流

```text
用户输入参数
  -> FrameProject
  -> Calculator
  -> Members + BOM
  -> Preview / BOM Table / Export
```

## 设计边界

第一版只处理矩形框架和水平层架。计算逻辑必须独立于 UI，避免后续改界面时影响 BOM 准确性。
