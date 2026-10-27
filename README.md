# OpenAI 原入口网络修复工具包

[English](README.en.md) · Windows / Clash Verge Rev / Mihomo

双击 **`run.cmd`** 打开窗口，在 **中文 / English** 下拉框中切换语言，通过按钮执行 **检查连接、修复 / 继续修复、还原、使用说明**。日常操作无需输入命令。底层诊断日志保留英文原文。

用于排查和处理使用 Clash 时，ChatGPT 桌面端的 Codex、Chat、Dots 断线、反复重连，以及相关站点访问异常。使用现有 Clash 核心的本地 TCP 转发，保留原应用图标和登录入口；不安装 ProxiFyre、网络驱动或新快捷方式。

## 下载与运行

1. 在 GitHub 点击 **Code → Download ZIP**，完整解压到本地文件夹。不要在压缩包里直接运行。
2. 启动 Clash Verge Rev，开启 **系统代理**，使用 **规则模式**，确保订阅中有可用节点。
3. 双击 `run.cmd`。首次运行默认中文，可随时切换 English。
4. 先点 **检查连接**。尚未修复时只执行基础检查；检测到已安装修复后，会检查 6 个域名的 DNS 与 TLS。

需要 Windows、Windows PowerShell 5.1、Clash Verge Rev 默认用户配置目录，以及可用的 Node.js（建议受支持的 LTS 版本）。启动器会先查找 PATH 中的 Node.js，再查找 ChatGPT 附带的运行时；找不到时会提示，不会自动安装。请在同一 Windows 账号中操作。写入 hosts 时需要管理员权限；若 UAC 要求输入另一个管理员账号，本工具会拒绝跨账号应用配置。

适配目录：`%APPDATA%\io.github.clash-verge-rev.clash-verge-rev`。需要唯一运行的 Clash Verge Rev Mihomo 核心及其命名管道控制接口。其它 Clash 客户端、便携版或定制目录不能保证兼容。

## 修复流程

1. 点击 **修复 / 继续修复**，确认后创建本机备份，并在全局 `profiles\Script.js` 末尾追加脚本。此时不修改 hosts 或代理环境变量。
2. 按窗口提示，**重新加载 Clash 配置或重启 Clash**。在 **OpenAI 稳定连接** 分组中选一个可用节点，然后回到工具点击“确定”。也可取消，稍后点击修复继续。
3. 接受 Windows 管理员授权。工具先验证 6 条本地转发的真实域名 TLS 证书，通过后才写入 hosts 和当前用户的代理环境变量。
4. 完全退出 ChatGPT，再从原图标打开；点击 **检查连接**。
5. 分别在 TUN 关闭、开启时，在 Codex、Chat、Dots 中实际发送消息，确认完整回复，并打开需要访问的站点。

修复期间暂停订阅更新和配置编辑。遇到已有自定义 hosts、冲突环境变量、转发端口占用、非预期脚本或缺失备份时，工具会停止，详细原因显示在日志中。不要反复点击强行覆盖。已有修复会被识别，不重复安装。

## 更改了什么

| 内容 | 更改 |
| --- | --- |
| Clash 全局脚本 | 保留原 `main` 的调用和参数，追加 OpenAI 分流规则、分组及 6 条本地 TCP 转发 |
| 本地转发 | `127.0.0.11` 至 `127.0.0.16` 的 443 端口分别转发到下列域名的 443 端口 |
| hosts | 追加带 `OPENAI_NATIVE_RELAY_KIT_V1` 标记的 6 个域名映射 |
| Clash DNS | 设置 `use-system-hosts: false`，避免核心把上游域名重新解析回本地转发而形成循环 |
| 当前用户环境 | 设置 `HTTP_PROXY`、`HTTPS_PROXY`、`WS_PROXY`、`WSS_PROXY`、`ALL_PROXY`、`NODE_USE_ENV_PROXY`，合并本地地址到 `NO_PROXY` |

域名依次为：`codex-cloud-backend.chatgpt.com`、`chatgpt.com`、`ws.chatgpt.com`、`ab.chatgpt.com`、`codex-cloud-environments.chatgpt.com`、`api.openai.com`。其它站点（包括 `*.chatgpt.site`）通过系统代理和 Clash 分流规则访问，不加入这 6 条 hosts 映射。

环境变量对当前用户的其它支持代理的程序也可能生效，不限于 ChatGPT。工具不修改应用文件、登录信息、订阅地址或节点凭据，不强制切换 TUN，不自动设置开机启动。全局脚本产生的运行配置需由 Clash 重载生成。

## 切换节点、订阅更新、重启与 TUN

- **切换 TUN**：这些本地 TCP 转发本身不依赖 TUN；仍需 Clash 核心运行、系统代理开启及可用节点。切换时已有连接可能短暂重建。
- **切换节点**：在“OpenAI 稳定连接”中选择。其它总分组的选择不一定影响此分组。节点不可达、服务限制或连接中断无法靠脚本保证消除。
- **更新订阅**：新建的分组会从当前配置中的全部节点及 provider 生成。若已经有同名分组，工具保留它，不覆盖其节点列表；需要在原分组定义中调整候选节点。更新后检查选中节点是否仍存在。
- **重启电脑**：脚本、hosts、用户环境变量保留，但 Clash 必须先启动。可自行开启 Clash 开机启动并检查系统代理。没有 Clash 时，这 6 个映射域名可能无法访问；可启动 Clash 或按下面步骤还原。
- **换电脑**：只复制公开工具文件，在新电脑重新检查、修复并生成当地备份。不要复制旧电脑的备份或 `state.json`。

网络检查通过只证明当时 DNS 和 TLS 通路可用，不代表完整登录、消息流、所有站点或长期稳定性。出口 IP 被服务拒绝、账号问题、公司网络策略和应用升级需要另外排查。本方案并非 OpenAI 或 Clash 官方修复工具。

## 还原

1. 如果原来的网络依赖 TUN，请先在 Clash 中打开 TUN，避免还原后失去连接。
2. 双击 `run.cmd` → **还原** → 确认并接受管理员授权。
3. **必须重新加载配置或重启 Clash**，让运行配置去掉本地转发；再完全退出并重新打开 ChatGPT。

工具仅撤销自身添加的标记块；环境变量只有仍等于本工具写入值时才还原，保留用户之后的修改。备份保留在本机，不自动删除。若标记块被修改或备份丢失，会停止自动还原，参见 [人工还原说明](docs/manual-restore.md)。

备份和状态：`%LOCALAPPDATA%\OpenAI\NetworkRepairKit\`，其中 `backups` 保存每次安装前的文件，`state.json` 记录阶段和环境变量，`ui-jobs` 保存本地菜单日志。它们可能包含私人配置，请勿上传到 GitHub。

菜单也兼容本项目早期的 `20261027` 修复：只在原电脑有对应本地备份、脚本指纹匹配且 TUN 开启时允许专用还原。其它电脑不应使用这份历史还原逻辑。

## 开发与验证

可选命令行：`run.cmd status`、`prepare`、`apply`、`verify`、`restore`。命令行的 apply/restore 需自行使用管理员终端，普通用户直接使用菜单即可。

```text
node test.cjs
node test-menu.cjs
```

测试使用临时目录和模拟接口，覆盖脚本幂等、保留订阅和后续编辑、冲突阻止、准备/应用/还原、TLS 失败、环境写入失败、历史修复保护，以及菜单路由、语言资源和 PowerShell 语法。测试不会修改正在使用的网络配置。
