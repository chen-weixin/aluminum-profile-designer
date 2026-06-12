export const PROFILE_SPECS = {
  "2020": {
    code: "2020",
    name: "欧标 2020",
    sizeMm: 20,
    slotWidthMm: 6,
    pricePerMeter: 18
  },
  "3030": {
    code: "3030",
    name: "欧标 3030",
    sizeMm: 30,
    slotWidthMm: 8,
    pricePerMeter: 32
  },
  "4040": {
    code: "4040",
    name: "欧标 4040",
    sizeMm: 40,
    slotWidthMm: 8,
    pricePerMeter: 52
  }
};

export const CONNECTOR_RULES = {
  corner_bracket: {
    code: "corner_bracket",
    name: "外置角码连接",
    railEndDeductionProfileWidths: 0,
    connectorPerNode: 2,
    boltsPerConnector: 2,
    connectorPrice: 2.8,
    boltPrice: 0.18
  },
  inside_connector: {
    code: "inside_connector",
    name: "内置连接件",
    railEndDeductionProfileWidths: 0,
    connectorPerNode: 2,
    boltsPerConnector: 2,
    connectorPrice: 3.6,
    boltPrice: 0.22
  },
  end_fastener: {
    code: "end_fastener",
    name: "端面连接件",
    railEndDeductionProfileWidths: 1,
    connectorPerNode: 2,
    boltsPerConnector: 1,
    connectorPrice: 4.2,
    boltPrice: 0.25
  }
};
