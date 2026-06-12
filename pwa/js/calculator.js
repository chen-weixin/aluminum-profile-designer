import { CONNECTOR_RULES, PROFILE_SPECS } from "./catalog.js";

export function defaultProject() {
  return {
    id: "default",
    name: "我的型材框架",
    templateKind: "rectangularRack",
    lengthMm: 1200,
    widthMm: 600,
    heightMm: 800,
    shelfLevels: 2,
    profileCode: "3030",
    connectorCode: "corner_bracket"
  };
}

export function normalizeProject(project = {}) {
  const base = defaultProject();
  return {
    ...base,
    ...project,
    id: String(project.id || base.id),
    name: String(project.name || base.name),
    lengthMm: clampInteger(project.lengthMm ?? base.lengthMm, 200, 6000),
    widthMm: clampInteger(project.widthMm ?? base.widthMm, 200, 3000),
    heightMm: clampInteger(project.heightMm ?? base.heightMm, 200, 3000),
    shelfLevels: clampInteger(project.shelfLevels ?? base.shelfLevels, 2, 8),
    profileCode: PROFILE_SPECS[project.profileCode] ? project.profileCode : base.profileCode,
    connectorCode: CONNECTOR_RULES[project.connectorCode] ? project.connectorCode : base.connectorCode
  };
}

export function calculateFrame(projectInput = {}) {
  const project = normalizeProject(projectInput);
  const profile = PROFILE_SPECS[project.profileCode];
  const connector = CONNECTOR_RULES[project.connectorCode];
  const levels = levelHeights(project);
  const members = [...posts(project, profile), ...rails(project, profile, connector, levels)];
  const bom = buildBom(profile, connector, members, levels.length);
  const totalPrice = bom.reduce((sum, item) => sum + item.totalPrice, 0);

  return {
    project,
    profile,
    connector,
    members,
    bom,
    totalPrice
  };
}

function clampInteger(value, min, max) {
  const number = Number.parseInt(value, 10);
  if (Number.isNaN(number)) {
    return min;
  }
  return Math.min(max, Math.max(min, number));
}

function levelHeights(project) {
  const levels = project.shelfLevels;
  if (levels === 1) {
    return [0];
  }
  const step = project.heightMm / (levels - 1);
  return Array.from({ length: levels }, (_, index) => Math.round(step * index));
}

function posts(project, profile) {
  const corners = [
    { x: 0, y: 0, label: "左前立柱" },
    { x: project.lengthMm, y: 0, label: "右前立柱" },
    { x: 0, y: project.widthMm, label: "左后立柱" },
    { x: project.lengthMm, y: project.widthMm, label: "右后立柱" }
  ];

  return corners.map((corner, index) => ({
    id: `post-${index}`,
    label: corner.label,
    axis: "z",
    profileCode: profile.code,
    netLengthMm: project.heightMm,
    cutLengthMm: project.heightMm,
    xMm: corner.x,
    yMm: corner.y,
    zMm: 0
  }));
}

function rails(project, profile, connector, levels) {
  const deduction = connector.railEndDeductionProfileWidths * profile.sizeMm * 2;
  const xCutLength = Math.max(profile.sizeMm, Math.min(project.lengthMm, project.lengthMm - deduction));
  const yCutLength = Math.max(profile.sizeMm, Math.min(project.widthMm, project.widthMm - deduction));
  const members = [];

  for (const z of levels) {
    members.push(
      {
        id: `x-front-${z}`,
        label: `前横梁 ${z}mm`,
        axis: "x",
        profileCode: profile.code,
        netLengthMm: project.lengthMm,
        cutLengthMm: xCutLength,
        xMm: 0,
        yMm: 0,
        zMm: z
      },
      {
        id: `x-back-${z}`,
        label: `后横梁 ${z}mm`,
        axis: "x",
        profileCode: profile.code,
        netLengthMm: project.lengthMm,
        cutLengthMm: xCutLength,
        xMm: 0,
        yMm: project.widthMm,
        zMm: z
      },
      {
        id: `y-left-${z}`,
        label: `左侧梁 ${z}mm`,
        axis: "y",
        profileCode: profile.code,
        netLengthMm: project.widthMm,
        cutLengthMm: yCutLength,
        xMm: 0,
        yMm: 0,
        zMm: z
      },
      {
        id: `y-right-${z}`,
        label: `右侧梁 ${z}mm`,
        axis: "y",
        profileCode: profile.code,
        netLengthMm: project.widthMm,
        cutLengthMm: yCutLength,
        xMm: project.lengthMm,
        yMm: 0,
        zMm: z
      }
    );
  }

  return members;
}

function buildBom(profile, connector, members, levelCount) {
  const lengthGroups = new Map();
  for (const member of members) {
    lengthGroups.set(member.cutLengthMm, (lengthGroups.get(member.cutLengthMm) || 0) + 1);
  }

  const profileItems = [...lengthGroups.entries()]
    .sort(([a], [b]) => b - a)
    .map(([lengthMm, quantity]) => {
      const unitPrice = (profile.pricePerMeter * lengthMm) / 1000;
      return {
        kind: "profile",
        code: profile.code,
        name: `${profile.name} 型材 ${lengthMm}mm`,
        lengthMm,
        quantity,
        unit: "根",
        unitPrice,
        totalPrice: unitPrice * quantity
      };
    });

  const connectionNodes = levelCount * 4;
  const connectorQuantity = connectionNodes * connector.connectorPerNode;
  const boltQuantity = connectorQuantity * connector.boltsPerConnector;

  return [
    ...profileItems,
    {
      kind: "connector",
      code: connector.code,
      name: connector.name,
      quantity: connectorQuantity,
      unit: "个",
      unitPrice: connector.connectorPrice,
      totalPrice: connectorQuantity * connector.connectorPrice
    },
    {
      kind: "fastener",
      code: "m6_socket_bolt",
      name: "M6 内六角螺丝",
      quantity: boltQuantity,
      unit: "颗",
      unitPrice: connector.boltPrice,
      totalPrice: boltQuantity * connector.boltPrice
    }
  ];
}
