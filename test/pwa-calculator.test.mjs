import assert from "node:assert/strict";
import test from "node:test";

import { calculateFrame, defaultProject } from "../pwa/js/calculator.js";

test("two shelf levels generate four posts and eight rails", () => {
  const design = calculateFrame({
    ...defaultProject(),
    lengthMm: 1200,
    widthMm: 600,
    heightMm: 800,
    shelfLevels: 2,
    profileCode: "3030",
    connectorCode: "corner_bracket"
  });

  assert.equal(design.members.filter((member) => member.axis === "z").length, 4);
  assert.equal(design.members.filter((member) => member.axis === "x").length, 4);
  assert.equal(design.members.filter((member) => member.axis === "y").length, 4);
  assert.equal(design.members.length, 12);
});

test("three shelf levels generate four posts and twelve rails", () => {
  const design = calculateFrame({
    ...defaultProject(),
    shelfLevels: 3
  });

  assert.equal(design.members.filter((member) => member.axis === "z").length, 4);
  assert.equal(design.members.filter((member) => member.axis !== "z").length, 12);
  assert.equal(design.members.length, 16);
});

test("end fastener shortens rails by two profile widths", () => {
  const design = calculateFrame({
    ...defaultProject(),
    lengthMm: 1000,
    widthMm: 500,
    heightMm: 700,
    profileCode: "4040",
    connectorCode: "end_fastener"
  });
  const xRail = design.members.find((member) => member.axis === "x");
  const yRail = design.members.find((member) => member.axis === "y");

  assert.equal(xRail.cutLengthMm, 920);
  assert.equal(yRail.cutLengthMm, 420);
});

test("BOM groups profile lengths and connection hardware", () => {
  const design = calculateFrame({
    ...defaultProject(),
    lengthMm: 1200,
    widthMm: 600,
    heightMm: 800,
    shelfLevels: 3,
    profileCode: "3030",
    connectorCode: "inside_connector"
  });

  const profileItems = design.bom.filter((item) => item.kind === "profile");
  const connector = design.bom.find((item) => item.code === "inside_connector");
  const bolt = design.bom.find((item) => item.code === "m6_socket_bolt");

  assert.equal(profileItems.length, 3);
  assert.equal(connector.quantity, 24);
  assert.equal(bolt.quantity, 48);
  assert.ok(design.totalPrice > 0);
});
