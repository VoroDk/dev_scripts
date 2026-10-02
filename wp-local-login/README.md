# WP Local Login

Chrome extension that adds a "Log in as …" button to the WordPress login form on
`*.localhost` dev sites, filling your shared dev credentials and submitting.

## Install (unpacked)

1. `chrome://extensions` → enable **Developer mode**
2. **Load unpacked** → pick this folder
3. Click the extension icon (or Extensions → WP Local Login → Options) and enter
   your default dev username/password. Save.

Visit any `http://something.localhost/wp-login.php` and the button appears under
the form.

## Behaviour

- **Click** the button → fills and submits.
- **Shift-click** → fills only, leaves the submit to you.
- **⌥L / Alt+L** → fills and submits.
- **Auto-login** (off by default) submits on page load, but is skipped when:
  - you just logged out (`?loggedout=true` or `action=logout`),
  - WordPress is showing a `#login_error`,
  - an attempt was made in the last 10 seconds.

  Those three guards are what keep auto-login from turning into a redirect loop
  or from logging you straight back in when you meant to log out.

## Scope

The content script is declared only for `http(s)://*.localhost/*` and
`http(s)://localhost/*`, so it is never injected on any other host. Match
patterns ignore ports, so `:8080` etc. are covered. It also bails immediately
unless the page has `#loginform`, `#user_login`, `#user_pass` and `#wp-submit` —
i.e. an actual WordPress login form.

Per-site overrides let you point specific hostnames at different accounts
(e.g. an editor account on one site).

## Sharing with the team

- Commit this folder to a repo; each person loads it unpacked and enters their
  own credentials. Credentials live in `chrome.storage.local`, so nothing
  secret is in the repo.
- Switch `chrome.storage.local` → `chrome.storage.sync` in `content.js` and
  `options.js` if you want settings to follow your own Chrome profile across
  machines. Don't do this if you'd rather dev passwords not touch Google's
  servers.
- For a managed org you can force-install it via enterprise policy, but that
  needs a hosted CRX or Web Store listing; unpacked is simpler for a small team.

## Caveats

- Extension storage is **not** encrypted. Any other extension with sufficient
  permissions, or anyone with your profile directory, can read it. Use it only
  for throwaway local passwords.
- Chrome drops unpacked extensions' "Developer mode" warning on each restart;
  harmless.
- If a site uses 2FA or a custom login form, this won't help — it only knows the
  stock WordPress markup.

## Alternative worth knowing

A mu-plugin in your local stack that auto-authenticates when
`$_SERVER['HTTP_HOST']` ends in `.localhost` achieves the same thing in every
browser with no extension at all. It's riskier (code that logs people in, living
in the site) but it's a one-file option if the extension gets annoying to
maintain across machines.
