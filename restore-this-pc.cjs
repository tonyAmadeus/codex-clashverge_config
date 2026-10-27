// Only restores the repair performed on 2026-10-27 using its LOCAL backups.
// This file contains no personal backup, subscription or credentials.
const fs=require('fs'),path=require('path');
exports.run=async function(h){
 h.requireAdmin();
 const base=path.join(process.env.APPDATA,'io.github.clash-verge-rev.clash-verge-rev');
 const root=path.join(process.env.LOCALAPPDATA,'OpenAI','NetworkRepair','native-relay-20261027');
 const first=path.join(process.env.LOCALAPPDATA,'Codex','network-repair-20261027-0950','profiles','Script.js');
 const envBackup=path.join(process.env.LOCALAPPDATA,'OpenAI','NetworkRepair','direct-20261027-110904','environment-backup.json');
 const script=path.join(base,'profiles','Script.js'),hosts=path.join(process.env.SystemRoot,'System32','drivers','etc','hosts');
 const original=fs.readFileSync(first),current=fs.readFileSync(script),envRecord=JSON.parse(fs.readFileSync(envBackup,'utf8').replace(/^\uFEFF/,''));
 if(h.hash(current)!=='754ea98e02550dc341cb5a8a8e51df34624cff63f256335506bcb1b1abd01177')throw Error('Current global script has changed. Refusing an entire-file restore; use the manual instructions to preserve later edits.');
 if(h.utf8(original).replace(/\r/g,'').trim()!=='// Define main function (script entry)\n\nfunction main(config, profileName) {\n  return config;\n}')throw Error('Unexpected original backup; review manually.');
 const core=await h.api('/configs');if(!core.tun?.enable)throw Error('Turn TUN ON in Clash first, then run restore-this-pc. This avoids disconnecting before the old configuration is restored.');
 const currentHosts=fs.readFileSync(hosts),text=h.utf8(currentHosts);
 const owned=/\r?\n# BEGIN OpenAI native Clash relay 20261027\r?\n127\.0\.0\.11 codex-cloud-backend\.chatgpt\.com\r?\n127\.0\.0\.12 chatgpt\.com\r?\n127\.0\.0\.13 ws\.chatgpt\.com\r?\n127\.0\.0\.14 ab\.chatgpt\.com\r?\n127\.0\.0\.15 codex-cloud-environments\.chatgpt\.com\r?\n127\.0\.0\.16 api\.openai\.com\r?\n# END OpenAI native Clash relay 20261027\r?\n/;
 if(!owned.test(text))throw Error('Expected hosts block changed/missing; review manually.');
 const envNow=h.userEnv(),undo={};for(const name of ['HTTP_PROXY','HTTPS_PROXY','ALL_PROXY','WS_PROXY','WSS_PROXY','NO_PROXY','NODE_USE_ENV_PROXY'])if(envNow[name]===envRecord.Applied[name])undo[name]=envRecord.Before[name];
 const saved=path.join(root,'before-restore-'+Date.now());fs.mkdirSync(saved);fs.writeFileSync(path.join(saved,'Script.js'),current);fs.writeFileSync(path.join(saved,'hosts'),currentHosts);fs.writeFileSync(path.join(saved,'environment.json'),JSON.stringify(envNow,null,2));
 if(h.hash(fs.readFileSync(script))!==h.hash(current)||h.hash(fs.readFileSync(hosts))!==h.hash(currentHosts))throw Error('Files changed during review');
 fs.writeFileSync(hosts,Buffer.from(text.replace(owned,'')));h.setEnv(undo);fs.writeFileSync(script,original);h.flushDns();
 console.log('Original script, owned hosts block and unchanged proxy environment settings restored. Reload/restart Clash to regenerate configuration, then restart ChatGPT. Keep TUN ON if needed. To restore the old preference exactly, enable auto-close connections on node changes in Clash settings. Subscription data was not replaced.');
};
