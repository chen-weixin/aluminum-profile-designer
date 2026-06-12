import assert from "node:assert/strict";
import test from "node:test";

import { calculateFrame, defaultProject } from "../pwa/js/calculator.js";
import { decodeProject, encodeProject, exportBomCsv } from "../pwa/js/exporters.js";

test("project JSON round trips user dimensions and selections", () => {
  const project = {
    ...defaultProject(),
    id: "p1",
    name: "测试框架",
    lengthMm: 1500,
    widthMm: 700,
    heightMm: 900,
    shelfLevels: 4,
    profileCode: "4040",
    connectorCode: "end_fastener"
  };

  const decoded = decodeProject(encodeProject(project));

  assert.equal(decoded.name, "测试框架");
  assert.equal(decoded.lengthMm, 1500);
  assert.equal(decoded.profileCode, "4040");
  assert.equal(decoded.connectorCode, "end_fastener");
});

test("BOM CSV includes header, profile rows, hardware rows, and total", () => {
  const design = calculateFrame(defaultProject());

  const csv = exportBomCsv(design);

  assert.match(csv, /类型,编码,名称,长度mm,数量,单位,单价,小计/);
  assert.match(csv, /型材,3030/);
  assert.match(csv, /连接件,corner_bracket/);
  assert.match(csv, /紧固件,m6_socket_bolt/);
  assert.match(csv, /合计/);
});

test("CSV exporter escapes commas and quotes", () => {
  const design = {
    totalPrice: 12,
    bom: [
      {
        kind: "profile",
        code: "x",
        name: '测试, "特殊" 型材',
        lengthMm: 100,
        quantity: 1,
        unit: "根",
        unitPrice: 12,
        totalPrice: 12
      }
    ]
  };

  const csv = exportBomCsv(design);

  assert.match(csv, /"测试, ""特殊"" 型材"/);
});
