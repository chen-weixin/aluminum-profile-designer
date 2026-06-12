# PWA Rewrite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current Flutter-first prototype with a lightweight PWA-first web app that can run locally, deploy as static files, install to mobile home screens, and keep the aluminum profile calculator usable without large toolchains.

**Architecture:** Build a dependency-free static app under `pwa/`. Keep business logic separate from UI: calculator, storage, export, preview, and app orchestration are separate JavaScript files. Preserve the Flutter prototype for reference in the first migration pass, then decide in a later cleanup commit whether to archive or remove it.

**Tech Stack:** HTML, CSS, vanilla JavaScript, Canvas, localStorage, Web App Manifest, Service Worker, Node.js built-in test runner for logic tests.

---

## File Structure

- Create `pwa/index.html`: mobile-first app shell with four tabs: design, preview, BOM, projects.
- Create `pwa/styles.css`: responsive touch UI, no framework dependency.
- Create `pwa/js/catalog.js`: profile specs and connector rules.
- Create `pwa/js/calculator.js`: frame generation and BOM calculation.
- Create `pwa/js/exporters.js`: project JSON and BOM CSV export helpers.
- Create `pwa/js/storage.js`: localStorage project persistence.
- Create `pwa/js/preview.js`: Canvas axonometric frame preview.
- Create `pwa/js/app.js`: UI state, form binding, tab navigation, save/load/import/export actions.
- Create `pwa/manifest.json`: PWA install metadata.
- Create `pwa/service-worker.js`: offline cache for static app files.
- Create `pwa/icons/icon.svg`: lightweight app icon.
- Create `test/pwa-calculator.test.mjs`: Node tests for calculator behavior.
- Create `test/pwa-exporters.test.mjs`: Node tests for JSON/CSV behavior.
- Modify `README.md`: make PWA usage the primary path.
- Modify `docs/DEPLOYMENT.md`: point static hosting to `pwa/`.
- Modify `docs/ARCHITECTURE.md`: make PWA module boundaries canonical.
- Modify `package.json`: add test and local preview scripts if Node is available.

---

### Task 1: Add PWA Project Skeleton

**Files:**
- Create: `pwa/index.html`
- Create: `pwa/styles.css`
- Create: `pwa/js/app.js`
- Create: `pwa/manifest.json`
- Create: `pwa/service-worker.js`
- Create: `pwa/icons/icon.svg`
- Create: `package.json`

- [ ] **Step 1: Create the static app shell**

Create `pwa/index.html` with:

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="theme-color" content="#1f6f5b">
    <title>铝型材 DIY 设计器</title>
    <link rel="manifest" href="./manifest.json">
    <link rel="stylesheet" href="./styles.css">
  </head>
  <body>
    <main class="app-shell">
      <header class="topbar">
        <div>
          <h1>铝型材 DIY 设计器</h1>
          <p id="projectSummary">1200 x 600 x 800mm · 3030</p>
        </div>
        <strong id="totalCost">￥0</strong>
      </header>

      <section class="tab-panel active" id="tab-design" aria-label="设计">
        <form id="designForm" class="panel-content">
          <label>项目名称<input id="projectName" name="name" autocomplete="off"></label>
          <div class="grid-2">
            <label>长度 mm<input id="lengthMm" name="lengthMm" type="number" min="200" max="6000" step="50"></label>
            <label>宽度 mm<input id="widthMm" name="widthMm" type="number" min="200" max="3000" step="50"></label>
            <label>高度 mm<input id="heightMm" name="heightMm" type="number" min="200" max="3000" step="50"></label>
            <label>水平层数<input id="shelfLevels" name="shelfLevels" type="number" min="2" max="8" step="1"></label>
          </div>
          <fieldset>
            <legend>型材规格</legend>
            <div id="profileOptions" class="segmented"></div>
          </fieldset>
          <label>连接方式<select id="connectorCode" name="connectorCode"></select></label>
        </form>
      </section>

      <section class="tab-panel" id="tab-preview" aria-label="预览">
        <canvas id="frameCanvas" width="900" height="720"></canvas>
        <p id="selectedMember" class="hint">点按预览区查看构件。</p>
      </section>

      <section class="tab-panel" id="tab-bom" aria-label="清单">
        <div class="panel-content">
          <div id="bomList"></div>
          <button id="downloadCsv" type="button">导出 CSV</button>
        </div>
      </section>

      <section class="tab-panel" id="tab-projects" aria-label="项目">
        <div class="panel-content">
          <button id="saveProject" type="button">保存项目</button>
          <button id="duplicateProject" type="button">复制项目</button>
          <div id="projectList"></div>
          <textarea id="projectJson" rows="8" spellcheck="false"></textarea>
          <button id="downloadJson" type="button">导出 JSON</button>
          <textarea id="importJson" rows="6" placeholder="粘贴项目 JSON"></textarea>
          <button id="importProject" type="button">导入项目</button>
        </div>
      </section>

      <nav class="bottom-tabs" aria-label="主导航">
        <button class="active" data-tab="design" type="button">设计</button>
        <button data-tab="preview" type="button">3D</button>
        <button data-tab="bom" type="button">清单</button>
        <button data-tab="projects" type="button">项目</button>
      </nav>
    </main>
    <script type="module" src="./js/app.js"></script>
  </body>
