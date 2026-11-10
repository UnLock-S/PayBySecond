// Optional browser verification. Install tooling into .local, not the app:
// npm install --prefix .local/qa playwright@1.65.0 --no-save --ignore-scripts
const assert=require('node:assert/strict');
const path=require('node:path');
const fs=require('node:fs');
const {createRequire}=require('node:module');
const root=path.resolve(__dirname,'../..');
const localRequire=createRequire(path.join(root,'.local/qa/package.json'));
const {chromium}=localRequire('playwright');
const baseUrl=process.env.PBS_TEST_URL||'http://127.0.0.1:7357';
const output=path.join(root,'out/reports/browser');fs.mkdirSync(output,{recursive:true});
const translations={
 zh:{start:'开始设置',salaryInput:'月薪（人民币）',dateInput:'入职日期',next:'下一步',finish:'开始查看收入',settings:'设置',salary:'薪资信息',calculation:'计算方式',schedule:'工作时间',calendar:'休假与补班',display:'显示偏好',language:'语言',data:'数据与说明',licenses:'开源许可',back:'返回',headline:'让每一秒，有所积累。',hide:'隐藏金额',show:'显示金额'},
 en:{settings:'Settings',salary:'Salary',calculation:'Calculation',schedule:'Work schedule',calendar:'Days off & make-up work',display:'Display',language:'Language',data:'Data & information',licenses:'Open-source licenses',back:'Back',headline:'Every second adds up.',hide:'Hide amounts',show:'Show amounts'},
 ja:{settings:'設定',salary:'給与情報',calculation:'計算方式',schedule:'勤務時間',calendar:'休日・振替出勤',display:'表示設定',language:'言語',data:'情報・データ',licenses:'利用許諾',back:'戻る',headline:'毎秒、積み重なる収入。',hide:'金額非表示',show:'金額表示'},
};
function escapeRegex(s){return s.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');}
async function boot(page){await page.goto(baseUrl);const placeholder=page.locator('flt-semantics-placeholder');await placeholder.waitFor({state:'attached',timeout:30000});await placeholder.evaluate(e=>e.click());}
async function clickButton(page,name,exact=true){await page.getByRole('button',{name:exact?name:new RegExp('^'+escapeRegex(name)),exact}).click();}
async function back(page,lang){await clickButton(page,translations[lang].back,false);}
async function fill(page,name,value){await page.getByRole('textbox',{name,exact:true}).click();await page.keyboard.press('ControlOrMeta+A');await page.keyboard.type(value,{delay:15});await page.keyboard.press('Tab');}
async function snapshot(page,name){await page.mouse.move(0,0);await page.waitForTimeout(350);await page.screenshot({path:path.join(output,name+'.png')});}
(async()=>{
 let browser,page;const errors=[],remoteFonts=[],updateRequests=[];
 try{
  browser=await chromium.launch({channel:process.env.PBS_BROWSER_CHANNEL||'msedge',headless:true});
  async function context(options){const c=await browser.newContext(options);await c.route(/https:\/\/fonts\.(googleapis|gstatic)\.com\//,route=>{remoteFonts.push(route.request().url());return route.abort();});c.on('page',p=>{p.on('pageerror',e=>errors.push(e.message));p.on('request',r=>{if(r.url().startsWith('https://api.github.com/'))updateRequests.push(r.url());});});return c;}
  const desktop=await context({viewport:{width:1365,height:1000}});page=await desktop.newPage();await boot(page);
  await clickButton(page,translations.zh.start);
  await fill(page,translations.zh.salaryInput,'20000');await fill(page,translations.zh.dateInput,'20260101');
  await clickButton(page,translations.zh.next);
  await page.getByRole('textbox').first().waitFor({state:'detached'});
  assert.equal(await page.getByRole('textbox').count(),0,'Calculation step excludes salary fields');
  await clickButton(page,translations.zh.next);
  assert.equal(await page.evaluate(()=>Object.keys(localStorage).some(k=>k.endsWith('pay_by_second.profile.v2'))),false,'Draft stays unsaved until confirmation');
  await clickButton(page,translations.zh.finish);
  await page.getByRole('button',{name:translations.zh.settings,exact:true}).waitFor();
  const profile=await page.evaluate(()=>localStorage.getItem(Object.keys(localStorage).find(k=>k.endsWith('pay_by_second.profile.v2'))));
  assert(profile&&profile.includes('20000'));
  const balance=page.getByText(/^CN¥ /).first();const before=await balance.innerText();await page.waitForTimeout(1400);assert.notEqual(await balance.innerText(),before);
  await clickButton(page,translations.zh.hide);await page.getByText('••••••',{exact:true}).first().waitFor();
  await clickButton(page,translations.zh.show,false);await balance.waitFor();
  let current='zh';
  for(const lang of ['zh','en','ja']){
   if(current!==lang){
    await clickButton(page,translations[current].settings);
    await clickButton(page,translations[current].language,false);
    await page.getByRole('radio',{name:{en:'English',ja:'日本語'}[lang],exact:true}).click();
    await page.getByText(translations[lang].headline,{exact:true}).waitFor();
    current=lang;
   }
   await page.getByText(translations[lang].headline,{exact:true}).waitFor();
   assert.equal(await page.locator('html').getAttribute('lang'),lang);
   await snapshot(page,'dashboard-desktop-'+lang);
   await clickButton(page,translations[lang].settings);
   await snapshot(page,'settings-desktop-'+lang);
   for(const section of ['salary','calculation','schedule','calendar','display']){
    await clickButton(page,translations[lang][section],false);
    await page.getByText(translations[lang][section],{exact:true}).first().waitFor();
    if(section==='salary')await snapshot(page,'salary-desktop-'+lang);
    await back(page,lang);
   }
   const updateText=JSON.parse(fs.readFileSync(path.join(root,'src/apps/pay_by_second/lib/l10n/app_'+lang+'.arb'),'utf8'));
   await clickButton(page,updateText.softwareUpdate,false);
   await page.getByText(updateText.updateWebHelp,{exact:true}).waitFor();
   assert(await page.getByRole('button',{name:updateText.updateCheckNow,exact:true}).isDisabled());
   await snapshot(page,'updates-desktop-'+lang);await back(page,lang);
   await clickButton(page,translations[lang].data,false);
   await clickButton(page,translations[lang].licenses);
   await back(page,lang);await back(page,lang);await back(page,lang);
   await boot(page);await page.getByText(translations[lang].headline,{exact:true}).waitFor();
   const profileAfter=await page.evaluate(()=>localStorage.getItem(Object.keys(localStorage).find(k=>k.endsWith('pay_by_second.profile.v2'))));
   assert.equal(profileAfter,profile,'Language and navigation must not rewrite salary');
   const mobile=await context({viewport:{width:390,height:844},deviceScaleFactor:1,isMobile:true,hasTouch:true,storageState:await desktop.storageState()});
   const phone=await mobile.newPage();await boot(phone);await phone.getByText(translations[lang].headline,{exact:true}).waitFor();await snapshot(phone,'dashboard-mobile-'+lang);
   await clickButton(phone,translations[lang].settings);
   await snapshot(phone,'settings-mobile-'+lang);
   await clickButton(phone,translations[lang].salary,false);await phone.getByRole('textbox').first().waitFor();await snapshot(phone,'salary-mobile-'+lang);
   await back(phone,lang);await clickButton(phone,updateText.softwareUpdate,false);
   await phone.getByText(updateText.updateWebHelp,{exact:true}).waitFor();await snapshot(phone,'updates-mobile-'+lang);
   await mobile.close();
  }
  // New overtime flow uses the Japanese UI left by the locale regression loop.
  const ot=JSON.parse(fs.readFileSync(path.join(root,'src/apps/pay_by_second/lib/l10n/app_ja.arb'),'utf8'));
  const ledger=()=>page.evaluate(()=>{
   const key=Object.keys(localStorage).find(k=>k.endsWith('pay_by_second.overtime.v2'));
   if(!key)return null;
   let value=JSON.parse(localStorage.getItem(key));
   value=typeof value==='string'?JSON.parse(value):value; return value.payload;
  });
  await clickButton(page,ot.otStart);
  await page.getByText(ot.otSettings,{exact:true}).waitFor();
  await snapshot(page,'overtime-setup-desktop-ja');
  await clickButton(page,ot.otSaveStart);
  await page.getByRole('button',{name:ot.otStop,exact:true}).waitFor();
  const started=await ledger();assert(started.active);assert.equal(started.active.policy.pay,'unpaid');
  await page.waitForTimeout(1200);
  await page.getByText(/上司の幸福度/).waitFor();
  await boot(page);await page.getByRole('button',{name:ot.otStop,exact:true}).waitFor();
  assert.equal((await ledger()).active.id,started.active.id,'Reload restores the same active session');
  await snapshot(page,'overtime-active-desktop-ja');
  await clickButton(page,ot.otStop);await page.getByRole('button',{name:ot.otStart,exact:true}).waitFor();
  const stopped=await ledger();assert.equal(stopped.active,null);assert.equal(stopped.entries.length,1);
  await clickButton(page,ot.otStart);await page.getByRole('button',{name:ot.otStop,exact:true}).waitFor();
  assert.equal((await ledger()).active.id,started.active.id+1,'Subsequent start is one tap');
  await clickButton(page,ot.otDetails);
  await snapshot(page,'overtime-history-desktop-ja');
  await clickButton(page,ot.otSettings);
  await page.getByRole('textbox',{name:ot.otBase,exact:true}).waitFor();
  await page.waitForTimeout(350);
  await page.getByText(ot.otUnpaid,{exact:false}).click();
  await page.waitForTimeout(350);
  await page.keyboard.press('ArrowDown');await page.keyboard.press('ArrowDown');await page.keyboard.press('ArrowDown');await page.keyboard.press('Enter');
  await fill(page,ot.otMultiplier,'2.5');
  await clickButton(page,ot.otSaveDefaults);
  const configured=await ledger();assert.equal(configured.policy.multiplier,250);
  assert.equal(configured.active.policy.pay,'unpaid','Defaults do not rewrite the active snapshot');
  await back(page,'ja');await clickButton(page,ot.otStop);
  const mobileOT=await context({viewport:{width:390,height:844},deviceScaleFactor:1,isMobile:true,hasTouch:true,storageState:await desktop.storageState()});
  const otPhone=await mobileOT.newPage();await boot(otPhone);
  await clickButton(otPhone,ot.otStart);await otPhone.getByRole('button',{name:ot.otStop,exact:true}).waitFor();
  await snapshot(otPhone,'overtime-active-mobile-ja');
  await clickButton(otPhone,ot.otDetails);await snapshot(otPhone,'overtime-history-mobile-ja');
  await clickButton(otPhone,ot.otSettings);await snapshot(otPhone,'overtime-settings-mobile-ja');
  await mobileOT.close();
  assert.deepEqual(updateRequests,[],'Web must not query APK updates automatically');
  assert.deepEqual(errors,[]);assert.deepEqual(remoteFonts,[],'Bundled SC/JP fonts avoid remote fallback');
  const report={status:'PASS',browser:await browser.version(),locales:['zh','en','ja'],viewports:['1365x1000','390x844'],checks:['staged setup','explicit first save','live income','privacy mask','five independent categories','license navigation','locale persistence','HTML language','salary unchanged by language','desktop and mobile rendering','local SC/JP fonts','flexible date input','language automatically returns home','overtime start/stop and reload recovery','custom multiplier and immutable snapshots','overtime desktop/mobile rendering','three-language update pages','no automatic APK checks on Web'],errors,remoteFonts,updateRequests};
  fs.writeFileSync(path.join(output,'result.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report,null,2));
 }catch(e){if(page&&!page.isClosed()){await page.screenshot({path:path.join(output,'failure.png')});console.error((await page.locator('body').innerText()).slice(-4000));}throw e;}
 finally{await browser?.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
