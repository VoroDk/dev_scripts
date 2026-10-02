(() => {
  "use strict";

  const form = document.getElementById("loginform");
  if (!form) return;

  const userField = document.getElementById("user_login");
  const passField = document.getElementById("user_pass");
  const submitBtn = document.getElementById("wp-submit");
  if (!userField || !passField || !submitBtn) return;

  const host = location.hostname;
  const params = new URLSearchParams(location.search);

  // Situations where auto-login would fight the user.
  const justLoggedOut = params.get("loggedout") === "true" || params.get("action") === "logout";
  const hasLoginError = !!document.getElementById("login_error");

  const defaults = {
    enabled: true,
    autoLogin: false,
    defaultUser: "",
    defaultPass: "",
    overrides: [] // [{ host: "beck.localhost", user: "...", pass: "..." }]
  };

  chrome.storage.local.get(defaults, (cfg) => {
    if (!cfg.enabled) return;

    const creds = pickCreds(cfg, host);
    if (!creds) {
      injectButton(null, "No credentials set — open settings");
      return;
    }

    injectButton(creds, `Log in as ${creds.user}`);

    const recentlyTried = Date.now() - lastAttempt() < 10000;
    if (cfg.autoLogin && !justLoggedOut && !hasLoginError && !recentlyTried) {
      doLogin(creds, true);
    }
  });

  function pickCreds(cfg, hostname) {
    const match = (cfg.overrides || []).find(
      (o) => o.host && o.host.toLowerCase() === hostname.toLowerCase()
    );
    if (match && match.user) return { user: match.user, pass: match.pass || "" };
    if (cfg.defaultUser) return { user: cfg.defaultUser, pass: cfg.defaultPass || "" };
    return null;
  }

  function lastAttempt() {
    const raw = sessionStorage.getItem("wpll:lastAttempt");
    return raw ? parseInt(raw, 10) : 0;
  }

  function setNative(el, value) {
    const setter = Object.getOwnPropertyDescriptor(
      window.HTMLInputElement.prototype,
      "value"
    ).set;
    setter.call(el, value);
    el.dispatchEvent(new Event("input", { bubbles: true }));
    el.dispatchEvent(new Event("change", { bubbles: true }));
  }

  function doLogin(creds, submit) {
    setNative(userField, creds.user);
    setNative(passField, creds.pass);
    if (!submit) {
      passField.focus();
      return;
    }
    sessionStorage.setItem("wpll:lastAttempt", String(Date.now()));
    submitBtn.click();
  }

  function injectButton(creds, label) {
    const wrap = document.createElement("div");
    wrap.id = "wpll-wrap";

    const btn = document.createElement("button");
    btn.type = "button";
    btn.id = "wpll-btn";
    btn.textContent = label;
    btn.addEventListener("click", (e) => {
      if (!creds) {
        alert("Set your dev credentials in the WP Local Login extension options.");
        return;
      }
      doLogin(creds, !e.shiftKey);
    });

    const hint = document.createElement("div");
    hint.id = "wpll-hint";
    hint.textContent = `${host} · shift-click to fill only · ⌥L`;

    wrap.appendChild(btn);
    wrap.appendChild(hint);
    form.parentNode.insertBefore(wrap, form.nextSibling);

    document.addEventListener("keydown", (e) => {
      if (e.altKey && e.code === "KeyL" && creds) {
        e.preventDefault();
        doLogin(creds, true);
      }
    });
  }
})();
