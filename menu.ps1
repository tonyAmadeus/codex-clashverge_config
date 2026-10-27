# Loaded as a normal PowerShell command. No execution policy changes.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$Mutex=[Threading.Mutex]::new($false,('Local\OpenAIRepairMenu-'+[Security.Principal.WindowsIdentity]::GetCurrent().User.Value))
try{$Owned=$Mutex.WaitOne(0)}catch [Threading.AbandonedMutexException]{$Owned=$true}
if(-not $Owned){[Windows.Forms.MessageBox]::Show('工具已打开 / The menu is already open.','OpenAI Repair')|Out-Null;$Mutex.Dispose();return}
$Store=Join-Path $UserLocal 'OpenAI\NetworkRepairKit'
$Jobs=Join-Path $Store 'ui-jobs'
New-Item -ItemType Directory -Path $Jobs -Force | Out-Null
$script:Language='zh'
$LanguageFile=Join-Path $Store 'ui-language.txt'
if((Test-Path -LiteralPath $LanguageFile) -and (Get-Content -LiteralPath $LanguageFile -Raw).Trim() -eq 'en'){$script:Language='en'}
$Text=@{
 zh=@{title='OpenAI 原入口网络修复';intro='使用现有 Clash 转发；保留原 ChatGPT 入口，不安装网络驱动。';check='检查连接';repair='修复 / 继续修复';restore='还原';guide='使用说明';exit='退出';idle='就绪：请先启动 Clash，开启系统代理并选择规则模式。';busy='正在处理，请稍候…';wait='操作尚未完成，请等待结果后关闭窗口。';repairAsk='将备份并追加全局脚本，验证转发后再修改 hosts 和当前用户的代理变量。请暂停更新订阅。继续？';reload='准备已完成。请在 Clash 中重新加载配置或重启 Clash，在“OpenAI 稳定连接”中选择可用节点。完成后点击“确定”继续；“取消”可稍后从修复按钮继续。';restoreAsk='将撤销本工具的 hosts、脚本和代理变量。若原网络需要 TUN，请先在 Clash 打开 TUN。继续还原？';already='检测到已有修复，请使用“检查连接”，不重复安装。';noRestore='没有找到可自动还原的记录。请查看使用说明中的人工还原步骤。';failed='操作未完成，请查看下方详细信息。';cancelled='管理员授权已取消或启动失败，没有执行本次管理员操作。';verified='网络检查通过。请在 TUN 开/关两种状态下实际测试 Codex、Chat 和 Dots。';notApplied='基础检查完成；尚未启用修复，未测试 hosts 转发。';applied='配置已启用。完全退出 ChatGPT，再从原图标打开，然后检查连接。';restored='还原文件已完成。必须重载/重启 Clash 以重新生成运行配置，再重启 ChatGPT。旧版修复若要恢复原偏好，可在 Clash 重新打开“切换节点自动关闭连接”。';uac='即将请求 Windows 管理员授权；请使用当前同一 Windows 账号。';timeout='操作超时或结果丢失。不要重复点击，请先查看备份状态。'}
 en=@{title='OpenAI Original-Entry Network Repair';intro='Uses existing Clash relays; keeps the original ChatGPT entry. No network driver.';check='Check connection';repair='Repair / Resume';restore='Restore';guide='User guide';exit='Exit';idle='Ready. Start Clash, enable system proxy and select Rule mode.';busy='Working, please wait...';wait='An operation is still running. Wait for its result before closing.';repairAsk='Back up and extend the global script, validate relays, then change hosts and current-user proxy variables. Pause subscription updates. Continue?';reload='Preparation complete. Reload the configuration or restart Clash. Select a working node in OpenAI 稳定连接. Click OK when ready, or Cancel and resume later with Repair.';restoreAsk='Restore this tool''s hosts, script and proxy-variable changes. Enable TUN in Clash first if your original network needs it. Continue?';already='An existing repair was detected. Use Check connection instead of installing again.';noRestore='No automatic restore record was found. Read the manual restoration section.';failed='The operation did not complete. See details below.';cancelled='Administrator consent was cancelled or launch failed. The requested admin action did not run.';verified='Network checks passed. Test real Codex, Chat and Dots messages with TUN both off and on.';notApplied='Basic check complete. Repair is not active; hosts relays were not tested.';applied='Configuration applied. Fully exit ChatGPT, reopen its original icon, then check the connection.';restored='Files restored. REQUIRED: reload/restart Clash to regenerate its runtime config, then restart ChatGPT. For the earlier repair, re-enable automatic connection closing in Clash if you want that original preference.';uac='Requesting Windows administrator consent. Use the same Windows account.';timeout='Timed out or no result received. Check backup state before retrying.'}
}
function T($key){$Text[$script:Language][$key]}
$Form=New-Object Windows.Forms.Form
$Form.Size=New-Object Drawing.Size(860,650)
$Form.MinimumSize=$Form.Size
$Form.StartPosition='CenterScreen'
$Form.Font=New-Object Drawing.Font('Segoe UI',10)
$Intro=New-Object Windows.Forms.Label
$Intro.SetBounds(20,18,800,45)
$Form.Controls.Add($Intro)
$Lang=New-Object Windows.Forms.ComboBox
$Lang.DropDownStyle='DropDownList'
$Lang.SetBounds(620,70,200,30)
$Lang.Items.AddRange(@('中文','English'))
$Lang.SelectedIndex=if($script:Language -eq 'en'){1}else{0}
$Form.Controls.Add($Lang)
$Buttons=@{}
$x=20
foreach($name in @('check','repair','restore','guide','exit')){
 $b=New-Object Windows.Forms.Button
 $b.SetBounds($x,115,150,42)
 $Buttons[$name]=$b
 $Form.Controls.Add($b)
 $x+=162
}
$Status=New-Object Windows.Forms.Label
$Status.SetBounds(20,170,800,60)
$Form.Controls.Add($Status)
$Log=New-Object Windows.Forms.TextBox
$Log.SetBounds(20,235,800,350)
$Log.Multiline=$true;$Log.ReadOnly=$true;$Log.ScrollBars='Both';$Log.WordWrap=$false
$Log.Anchor='Top,Bottom,Left,Right'
$Log.Font=New-Object Drawing.Font('Consolas',9)
$Form.Controls.Add($Log)
$script:Running=$null
function Refresh-Language{$Form.Text=T title;$Intro.Text=T intro;foreach($k in $Buttons.Keys){$Buttons[$k].Text=T $k};if(-not $script:Running){$Status.Text=T idle}}
function Ask($key){[Windows.Forms.MessageBox]::Show($Form,(T $key),(T title),'OKCancel','Information') -eq 'OK'}
function Append-Log($s){$Log.AppendText($s+[Environment]::NewLine)}
function Set-Busy($value){foreach($k in @('check','repair','restore','exit')){$Buttons[$k].Enabled=-not $value}}
function Start-Action($action,$elevated=$false){
 if($script:Running){return}
 $id=[Guid]::NewGuid().ToString('N')
 $request=@{id=$id;action=$action;expectedLocal=$UserLocal}|ConvertTo-Json -Compress
 $request|Set-Content -LiteralPath (Join-Path $Jobs ($id+'.request.json')) -Encoding UTF8
 $encoded=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($request))
 $worker=Join-Path $Kit 'menu-worker.cjs'
 $arguments='"'+$worker+'" '+$encoded
 try{
  Set-Busy $true
  $Status.Text=if($elevated){T uac}else{T busy}
  [Windows.Forms.Application]::DoEvents()
  if($elevated){$p=Start-Process -FilePath $Node -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -PassThru}
  else{$p=Start-Process -FilePath $Node -ArgumentList $arguments -WindowStyle Hidden -PassThru}
  $script:Running=@{id=$id;action=$action;process=$p;started=[DateTime]::UtcNow;ended=$null}
 }catch{Set-Busy $false;$Status.Text=T cancelled;Append-Log $_.Exception.Message}
}
function Complete-Action($action,$result){
 if($result.output){Append-Log $result.output}
 if(-not $result.ok){$Status.Text=T failed;if($result.error){Append-Log $result.error};return}
 switch($action){
  'check'{$Status.Text=if($result.next -eq 'verified'){T verified}else{T notApplied}}
  'prepare'{if($result.next -eq 'already'){$Status.Text=T already}elseif(Ask reload){Start-Action 'apply' $true}else{$Status.Text=T idle}}
  'inspect-restore'{if(-not $result.restoreAction){$Status.Text=T noRestore}elseif(Ask restoreAsk){Start-Action $result.restoreAction $true}else{$Status.Text=T idle}}
  'apply'{$Status.Text=T applied}
  default{$Status.Text=T restored}
 }
}
$Timer=New-Object Windows.Forms.Timer
$Timer.Interval=300
$Timer.Add_Tick({
 if(-not $script:Running){return}
 $job=$script:Running
 $resultFile=Join-Path $Jobs ($job.id+'.result.json')
 if(Test-Path -LiteralPath $resultFile){
  try{$result=Get-Content -LiteralPath $resultFile -Raw -Encoding UTF8|ConvertFrom-Json}catch{$result=@{ok=$false;error=$_.Exception.Message}}
  $script:Running=$null;Set-Busy $false;Complete-Action $job.action $result
 }elseif($job.process.HasExited){
  if(-not $job.ended){$job.ended=[DateTime]::UtcNow}
  if(([DateTime]::UtcNow-$job.ended).TotalSeconds -gt 3){$script:Running=$null;Set-Busy $false;$Status.Text=T failed;Append-Log ('Worker exit: '+$job.process.ExitCode)}
 }elseif(([DateTime]::UtcNow-$job.started).TotalSeconds -gt 200){
  # Keep mutations locked while a worker still exists; do not start a second job.
  $Status.Text=T timeout
 }
})
$Buttons.check.Add_Click({Start-Action 'check'})
$Buttons.repair.Add_Click({if(Ask repairAsk){Start-Action 'prepare'}})
$Buttons.restore.Add_Click({Start-Action 'inspect-restore'})
$Buttons.guide.Add_Click({
 $file=if($script:Language -eq 'zh'){'README.md'}else{'README.en.md'}
 $Help=New-Object Windows.Forms.Form;$Help.Text=T guide;$Help.Size=New-Object Drawing.Size(800,650);$Help.StartPosition='CenterParent'
 $Body=New-Object Windows.Forms.TextBox;$Body.Dock='Fill';$Body.Multiline=$true;$Body.ReadOnly=$true;$Body.ScrollBars='Vertical';$Body.Font=New-Object Drawing.Font('Segoe UI',10)
 $Body.Text=[IO.File]::ReadAllText((Join-Path $Kit $file));$Help.Controls.Add($Body);[void]$Help.ShowDialog($Form);$Help.Dispose()
})
$Buttons.exit.Add_Click({$Form.Close()})
$Lang.Add_SelectedIndexChanged({$script:Language=if($Lang.SelectedIndex -eq 1){'en'}else{'zh'};$script:Language|Set-Content -LiteralPath $LanguageFile -Encoding ASCII;Refresh-Language})
$Form.Add_FormClosing({param($sender,$eventArgs)if($script:Running){$eventArgs.Cancel=$true;[Windows.Forms.MessageBox]::Show($Form,(T wait),(T title))|Out-Null}})
Refresh-Language
$Timer.Start()
[void]$Form.ShowDialog()
$Timer.Dispose()
$Form.Dispose()
$Mutex.ReleaseMutex();$Mutex.Dispose()
