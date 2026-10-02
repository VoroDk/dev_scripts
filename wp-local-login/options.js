"use strict";

const defaults = {
  enabled: true,
  autoLogin: false,
  defaultUser: "",
  defaultPass: "",
  overrides: []
};

const $ = (id) => document.getElementById(id);
const rows = $("overrides");

function addRow(entry = { host: "", user: "", pass: "" }) {
  const row = document.createElement("div");
  row.className = "row";
  row.innerHTML =
    '<input type="text" class="o-host" placeholder="beck.localhost" spellcheck="false">' +
    '<input type="text" class="o-user" autocomplete="off" spellcheck="false">' +
    '<input type="password" class="o-pass" autocomplete="off">' +
    '<button type="button" class="o-del" title="Remove">&times;</button>';
  row.querySelector(".o-host").value = entry.host || "";
  row.querySelector(".o-user").value = entry.user || "";
  row.querySelector(".o-pass").value = entry.pass || "";
  row.querySelector(".o-del").addEventListener("click", () => row.remove());
  rows.appendChild(row);
}

function collect() {
  return [...rows.querySelectorAll(".row")]
    .map((r) => ({
      host: r.querySelector(".o-host").value.trim(),
      user: r.querySelector(".o-user").value.trim(),
      pass: r.querySelector(".o-pass").value
    }))
    .filter((o) => o.host && o.user);
}

chrome.storage.local.get(defaults, (cfg) => {
  $("defaultUser").value = cfg.defaultUser;
  $("defaultPass").value = cfg.defaultPass;
  $("enabled").checked = cfg.enabled;
  $("autoLogin").checked = cfg.autoLogin;
  (cfg.overrides || []).forEach(addRow);
});

$("addRow").addEventListener("click", () => addRow());

$("save").addEventListener("click", () => {
  chrome.storage.local.set(
    {
      defaultUser: $("defaultUser").value.trim(),
      defaultPass: $("defaultPass").value,
      enabled: $("enabled").checked,
      autoLogin: $("autoLogin").checked,
      overrides: collect()
    },
    () => {
      $("status").textContent = "Saved";
      setTimeout(() => ($("status").textContent = ""), 1500);
    }
  );
});
