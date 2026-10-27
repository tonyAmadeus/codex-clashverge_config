# OpenAI Original-Entry Network Repair

[中文说明](README.md) · Windows / Clash Verge Rev / Mihomo

Double-click **`run.cmd`** for a desktop menu with **Check connection, Repair / Resume, Restore, User guide**. Select **中文 / English** in the dropdown. Normal use requires no terminal commands. Diagnostic output remains in its original English.

The toolkit uses the existing Clash core to help with Codex, Chat and Dots reconnects and related website access. It keeps the original ChatGPT icon and login entry. It does not install network drivers, ProxiFyre or another application shortcut. This is a community tool, not an official OpenAI or Clash fix.

## Requirements and launch

Download **Code → Download ZIP**, extract all files, then double-click `run.cmd`. Do not run inside the ZIP.

Requires Windows, Windows PowerShell 5.1, Clash Verge Rev using its default user directory, and an available Node.js runtime (a supported LTS version is recommended). The launcher looks in PATH and then for the ChatGPT bundled runtime; it never installs one automatically. Keep one Verge Mihomo core running, system proxy enabled, Rule mode selected, and a working subscription node available.

Expected configuration: `%APPDATA%\io.github.clash-verge-rev.clash-verge-rev`. Portable installations, other Clash clients and custom directories are not guaranteed to work. Administrator consent is required for hosts changes. Use the same Windows account; elevation under a different administrator account is rejected.

## Check and repair

1. Click **Check connection**. Before installation, this checks the basic configuration. After installation, it also checks DNS and verified TLS for six relay domains.
2. Click **Repair / Resume** and confirm. It backs up the local files and appends a global script extension. Hosts and user environment variables are unchanged at this stage.
3. Reload the Clash configuration or restart Clash. Select a working node in **OpenAI 稳定连接**. Return to the menu and click OK, or cancel and resume later.
4. Accept Windows administrator consent. Six TLS relay probes must succeed before hosts and user proxy variables are changed.
5. Fully exit ChatGPT and reopen its original icon. Check again, then send real messages in Codex, Chat and Dots with TUN both off and on. Test your intended websites as well.

Pause subscription updates and configuration editing during repair. The tool stops on conflicting custom hosts entries, proxy variables, listener conflicts, unexpected scripts or missing backups. Existing repairs are detected rather than installed twice. Read the diagnostic log if an operation stops.

## Changes and limitations

The global `profiles\Script.js` extension preserves the previous `main` call and arguments, adds OpenAI routing and a proxy group, and creates TCP relays on `127.0.0.11` through `127.0.0.16`, port 443. Corresponding marked hosts entries map these six domains, respectively:

`codex-cloud-backend.chatgpt.com`, `chatgpt.com`, `ws.chatgpt.com`, `ab.chatgpt.com`, `codex-cloud-environments.chatgpt.com`, `api.openai.com`.

Clash DNS `use-system-hosts` becomes false to avoid a relay loop. Other sites, including `*.chatgpt.site`, use the system proxy and Clash rules. Current-user `HTTP_PROXY`, `HTTPS_PROXY`, `WS_PROXY`, `WSS_PROXY`, `ALL_PROXY`, `NODE_USE_ENV_PROXY` are set; local exclusions are merged into `NO_PROXY`. These variables may also affect other proxy-aware programs for this user.

The tool does not change application binaries, accounts, subscriptions, credentials, TUN state or startup settings. Clash must reload the script to regenerate its runtime configuration.

- **TUN:** The TCP relays do not depend on TUN, but Clash must stay running with a working node. Existing connections may reconnect when toggling modes.
- **Nodes:** Select the node inside **OpenAI 稳定连接**. Changing another group may not affect this group. A blocked or unavailable exit node still needs attention.
- **Subscriptions:** Newly created groups use all current nodes and providers. An existing group with the same name is preserved, including its candidate list; edit its original definition to add candidates. Check the selected node after updates.
- **Restart:** Files and user variables persist, but Clash must start first. Configure Clash startup yourself if desired. With Clash stopped, the six mapped domains may be unreachable until you start Clash or restore the changes.
- **Other PCs:** Copy only the public toolkit, run checks and create new local backups. Never transfer another PC's `state.json` or backups.

DNS/TLS success proves a path at the time of the check, not full authentication, message streaming, every website or long-term stability. Service restrictions on exit IPs, account issues, corporate network policies and application updates may need separate investigation.

## Restore

If your original connection requires TUN, enable it first. Click **Restore**, confirm and accept administrator consent. Then **reload/restart Clash** to regenerate its running configuration, and fully restart ChatGPT.

Only the toolkit's marked blocks are removed. Environment variables are restored only when they still equal the values installed by the toolkit; later user edits are preserved. Backups remain on disk. Modified blocks or missing backups stop automatic restoration; see [manual restoration](docs/manual-restore.md).

Local data lives in `%LOCALAPPDATA%\OpenAI\NetworkRepairKit\`: `backups`, `state.json`, and `ui-jobs`. These may contain private configuration and must not be uploaded. The menu also recognizes the earlier 20261027 repair, but its dedicated restore requires that original PC's backups, an unchanged script fingerprint and TUN enabled.

## Developer checks

Run `node test.cjs` and `node test-menu.cjs`. Isolated fixtures cover prepare/apply/restore, failures, preservation of later edits, routing and menu validation. They do not alter your live network configuration.

Optional CLI compatibility: `run.cmd status`, `prepare`, `apply`, `verify`, `restore`. CLI apply/restore require an administrator terminal; menu users do not need to type commands.
