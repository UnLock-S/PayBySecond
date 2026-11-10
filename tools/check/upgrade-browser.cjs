// Runs only isolated browser contexts with synthetic finance, never a user profile.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {createRequire} = require('node:module');
const root = path.resolve(__dirname, '../..');
const {chromium} = createRequire(path.join(root, '.local/qa/package.json'))('playwright');
const base = process.env.PBS_TEST_URL || 'http://127.0.0.1:7357';
const output = path.join(root, 'out/reports/upgrade-browser');
fs.mkdirSync(output, {recursive: true});
const l = JSON.parse(fs.readFileSync(path.join(root, 'src/apps/pay_by_second/lib/l10n/app_zh.arb'), 'utf8'));
const legacy = {schemaVersion: 1, salary: '12345.67', start: '2024-01-01', mode: 'calendar', basis: 'annual', weekdays: [1,2,3,4,5], startMinute: 480, endMinute: 1020, lunch: true, refreshMs: 1000, digits: 4, overrides: {'2026-01-04': true}};
async function boot(page) {
  await page.goto(base);
  const semantics = page.locator('flt-semantics-placeholder');
  await semantics.waitFor({state: 'attached', timeout: 30000});
  await semantics.evaluate(e => e.click());
}
async function click(page, name) { await page.getByRole('button', {name, exact: true}).click(); }
async function back(page) { await page.getByRole('button', {name: /^返回/}).click(); }
async function fill(page, name, value) {
  const field = page.getByRole('textbox', {name, exact: true});
  await field.click(); await page.keyboard.press('ControlOrMeta+A'); await page.keyboard.insertText(value); await page.keyboard.press('Tab');
}
async function reveal(page, role, name) {
  const item = page.getByRole(role, {name, exact:true});
  await page.mouse.move(180,450); await page.mouse.wheel(0,-4000); await page.waitForTimeout(200);
  for (let i=0;i<18;i++) {
    if (await item.count()) { const box=await item.boundingBox(); if(box && box.y>=60 && box.y+box.height<780) return item; }
    await page.mouse.wheel(0,240); await page.waitForTimeout(100);
  }
  throw new Error('Could not reveal '+name);
}
async function raw(page, suffix) { return page.evaluate(s => { const k = Object.keys(localStorage).find(k => k.endsWith(s)); return k ? localStorage.getItem(k) : null; }, suffix); }
function decode(raw) { let value = JSON.parse(raw); return typeof value === 'string' ? JSON.parse(value) : value; }
async function shot(page, name) { await page.waitForTimeout(350); await page.screenshot({path: path.join(output, name + '.png'), fullPage: true}); }
(async () => {
  const browser = await chromium.launch({channel: process.env.PBS_BROWSER_CHANNEL || 'msedge', headless: true});
  let page;
  const errors = [], fonts = [], policyRequests = [];
  try {
    const context = await browser.newContext({viewport: {width: 390, height: 844}});
    await context.addInitScript(data => {
      if (!localStorage.getItem('qa.seeded')) {
        localStorage.setItem('pay_by_second.profile.v1', JSON.stringify(JSON.stringify(data)));
        localStorage.setItem('qa.seeded', 'true');
      }
    }, legacy);
    page = await context.newPage();
    page.on('pageerror', e => errors.push(e.message));
    page.on('request', r => { if (/fonts\.(googleapis|gstatic)\.com/.test(r.url())) fonts.push(r.url()); });
    await context.route('https://raw.githubusercontent.com/UnLock-S/PayBySecond/main/config/policy/cn-2026.json', route => { policyRequests.push(route.request().url()); return route.fulfill({status: 503, body: 'offline simulation', headers: {'Access-Control-Allow-Origin': '*'}}); });
    await boot(page); await page.getByText(l.headline, {exact: true}).waitFor();
    await page.getByRole('button', {name: l.settings, exact: true}).waitFor();
    const original = await raw(page, 'pay_by_second.profile.v1');
    assert.deepEqual(decode(original), legacy);
    const first = await raw(page, 'pay_by_second.profile.v2');
    assert.equal(decode(first).payload.salaries[0].salary, legacy.salary);
    assert.equal(await raw(page, 'pay_by_second.profile.v1.original'), original);
    await boot(page); await page.getByRole('button', {name: l.settings, exact: true}).waitFor();
    assert.equal(await raw(page, 'pay_by_second.profile.v2'), first, 'migration is idempotent');
    assert.deepEqual(policyRequests, [], 'no startup policy request');
    await shot(page, 'home-after-migration');

    await click(page, l.hideAmount);
    await click(page, l.traceTitle);
    await page.getByText(l.traceHelp, {exact: true}).waitFor();
    assert.equal(await page.getByText(/^CNY \d/).count(), 0, 'trace respects session privacy');
    await shot(page, 'hidden-trace'); await back(page);
    await click(page, l.settings); await click(page, l.historyTitle + ' ' + l.effectiveDate);
    await page.getByText(l.historyHelp, {exact: true}).waitFor();
    assert.equal(await page.getByText(/CNY 12345/).count(), 0);
    await shot(page, 'hidden-history'); await back(page);

    await click(page, l.salarySection + ' ' + l.salarySummary);
    await fill(page, l.salaryLabel, '20000');
    await fill(page, l.effectiveDate, '20261201');
    await page.mouse.wheel(0, 1500); await click(page, l.save);
    await page.getByText(l.recalculateTitle, {exact: true}).waitFor();
    await click(page, l.cancel); assert.equal(await raw(page, 'pay_by_second.profile.v2'), first);
    await click(page, l.save); await click(page, l.confirmSave);
    await page.getByRole('button', {name: l.historyTitle + ' ' + l.effectiveDate, exact: true}).waitFor();
    const changed = decode(await raw(page, 'pay_by_second.profile.v2')).payload;
    assert.equal(changed.salaries.length, 2); assert.equal(changed.schedules.length, 1);
    assert.equal(changed.salaries[0].salary, legacy.salary); assert.equal(changed.salaries[1].effectiveFrom, '2026-12-01');
    await click(page, l.policyTitle + ' ' + l.policyPending);
    await page.mouse.wheel(0,1400); await page.getByText(l.policySource, {exact:true}).waitFor();
    await shot(page, 'calendar-pending-source');
    await page.mouse.wheel(0, 3000); await click(page, l.policyUpdate);
    await click(page, l.confirmSave); await page.getByText(l.policyCacheFailed, {exact: true}).waitFor();
    assert.equal(policyRequests.length, 1); assert.equal(await raw(page, 'pay_by_second.policy.v1'), null);
    await (await reveal(page,'checkbox',l.policyConfirm)).click();
    await page.waitForFunction(label=>[...document.querySelectorAll('[role=checkbox]')].some(e=>e.getAttribute('aria-label')===label&&e.getAttribute('aria-checked')==='true'),l.policyConfirm);
    await (await reveal(page,'button',l.policyApply)).click(); await click(page,l.confirmSave);
    await page.getByRole('button',{name:l.policyApply,exact:true}).waitFor();
    await page.waitForFunction(()=>{let value=JSON.parse(localStorage.getItem('pay_by_second.profile.v2'));if(typeof value==='string')value=JSON.parse(value);return value.payload.schedules.length===2;});
    const policySnapshot=decode(await raw(page,'pay_by_second.profile.v2')).payload.schedules[1].fields.calendarSource;
    assert.match(policySnapshot.datasetSha256,/^[0-9a-f]{64}$/); assert.equal(policySnapshot.source.review,'pending');
    await back(page);
    await page.mouse.wheel(0, 3000); await click(page, l.recoveryTitle + ' ' + l.localOnly);
    await click(page, l.exportData);
    const field = page.getByRole('textbox', {name: l.backupJson, exact: true});
    await page.getByText(l.operationDone, {exact:true}).waitFor(); await field.click();
    await page.waitForFunction(() => [...document.querySelectorAll('textarea')].some(e => e.value.includes('pay-by-second-financial-backup')));
    const backup = await page.locator('textarea').first().inputValue(); await page.keyboard.press('Tab'); assert.equal(JSON.parse(backup).payload.kind, 'pay-by-second-financial-backup');
    await fill(page, l.backupJson, backup.replace('"sha256":"', '"sha256":"bad'));
    await page.mouse.wheel(0, 900); await click(page, l.importData);
    await page.getByText(l.operationFailed, {exact: true}).waitFor();
    const beforeImport = await raw(page, 'pay_by_second.profile.v2');
    await fill(page, l.backupJson, backup); await click(page, l.importData); await click(page, l.confirmSave);
    await page.getByRole('button', {name: l.settings, exact: true}).waitFor();
    assert.equal(await raw(page, 'pay_by_second.profile.v2'), beforeImport);
    assert(await raw(page, 'pay_by_second.import.previous.v1'), 'pre-import state retained');

    await click(page, l.settings); await page.mouse.wheel(0, 900);
    await click(page, l.appearance + ' ' + l.systemTheme); await click(page, l.darkTheme);
    await shot(page, 'dark-appearance'); await back(page); await back(page);
    await shot(page, 'dark-home');

    // An older application writing v1 cannot silently overwrite the migrated history.
    await page.evaluate(data => localStorage.setItem('pay_by_second.profile.v1', JSON.stringify(JSON.stringify({...data, salary: '15000'}))), legacy);
    await boot(page); await page.getByText(l.loadError, {exact: true}).waitFor();
    assert(await page.getByRole('button', {name: l.getStarted, exact: true}).isDisabled());
    await shot(page, 'legacy-conflict-recovery');
    await click(page, l.recoveryTitle); await page.mouse.wheel(0, 2000);
    await click(page, l.restoreLegacy); await click(page, l.confirmSave);
    await page.getByRole('button', {name: l.settings, exact: true}).waitFor();
    assert.equal(decode(await raw(page, 'pay_by_second.profile.v2')).payload.salaries[0].salary, '15000');
    assert(await raw(page, 'pay_by_second.profile.v2.recovered'), 'replaced document retained');
    assert.deepEqual(errors, []); assert.deepEqual(fonts, []);
    const report = {status: 'PASS', browser: await browser.version(), viewport: '390x844', checks: ['real Web v1 migration and exact originals', 'idempotent reload', 'session-wide detail privacy', 'future salary and cancel preview', 'independent rule history', 'pending calendar source', 'policy opt-in network failure', 'confirmed personal calendar source snapshot retains pending official review', 'no startup policy requests', 'backup checksum rejection and confirmed import', 'pre-import retained copy', 'dark theme', 'legacy conflict fail-closed and explicit recovery'], errors, fonts, policyRequests};
    fs.writeFileSync(path.join(output, 'result.json'), JSON.stringify(report, null, 2)); console.log(JSON.stringify(report, null, 2));
  } catch (error) {
    if (page && !page.isClosed()) { await shot(page, 'failure'); console.error((await page.locator('body').innerText()).slice(-5000)); }
    throw error;
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
