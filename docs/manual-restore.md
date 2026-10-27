# 人工还原 / Manual restoration

优先使用菜单“还原”。以下用于备份缺失或自动还原被保护检查阻止的情况；不要把整份旧配置覆盖回去，以免丢失之后的订阅或其它修改。

Prefer **Restore** in the menu. Use these steps when backup data is missing or automatic restoration stops. Do not replace entire current configurations with old copies.

1. 如果原网络依赖 TUN，先打开 TUN；另行保存当前 hosts、全局脚本和当前用户环境变量。 / Enable TUN if your original connection needs it. Save current hosts, the global script and user environment variables first.
2. 在管理员权限的文本编辑器中打开 `%SystemRoot%\System32\drivers\etc\hosts`，仅删除 `# BEGIN OPENAI_NATIVE_RELAY_KIT_V1` 至对应 `# END OPENAI_NATIVE_RELAY_KIT_V1` 的完整块。历史版本使用 `# BEGIN OpenAI native Clash relay 20261027` / `# END OpenAI native Clash relay 20261027`。不要删除其它条目。 / With an elevated editor, remove only the matching complete marker block; preserve all other entries.
3. 在 Clash 全局脚本 `%APPDATA%\io.github.clash-verge-rev.clash-verge-rev\profiles\Script.js` 中，仅删除 `BEGIN OPENAI_NATIVE_RELAY_KIT_V1` 到 `END OPENAI_NATIVE_RELAY_KIT_V1` 的追加脚本块。保留原来的 main 函数及其它编辑。如果标记已损坏，先对照本机 `backups` 中的 `Script.before.js` 与 `owned-patch.js`，不要直接全量替换。历史版本无通用脚本标记，应对照原电脑备份逐项处理。 / Remove only the appended marked script block. Compare local backups if markers were edited; older repairs require manual comparison with their original backups.
4. 打开 Windows“编辑账户的环境变量”，对照本机 `state.json` 的 `envBefore` 与 `envApplied`。仅对仍等于本工具写入值的变量还原旧值；原来不存在的才删除。涉及 HTTP_PROXY、HTTPS_PROXY、ALL_PROXY、WS_PROXY、WSS_PROXY、NO_PROXY、NODE_USE_ENV_PROXY。没有备份且不清楚原值时，不要猜测删除共享设置。 / Use Windows user environment settings and compare envBefore/envApplied. Restore only unchanged toolkit values. Do not guess previous shared settings if backups are missing.
5. 重新加载配置或重启 Clash，完全退出并重新打开 ChatGPT。重启 Windows 可清除旧进程环境及 DNS 缓存。检查原入口和原网络是否恢复。 / Reload/restart Clash and fully restart ChatGPT. A Windows restart also clears old process environments and DNS cache. Test the original entry and network.

人工处理后不要伪造 `state.json` 的阶段来强制继续自动安装；保留本机备份供核对，必要时审查并归档这次安装记录后再重新准备。

After manual changes, do not fabricate a state phase to force automatic installation. Retain and review the local backup records before starting a new installation.
