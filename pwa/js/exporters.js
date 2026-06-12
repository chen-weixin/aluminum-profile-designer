import { normalizeProject } from "./calculator.js";

export function encodeProject(project) {
  return JSON.stringify(normalizeProject(project), null, 2);
}

export function decodeProject(source) {
  let parsed;
  try {
    parsed = JSON.parse(source);
  } catch (error) {
    throw new Error("项目 JSON 格式不正确");
  }

  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("项目 JSON 必须是对象");
  }

  return normalizeProject(parsed);
}

export function exportBomCsv(design) {
  const rows = [
    ["类型", "编码", "名称", "长度mm", "数量", "单位", "单价", "小计"],
    ...design.bom.map((item) => [
      kindLabel(item.kind),
      item.code,
      item.name,
      item.lengthMm == null ? "" : String(item.lengthMm),
      String(item.quantity),
      item.unit,
      item.unitPrice.toFixed(2),
      item.totalPrice.toFixed(2)
    ]),
    ["", "", "", "", "", "", "合计", design.totalPrice.toFixed(2)]
  ];

  return rows.map((row) => row.map(escapeCsv).join(",")).join("\n");
}

export function downloadTextFile(filename, content, mimeType = "text/plain;charset=utf-8") {
  const blob = new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
}

function kindLabel(kind) {
  if (kind === "profile") return "型材";
  if (kind === "connector") return "连接件";
  if (kind === "fastener") return "紧固件";
  return kind;
}

function escapeCsv(value) {
  if (!/[",\n]/.test(value)) {
    return value;
  }
  return `"${value.replaceAll('"', '""')}"`;
}
