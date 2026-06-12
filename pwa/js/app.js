import { CONNECTOR_RULES, PROFILE_SPECS } from "./catalog.js";
import { calculateFrame, defaultProject, normalizeProject } from "./calculator.js";
import { decodeProject, downloadTextFile, encodeProject, exportBomCsv } from "./exporters.js";
import { duplicateProject, loadProjects, saveProject } from "./storage.js";
import { drawFramePreview } from "./preview.js";

let currentProject = defaultProject();
let currentDesign = calculateFrame(currentProject);
let selectedMemberIndex = -1;

const elements = {
  tabs: [...document.querySelectorAll(".bottom-tabs button")],
  panels: [...document.querySelectorAll(".tab-panel")],
  form: document.querySelector("#designForm"),
  projectName: document.querySelector("#projectName"),
  lengthMm: document.querySelector("#lengthMm"),
  widthMm: document.querySelector("#widthMm"),
  heightMm: document.querySelector("#heightMm"),
  shelfLevels: document.querySelector("#shelfLevels"),
  profileOptions: document.querySelector("#profileOptions"),
  connectorCode: document.querySelector("#connectorCode"),
  projectSummary: document.querySelector("#projectSummary"),
  totalCost: document.querySelector("#totalCost"),
  canvas: document.querySelector("#frameCanvas"),
  selectedMember: document.querySelector("#selectedMember"),
  bomList: document.querySelector("#bomList"),
  downloadCsv: document.querySelector("#downloadCsv"),
  saveProject: document.querySelector("#saveProject"),
  duplicateProject: document.querySelector("#duplicateProject"),
  projectList: document.querySelector("#projectList"),
  projectJson: document.querySelector("#projectJson"),
  downloadJson: document.querySelector("#downloadJson"),
  importJson: document.querySelector("#importJson"),
  importProject: document.querySelector("#importProject"),
  statusMessage: document.querySelector("#statusMessage")
};

boot();

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./service-worker.js");
  });
}

function boot() {
  renderProfileOptions();
  renderConnectorOptions();
  bindEvents();

  const projects = loadProjects();
  if (projects.length > 0) {
    currentProject = projects[0];
  }
  recalculate();
}

function bindEvents() {
  elements.tabs.forEach((button) => {
    button.addEventListener("click", () => activateTab(button.dataset.tab));
  });

  elements.form.addEventListener("input", () => {
    currentProject = normalizeProject({
      ...currentProject,
      name: elements.projectName.value,
      lengthMm: elements.lengthMm.value,
      widthMm: elements.widthMm.value,
      heightMm: elements.heightMm.value,
      shelfLevels: elements.shelfLevels.value,
      connectorCode: elements.connectorCode.value
    });
    selectedMemberIndex = -1;
    recalculate();
  });

  elements.profileOptions.addEventListener("click", (event) => {
    const button = event.target.closest("button[data-profile]");
    if (!button) return;
    currentProject = normalizeProject({ ...currentProject, profileCode: button.dataset.profile });
    selectedMemberIndex = -1;
    recalculate();
  });

  elements.canvas.addEventListener("click", () => {
    if (currentDesign.members.length === 0) return;
    selectedMemberIndex = (selectedMemberIndex + 1) % currentDesign.members.length;
    renderPreview();
  });

  window.addEventListener("resize", renderPreview);

  elements.downloadCsv.addEventListener("click", () => {
    downloadTextFile("bom.csv", exportBomCsv(currentDesign), "text/csv;charset=utf-8");
    showStatus("CSV 已生成");
  });

  elements.downloadJson.addEventListener("click", () => {
    downloadTextFile("project.json", encodeProject(currentProject), "application/json;charset=utf-8");
    showStatus("项目 JSON 已生成");
  });

  elements.saveProject.addEventListener("click", () => {
    currentProject = saveProject(currentProject);
    renderProjects();
    showStatus("项目已保存到本机浏览器");
  });

  elements.duplicateProject.addEventListener("click", () => {
    currentProject = duplicateProject(currentProject);
    selectedMemberIndex = -1;
    recalculate();
    showStatus("已复制项目");
  });

  elements.importProject.addEventListener("click", () => {
    try {
      currentProject = saveProject(decodeProject(elements.importJson.value));
      elements.importJson.value = "";
      selectedMemberIndex = -1;
      recalculate();
      showStatus("项目已导入");
    } catch (error) {
      showStatus(error.message || "导入失败");
    }
  });
}