</html>
```

- [ ] **Step 2: Add responsive CSS**

Create `pwa/styles.css` with mobile-first layout, bottom tabs fixed to the bottom, readable form controls, and Canvas sized with `width: 100%; aspect-ratio: 5 / 4;`.

- [ ] **Step 3: Add placeholder app bootstrap**

Create `pwa/js/app.js`:

```js
console.info("Aluminum profile designer PWA loaded");

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./service-worker.js");
  });
}
```

- [ ] **Step 4: Add manifest and service worker**

Create `pwa/manifest.json`:

```json
{
  "name": "铝型材 DIY 设计器",
  "short_name": "型材设计",
  "start_url": "./index.html",
  "scope": "./",
  "display": "standalone",
  "background_color": "#f6f7f4",
  "theme_color": "#1f6f5b",
  "icons": [
    {
      "src": "./icons/icon.svg",
      "sizes": "any",
      "type": "image/svg+xml",
      "purpose": "any maskable"
    }
  ]
}
```

Create `pwa/service-worker.js`:

```js
const CACHE_NAME = "aluminum-profile-designer-v1";
const APP_FILES = [
  "./",
  "./index.html",
  "./styles.css",
  "./manifest.json",
  "./icons/icon.svg",
  "./js/app.js"
];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_FILES)));
});

self.addEventListener("fetch", (event) => {
  event.respondWith(caches.match(event.request).then((cached) => cached || fetch(event.request)));
});
```

- [ ] **Step 5: Add package scripts**

Create `package.json`:

```json
{
  "name": "aluminum-profile-designer",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "node --test test/*.test.mjs",
    "serve": "python -m http.server 4173 -d pwa"
  }
}
```

- [ ] **Step 6: Commit skeleton**

Run:

```powershell
git add pwa package.json
git commit -m "feat: add PWA app skeleton"
```

---

### Task 2: Port Catalog and Calculator Logic

**Files:**
- Create: `pwa/js/catalog.js`
- Create: `pwa/js/calculator.js`
- Create: `test/pwa-calculator.test.mjs`

- [ ] **Step 1: Write failing calculator tests**

Create `test/pwa-calculator.test.mjs` with tests for:

- 2 levels produce 4 posts, 8 x-rails/y-rails total, 12 members total.
- 3 levels produce 4 posts and 12 rails, 16 members total.
- `end_fastener` shortens rails by two profile widths.
- BOM groups profile lengths and connector/bolt quantities.

- [ ] **Step 2: Run tests and verify failure**

Run:

```powershell
npm test
```

Expected: fail because `pwa/js/calculator.js` does not exist or exports are missing.

- [ ] **Step 3: Implement catalog**

Create `pwa/js/catalog.js` exporting `PROFILE_SPECS` and `CONNECTOR_RULES` equivalent to the current Dart rules.

- [ ] **Step 4: Implement calculator**

Create `pwa/js/calculator.js` exporting:

```js
export function defaultProject()
export function calculateFrame(project)
export function normalizeProject(project)
```

The returned design shape must be:

```js
{
  project,
  profile,
  connector,
  members,
  bom,
  totalPrice
}
```

- [ ] **Step 5: Run tests and verify pass**

Run:

```powershell
npm test
```

Expected: all calculator tests pass.

- [ ] **Step 6: Commit calculator**

Run:

```powershell
git add pwa/js/catalog.js pwa/js/calculator.js test/pwa-calculator.test.mjs
git commit -m "feat: port frame calculator to PWA"
```

---

### Task 3: Add Export and Local Storage

**Files:**
- Create: `pwa/js/exporters.js`
- Create: `pwa/js/storage.js`
- Create: `test/pwa-exporters.test.mjs`

- [ ] **Step 1: Write failing exporter tests**

Create tests covering:

- JSON project round-trip keeps name, dimensions, profile, connector.
- CSV includes header, profile rows, connector rows, and total row.
- CSV escapes values containing commas or quotes.

- [ ] **Step 2: Run tests and verify failure**

Run:

```powershell
npm test
```

Expected: fail because exporter functions are missing.

- [ ] **Step 3: Implement exporters**

Create `pwa/js/exporters.js` exporting:

```js
export function encodeProject(project)
export function decodeProject(source)
export function exportBomCsv(design)
```

- [ ] **Step 4: Implement storage**

Create `pwa/js/storage.js` exporting:

```js
export function loadProjects()
export function saveProject(project)
export function duplicateProject(project)
export function deleteProject(projectId)
```

Use key `aluminum-profile-designer.projects.v1`.

- [ ] **Step 5: Run tests and verify pass**

Run:

```powershell
npm test
```

Expected: all calculator and exporter tests pass.

- [ ] **Step 6: Commit export/storage**

Run:

```powershell
git add pwa/js/exporters.js pwa/js/storage.js test/pwa-exporters.test.mjs
git commit -m "feat: add PWA export and local storage"
```

---

### Task 4: Build App UI Wiring

**Files:**
- Modify: `pwa/js/app.js`
- Modify: `pwa/index.html`
- Modify: `pwa/styles.css`

- [ ] **Step 1: Wire app state**

In `pwa/js/app.js`, import calculator, catalog, exporters, and storage. Maintain:

```js
let currentProject = defaultProject();
let currentDesign = calculateFrame(currentProject);
let selectedMemberIndex = -1;
```

- [ ] **Step 2: Bind design form**

Populate profile buttons and connector select from catalog. On input change, update `currentProject`, recalculate, and rerender all panels.

- [ ] **Step 3: Render BOM**

Render `design.bom` into `#bomList`, including quantity, unit, length, unit price, and subtotal.

