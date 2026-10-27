// BEGIN OPENAI_NATIVE_RELAY_KIT_V1
// Append this block to the EXISTING global Script.js. Do not replace its main().
;(function () {
  if (typeof main !== 'function') throw new Error('An existing main(config) is required');
  const previousMain = main;
  main = function (config) {
    config = previousMain.apply(this, arguments);
    if (!config || typeof config !== 'object') throw new Error('Original main returned no config');
    const group = 'OpenAI 稳定连接';
    const pairs = [
      ['127.0.0.11', 'codex-cloud-backend.chatgpt.com'],
      ['127.0.0.12', 'chatgpt.com'],
      ['127.0.0.13', 'ws.chatgpt.com'],
      ['127.0.0.14', 'ab.chatgpt.com'],
      ['127.0.0.15', 'codex-cloud-environments.chatgpt.com'],
      ['127.0.0.16', 'api.openai.com']
    ];
    config['proxy-groups'] = config['proxy-groups'] || [];
    if (!config['proxy-groups'].some(g => g.name === group)) {
      const nodes = Array.from(new Set((config.proxies || []).map(p => p.name).filter(Boolean)));
      const providers = Object.keys(config['proxy-providers'] || {});
      if (!nodes.length && !providers.length) throw new Error('No subscription nodes/providers');
      const selector = {name: group, type: 'select', proxies: nodes};
      if (providers.length) selector.use = providers;
      config['proxy-groups'].unshift(selector);
    }
    const rules = ['chatgpt.site','chatgpt.com','openai.com','oaistatic.com','oaiusercontent.com']
      .map(d => 'DOMAIN-SUFFIX,' + d + ',' + group);
    rules.push('PROCESS-NAME,codex.exe,' + group, 'PROCESS-NAME,ChatGPT.exe,' + group);
    config.rules = rules.concat((config.rules || []).filter(r => !rules.includes(r)));
    config.tunnels = config.tunnels || [];
    for (const [ip, host] of pairs) {
      const address = ip + ':443', target = host + ':443';
      for (const tunnel of config.tunnels) {
        const a = typeof tunnel === 'string' ? tunnel.split(',')[1]?.trim() : tunnel.address;
        if (['0.0.0.0:443', ':443', '[::]:443'].includes(a)) throw new Error('Wildcard port 443 conflict');
        if (a === address && (typeof tunnel === 'string' || tunnel.target !== target || tunnel.proxy !== group)) {
          throw new Error('Existing tunnel conflict: ' + address);
        }
      }
      if (!config.tunnels.some(t => typeof t === 'object' && t.address === address)) {
        config.tunnels.push({network:['tcp'], address, target, proxy:group});
      }
    }
    config.dns = config.dns || {};
    config.dns['use-system-hosts'] = false;
    return config;
  };
})();
// END OPENAI_NATIVE_RELAY_KIT_V1
