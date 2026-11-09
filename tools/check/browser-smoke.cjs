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
 let browser,page;const errors=[],remoteFonts=[];
 try{
  browser=await chromium.launch({channel:process.env.PBS_BROWSER_CHANNEL||'msedge',headless:true});
  async function context(options){const c=await browser.newContext(options);await c.route(/https:\/\/fonts\.(googleapis|gstatic)\.com\//,route=>{remoteFonts.push(route.request().url());return route.abort();});c.on('page',p=>p.on('pageerror',e=>errors.push(e.message)));return c;}
  const desktop=await context({viewport:{width:1365,height:1000}});page=await desktop.newPage();await boot(page);
  await clickButton(page,translations.zh.start);
  await fill(page,translations.zh.salaryInput,'20000');await fill(page,translations.zh.dateInput,'2026-01-01');
  await clickButton(page,translations.zh.next);
  assert.equal(await page.getByRole('textbox').count(),0,'Calculation step excludes salary fields');
  await clickButton(page,translations.zh.next);
  assert.equal(await page.evaluate(()=>Object.keys(localStorage).some(k=>k.endsWith('pay_by_second.profile.v1'))),false,'Draft stays unsaved until confirmation');
  await clickButton(page,translations.zh.finish);
  await page.getByRole('button',{name:translations.zh.settings,exact:true}).waitFor();
  const profile=await page.evaluate(()=>localStorage.getItem(Object.keys(localStorage).find(k=>k.endsWith('pay_by_second.profile.v1'))));
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
    await page.getByText(translations[lang].language,{exact:true}).first().waitFor();
    await back(page,lang);await back(page,lang);current=lang;
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
   await clickButton(page,translations[lang].data,false);
   await clickButton(page,translations[lang].licenses);
   await back(page,lang);await back(page,lang);await back(page,lang);
   await boot(page);await page.getByText(translations[lang].headline,{exact:true}).waitFor();
   const profileAfter=await page.evaluate(()=>localStorage.getItem(Object.keys(localStorage).find(k=>k.endsWith('pay_by_second.profile.v1'))));
   assert.equal(profileAfter,profile,'Language and navigation must not rewrite salary');
   const mobile=await context({viewport:{width:390,height:844},deviceScaleFactor:1,isMobile:true,hasTouch:true,storageState:await desktop.storageState()});
   const phone=await mobile.newPage();await boot(phone);await phone.getByText(translations[lang].headline,{exact:true}).waitFor();await snapshot(phone,'dashboard-mobile-'+lang);
   await clickButton(phone,translations[lang].settings);
   await snapshot(phone,'settings-mobile-'+lang);
   await clickButton(phone,translations[lang].salary,false);await phone.getByRole('textbox').first().waitFor();await snapshot(phone,'salary-mobile-'+lang);
   await mobile.close();
  }
  assert.deepEqual(errors,[]);assert.deepEqual(remoteFonts,[],'Bundled SC/JP fonts avoid remote fallback');
  const report={status:'PASS',browser:await browser.version(),locales:['zh','en','ja'],viewports:['1365x1000','390x844'],checks:['staged setup','explicit first save','live income','privacy mask','five independent categories','license navigation','locale persistence','HTML language','salary unchanged by language','desktop and mobile rendering','local SC/JP fonts'],errors,remoteFonts};
  fs.writeFileSync(path.join(output,'result.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report,null,2));
 }catch(e){if(page&&!page.isClosed()){await page.screenshot({path:path.join(output,'failure.png')});console.error((await page.locator('body').innerText()).slice(-4000));}throw e;}
 finally{await browser?.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