function activateTab(tab) {
  elements.tabs.forEach((button) => button.classList.toggle("active", button.dataset.tab === tab));
  elements.panels.forEach((panel) => panel.classList.toggle("active", panel.id === `tab-${tab}`));
  if (tab === "preview") {
    renderPreview();
  }
}

function recalculate() {
  currentDesign = calculateFrame(currentProject);
  renderAll();
}

function renderAll() {
  renderForm();
  renderSummary();
  renderBom();
  renderProjects();
  renderPreview();
}

function renderProfileOptions() {
  elements.profileOptions.innerHTML = Object.values(PROFILE_SPECS)
    .map((profile) => `<button type="button" data-profile="${profile.code}">${profile.code}</button>`)
    .join("");
}

function renderConnectorOptions() {
  elements.connectorCode.innerHTML = Object.values(CONNECTOR_RULES)
    .map((connector) => `<option value="${connector.code}">${connector.name}</option>`)
    .join("");
}

function renderForm() {
  elements.projectName.value = currentProject.name;
  elements.lengthMm.value = currentProject.lengthMm;
  elements.widthMm.value = currentProject.widthMm;
  elements.heightMm.value = currentProject.heightMm;
  elements.shelfLevels.value = currentProject.shelfLevels;
  elements.connectorCode.value = currentProject.connectorCode;
  elements.profileOptions.querySelectorAll("button").forEach((button) => {
    button.classList.toggle("active", button.dataset.profile === currentProject.profileCode);
  });
}

function renderSummary() {
  elements.projectSummary.textContent = `${currentProject.lengthMm} x ${currentProject.widthMm} x ${currentProject.heightMm}mm · ${currentProject.profileCode}`;
  elements.totalCost.textContent = `￥${currentDesign.totalPrice.toFixed(0)}`;
  elements.projectJson.value = encodeProject(currentProject);
}

function renderBom() {
  elements.bomList.innerHTML = currentDesign.bom
    .map((item) => {
      const length = item.lengthMm == null ? "" : ` · ${item.lengthMm}mm`;
      return `
        <article class="bom-card">
          <div class="row">
            <strong>${item.name}</strong>
            <span>￥${item.totalPrice.toFixed(2)}</span>
          </div>
          <span class="meta">${item.quantity}${item.unit}${length} · 单价 ￥${item.unitPrice.toFixed(2)}</span>
        </article>
      `;
    })
    .join("");
}

function renderProjects() {
  const projects = loadProjects();
  if (projects.length === 0) {
    elements.projectList.innerHTML = '<p class="meta">还没有保存项目。</p>';
    return;
  }

  elements.projectList.innerHTML = projects
    .map((project) => `
      <button class="project-card secondary" type="button" data-project-id="${project.id}">
        <strong>${project.name}</strong>
        <span class="meta">${project.lengthMm} x ${project.widthMm} x ${project.heightMm}mm · ${project.profileCode}</span>
      </button>
    `)
    .join("");

  elements.projectList.querySelectorAll("[data-project-id]").forEach((button) => {
    button.addEventListener("click", () => {
      const selected = loadProjects().find((project) => project.id === button.dataset.projectId);
      if (!selected) return;
      currentProject = selected;
      selectedMemberIndex = -1;
      recalculate();
      showStatus("项目已载入");
    });
  });
}

function renderPreview() {
  if (!elements.canvas.offsetParent && !document.querySelector("#tab-preview").classList.contains("active")) {
    return;
  }
  drawFramePreview(elements.canvas, currentDesign, selectedMemberIndex);
  const member = currentDesign.members[selectedMemberIndex];
  elements.selectedMember.textContent = member
    ? `${member.label}：${member.profileCode}，切割 ${member.cutLengthMm}mm`
    : "点按预览区查看构件。";
}

function showStatus(message) {
  elements.statusMessage.textContent = message;
  window.clearTimeout(showStatus.timer);
  showStatus.timer = window.setTimeout(() => {
    elements.statusMessage.textContent = "";
  }, 2600);
}