- [ ] **Step 4: Add JSON and CSV downloads**

Use `Blob` and temporary anchor downloads:

- `downloadProject.json`
- `bom.csv`

- [ ] **Step 5: Add project save/load/import**

Use storage helpers. On import parse JSON, normalize project, save/load into state, and show a visible status message.

- [ ] **Step 6: Manual verification**

Run:

```powershell
python -m http.server 4173 -d pwa
```

Open `http://localhost:4173`. Verify:

- Changing dimensions updates summary and BOM.
- Saving project adds it to the list.
- JSON export/import restores project.
- CSV download creates a file.

- [ ] **Step 7: Commit UI wiring**

Run:

```powershell
git add pwa/index.html pwa/styles.css pwa/js/app.js
git commit -m "feat: wire PWA design and BOM UI"
```

---

### Task 5: Add Canvas Preview

**Files:**
- Create: `pwa/js/preview.js`
- Modify: `pwa/js/app.js`
- Modify: `pwa/styles.css`

- [ ] **Step 1: Implement preview renderer**

Create `pwa/js/preview.js` exporting:

```js
export function drawFramePreview(canvas, design, selectedMemberIndex)
```

Use the same axonometric projection as the Flutter prototype:

```js
screenX = originX + x * scale + y * scale * 0.45
screenY = originY - z * scale + y * scale * 0.32
```

- [ ] **Step 2: Add member selection**

In `app.js`, clicking the canvas cycles through `design.members`; update `#selectedMember`.

- [ ] **Step 3: Add high-DPI canvas support**

Scale the canvas backing store by `window.devicePixelRatio`, then draw using CSS pixel dimensions.

- [ ] **Step 4: Manual verification**

Open local app and verify:

- Frame is visible on mobile-width viewport.
- Changing length/width/height changes preview.
- Clicking preview highlights next member.

- [ ] **Step 5: Commit preview**

Run:

```powershell
git add pwa/js/preview.js pwa/js/app.js pwa/styles.css
git commit -m "feat: add canvas frame preview"
```

---

### Task 6: Finish PWA Offline and Deployment Readiness

**Files:**
- Modify: `pwa/service-worker.js`
- Modify: `README.md`
- Modify: `docs/ARCHITECTURE.md`
- Modify: `docs/DEPLOYMENT.md`
- Modify: `docs/ROADMAP.md`

- [ ] **Step 1: Update service worker cache list**

Add every PWA file to `APP_FILES`, including catalog, calculator, exporters, storage, preview, and icon.

- [ ] **Step 2: Verify offline behavior**

Serve locally, open app once, then simulate offline in browser devtools or stop server and reload from cache where supported.

- [ ] **Step 3: Update documentation**

README should lead with:

```powershell
python -m http.server 4173 -d pwa
```

Deployment docs should state output directory is `pwa/` and build command is empty.

- [ ] **Step 4: Final checks**

Run:

```powershell
npm test
git status -sb
```

Expected:

- `npm test` passes.
- Only intended documentation/PWA files are modified.

- [ ] **Step 5: Commit PWA finish**

Run:

```powershell
git add pwa README.md docs
git commit -m "docs: document PWA usage and deployment"
```

---

### Task 7: Push Version to GitHub

**Files:**
- No file edits expected.

- [ ] **Step 1: Review commit history**

Run:

```powershell
git log --oneline -5
```

- [ ] **Step 2: Push to GitHub**

Run:

```powershell
git push
```

- [ ] **Step 3: Confirm repository status**

Open:

```text
https://github.com/chen-weixin/aluminum-profile-designer
```

Confirm README renders, PWA files are present, and latest commits are visible.

---

## Self-Review

- Spec coverage: The plan covers PWA skeleton, calculator, export, storage, Canvas preview, offline cache, docs, and GitHub push.
- Placeholder scan: No open-ended TODO/TBD steps; each task defines concrete files, commands, and expected results.
- Scope control: The plan does not include accounts, cloud sync, free CAD, angled braces, panels, PDF export, or native APK packaging.
