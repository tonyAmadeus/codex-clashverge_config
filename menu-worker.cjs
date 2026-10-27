const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const allowed=new Set(['check','prepare','inspect-restore','apply','restore','restore-this-pc']);
function inspect(env=process.env){
 const root=path.join(env.LOCALAPPDATA,'OpenAI','NetworkRepairKit'),statePath=path.join(root,'state.json');
 const state=fs.existsSync(statePath)?JSON.parse(fs.readFileSync(statePath,'utf8')):null;
 const hosts=fs.readFileSync(path.join(env.SystemRoot,'System32','drivers','etc','hosts'),'utf8');
 const legacy=hosts.includes('BEGIN OpenAI native Clash relay 20261027');
 return {phase:state?.phase||'none',legacy,restoreAction:state&&state.phase!=='restored'?'restore':legacy?'restore-this-pc':null};
}
function preparationPlan(state){if(state.legacy||state.phase==='applied')return'already';if(state.phase==='prepared')return'continue';if(state.phase==='applying')throw Error('An earlier apply was interrupted. Restore first.');if(!['none','restored'].includes(state.phase))throw Error('Unknown backup state. Review before making changes.');return'prepare';}
async function cli(command){return new Promise(resolve=>cp.execFile(process.execPath,[path.join(__dirname,'repair.cjs'),command],{windowsHide:true,encoding:'utf8',timeout:90000,maxBuffer:2*1024*1024},(error,stdout,stderr)=>resolve({ok:!error,output:[stdout,stderr].filter(Boolean).join('\n'),error:error?.message||null})));}
async function action(command,dependencies={inspect,cli}){
 if(!allowed.has(command))throw Error('Unsupported menu action');
 if(command==='inspect-restore'){const state=dependencies.inspect();return{ok:true,...state,output:''};}
 if(command==='prepare'){
  const plan=preparationPlan(dependencies.inspect());if(plan==='already')return{ok:true,next:'already',output:''};if(plan==='continue')return{ok:true,next:'apply',output:''};
  const result=await dependencies.cli('prepare');return{...result,next:result.ok?'apply':null};
 }
 if(command==='check'){
  const state=dependencies.inspect(),report=await dependencies.cli('status');if(!report.ok)return report;
  if(state.phase==='applied'||state.legacy){const verification=await dependencies.cli('verify');return{...verification,output:report.output+'\n'+verification.output,next:verification.ok?'verified':null};}
  return{...report,next:'not-applied'};
 }
 return dependencies.cli(command);
}
async function runJob(encoded){
 const job=JSON.parse(Buffer.from(encoded,'base64').toString('utf8'));
 if(!allowed.has(job.action)||!/^[a-f0-9]{32}$/.test(job.id))throw Error('Invalid job');
 const expected=path.resolve(job.expectedLocal),actual=path.resolve(process.env.LOCALAPPDATA);
 const jobRoot=path.join(expected,'OpenAI','NetworkRepairKit','ui-jobs');
 // Output path is derived, never accepted as an arbitrary elevated write target.
 if(path.basename(expected).toLowerCase()!=='local')throw Error('Unexpected user profile layout');
 if(!fs.existsSync(path.join(jobRoot,job.id+'.request.json')))throw Error('Missing request file');
 const resultPath=path.join(jobRoot,job.id+'.result.json');let result;
 try{if(expected.toLowerCase()!==actual.toLowerCase())throw Error('Administrator account differs from the initiating Windows user. No changes made.');result=await action(job.action);}catch(e){result={ok:false,error:e.message,output:''};}
 const temp=resultPath+'.tmp';fs.writeFileSync(temp,JSON.stringify(result));fs.renameSync(temp,resultPath);
}
module.exports={inspect,preparationPlan,action,allowed};
if(require.main===module)runJob(process.argv[2]).catch(e=>{console.error(e.message);process.exitCode=1;});
