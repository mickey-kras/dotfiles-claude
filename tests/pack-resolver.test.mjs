import test from "node:test";
import assert from "node:assert/strict";
import path from "node:path";

import {
  getProfileSelection,
  legacyDataToSelection,
  loadPack,
  matchProfile,
  normalizeSelection,
  normalizeSettings,
  resolveLegacyState,
  resolveState,
  stateFromFlatData,
  validateSelection
} from "../scripts/lib/pack-resolver.mjs";

const repoRoot = path.resolve(import.meta.dirname, "..");
const pack = loadPack(repoRoot, "software-development");

test("loads the software-development pack", () => {
  assert.equal(pack.id, "software-development");
  assert.equal(pack.defaults.profile, "balanced");
  assert.ok(pack.profiles.restricted);
  assert.ok(pack.catalogs.mcps.github);
});

test("normalizes hidden settings back to defaults", () => {
  const settings = normalizeSettings(pack, {
    memory_provider: "builtin",
    obsidian_vault_path: "/tmp/vault",
    azure_devops_org: "acme"
  });

  assert.deepEqual(settings, {
    memory_provider: "builtin",
    obsidian_vault_path: "",
    azure_devops_org: "acme"
  });
});

test("matches named profiles after normalization", () => {
  const balanced = getProfileSelection(pack, "balanced");
  balanced.mcps.enabled = [...balanced.mcps.enabled].reverse();
  assert.equal(matchProfile(pack, balanced), "balanced");
});

test("marks edited selections as custom", () => {
  const balanced = getProfileSelection(pack, "balanced");
  balanced.mcps.enabled = balanced.mcps.enabled.filter((id) => id !== "shell");

  const resolved = resolveState(pack, {
    pack_id: pack.id,
    profile: {
      selected: "balanced",
      mode: "preset"
    },
    selection: balanced
  });

  assert.equal(resolved.profile.mode, "custom");
  assert.equal(resolved.resolved.profile, "custom");
  assert.equal(resolved.resolved.profile_basis, "balanced");
});

test("derives a custom selection from legacy fields", () => {
  const derived = legacyDataToSelection(pack, {
    runtime_profile: "custom",
    profile_base: "restricted",
    custom_enabled_mcps: ["shell"],
    custom_enabled_permission_groups: ["git_full"],
    memory_provider: "obsidian",
    obsidian_vault_path: "/vault"
  });

  assert.equal(derived.profile.selected, "restricted");
  assert.equal(derived.profile.mode, "custom");
  assert.ok(derived.selection.mcps.enabled.includes("shell"));
  assert.ok(derived.selection.permissions.enabled.includes("git_full"));
  assert.equal(derived.selection.settings.memory_provider, "obsidian");
  assert.equal(derived.selection.settings.obsidian_vault_path, "/vault");
});

test("preserves preset parity for legacy balanced profile", () => {
  const resolved = resolveLegacyState(pack, {
    runtime_profile: "balanced",
    memory_provider: "builtin",
    obsidian_vault_path: "/ignored"
  });

  assert.equal(resolved.profile.selected, "balanced");
  assert.equal(resolved.profile.mode, "preset");
  assert.equal(resolved.resolved.profile, "balanced");
  assert.equal(resolved.resolved.settings.obsidian_vault_path, "");
  assert.ok(resolved.resolved.permissions.allow.includes("Bash(git *)"));
});

test("flags missing required settings for enabled tools", () => {
  const selection = normalizeSelection(pack, {
    mcps: {
      enabled: ["azure-devops"]
    },
    settings: {
      memory_provider: "builtin"
    }
  });
  const validation = validateSelection(pack, selection);

  assert.deepEqual(validation.errors, []);
  assert.ok(validation.warnings.includes("MCP azure-devops requires setting azure_devops_org"));
});

test("prefers explicit selection state over legacy flat fields", () => {
  const state = stateFromFlatData(pack, {
    capability_pack: "software-development",
    runtime_profile: "open",
    profile_selected: "balanced",
    profile_mode: "preset",
    selection_enabled_mcps: ["git", "filesystem"],
    selection_enabled_skills: ["writing-plans"],
    selection_enabled_agents: ["planner"],
    selection_enabled_rules: ["testing"],
    selection_enabled_permissions: ["core_read_write"],
    memory_provider: "builtin",
    obsidian_vault_path: "/ignored",
    azure_devops_org: "acme"
  });

  assert.equal(state.profile.selected, "balanced");
  assert.deepEqual(state.selection.mcps.enabled, ["git", "filesystem"]);
  assert.equal(state.selection.settings.obsidian_vault_path, "/ignored");
});
