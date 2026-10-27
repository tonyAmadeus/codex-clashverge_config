const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
function encodedMenu(root,node,local){
 const quote=s=>"'"+s.replace(/'/g,"''")+"'";
 const source='$Kit='+quote(root)+'; $Node='+quote(node)+'; $UserLocal='+quote(local)+';\n'+fs.readFileSync(path.join(root,'menu.ps1'),'utf8');
 const encoded=Buffer.from(source,'utf16le').toString('base64');if(encoded.length>30000)throw Error('Menu exceeds the Windows command-line limit');return encoded;
}
// Hide the PowerShell console, but keep the child attached: hiding/detaching the
// entire child at creation can also hide the first WinForms window on Windows.
function launch(){if(process.platform!=='win32')throw Error('This menu requires Windows');const exe=path.join(process.env.SystemRoot,'System32','WindowsPowerShell','v1.0','powershell.exe');const encoded=encodedMenu(__dirname,process.execPath,process.env.LOCALAPPDATA);const p=cp.spawn(exe,['-NoProfile','-STA','-WindowStyle','Hidden','-EncodedCommand',encoded],{windowsHide:false,stdio:'inherit'});p.on('error',e=>{console.error(e.message);process.exitCode=1;});p.on('exit',code=>{process.exitCode=code??1;});}
module.exports={encodedMenu};if(require.main===module)launch();
