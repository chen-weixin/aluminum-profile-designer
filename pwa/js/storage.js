import { normalizeProject } from "./calculator.js";

const STORAGE_KEY = "aluminum-profile-designer.projects.v1";

export function loadProjects(storage = window.localStorage) {
  const raw = storage.getItem(STORAGE_KEY);
  if (!raw) {
    return [];
  }

  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) {
      return [];
    }
    return parsed.map((project) => normalizeProject(project));
  } catch (error) {
    return [];
  }
}

export function saveProject(project, storage = window.localStorage) {
  const normalized = normalizeProject(project);
  const projects = loadProjects(storage);
  const index = projects.findIndex((item) => item.id === normalized.id);
  if (index === -1) {
    projects.push(normalized);
  } else {
    projects[index] = normalized;
  }
  storage.setItem(STORAGE_KEY, JSON.stringify(projects));
  return normalized;
}

export function duplicateProject(project, storage = window.localStorage) {
  const duplicated = normalizeProject({
    ...project,
    id: String(Date.now()),
    name: `${project.name || "项目"} 副本`
  });
  return saveProject(duplicated, storage);
}

export function deleteProject(projectId, storage = window.localStorage) {
  const projects = loadProjects(storage).filter((project) => project.id !== projectId);
  storage.setItem(STORAGE_KEY, JSON.stringify(projects));
  return projects;
}
