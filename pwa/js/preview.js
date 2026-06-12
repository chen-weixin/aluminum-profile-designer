export function drawFramePreview(canvas, design, selectedMemberIndex = -1) {
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.max(1, Math.round(rect.width * dpr));
  canvas.height = Math.max(1, Math.round(rect.height * dpr));

  const ctx = canvas.getContext("2d");
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, rect.width, rect.height);

  const { project, profile, members } = design;
  const scale = Math.min(
    rect.width / (project.lengthMm + project.widthMm * 0.65 + 160),
    rect.height / (project.heightMm + project.widthMm * 0.45 + 160)
  );
  const origin = {
    x: rect.width * 0.14,
    y: rect.height * 0.72
  };

  drawGrid(ctx, rect, origin, scale, project);

  for (const [index, member] of members.entries()) {
    const start = projectPoint(member.xMm, member.yMm, member.zMm, origin, scale);
    const end = memberEnd(member, origin, scale);
    ctx.lineWidth = Math.max(4, profile.sizeMm * scale);
    ctx.lineCap = "square";
    ctx.strokeStyle = index === selectedMemberIndex ? "#d97706" : "#56636b";
    ctx.beginPath();
    ctx.moveTo(start.x, start.y);
    ctx.lineTo(end.x, end.y);
    ctx.stroke();
  }

  drawDimensions(ctx, rect, project);
}

function memberEnd(member, origin, scale) {
  if (member.axis === "x") {
    return projectPoint(member.xMm + member.netLengthMm, member.yMm, member.zMm, origin, scale);
  }
  if (member.axis === "y") {
    return projectPoint(member.xMm, member.yMm + member.netLengthMm, member.zMm, origin, scale);
  }
  return projectPoint(member.xMm, member.yMm, member.zMm + member.netLengthMm, origin, scale);
}

function projectPoint(x, y, z, origin, scale) {
  return {
    x: origin.x + x * scale + y * scale * 0.45,
    y: origin.y - z * scale + y * scale * 0.32
  };
}

function drawGrid(ctx, rect, origin, scale, project) {
  ctx.strokeStyle = "#dfe7df";
  ctx.lineWidth = 1;
  ctx.setLineDash([4, 6]);
  const base = [
    projectPoint(0, 0, 0, origin, scale),
    projectPoint(project.lengthMm, 0, 0, origin, scale),
    projectPoint(project.lengthMm, project.widthMm, 0, origin, scale),
    projectPoint(0, project.widthMm, 0, origin, scale)
  ];
  ctx.beginPath();
  ctx.moveTo(base[0].x, base[0].y);
  for (const point of base.slice(1)) {
    ctx.lineTo(point.x, point.y);
  }
  ctx.closePath();
  ctx.stroke();
  ctx.setLineDash([]);

  ctx.fillStyle = "#edf4ef";
  ctx.fillRect(0, rect.height - 40, rect.width, 40);
}

function drawDimensions(ctx, rect, project) {
  ctx.fillStyle = "#32413a";
  ctx.font = "13px system-ui, sans-serif";
  ctx.fillText(`长 ${project.lengthMm}mm`, 14, rect.height - 18);
  ctx.fillText(`宽 ${project.widthMm}mm`, 120, rect.height - 18);
  ctx.fillText(`高 ${project.heightMm}mm`, 226, rect.height - 18);
}
