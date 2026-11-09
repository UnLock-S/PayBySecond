// Optional real-browser smoke test. No Node dependencies enter the Flutter app.
// Install: npm install --prefix .local/qa playwright@1.65.0 --no-save --ignore-scripts
// Serve Release build on localhost, then: node tools/check/browser-smoke.cjs
const assert = require('node:assert/strict');
const path = require('node:path');
const fs = require('node:fs');
const { createRequire } = require('node:module');
const root = path.resolve(__dirname, '../..');
const localRequire = createRequire(path.join(root, '.local/qa/package.json'));
const { chromium } = localRequire('playwright');
const baseUrl = process.env.PBS_TEST_URL || 'http://127.0.0.1:7357';
const output = path.join(root, 'out/reports/browser');
fs.mkdirSync(output, { recursive: true });

async function enableSemantics(page) {
  await page.goto(baseUrl);
  const placeholder = page.locator('flt-semantics-placeholder');
  await placeholder.waitFor({ state: 'attached', timeout: 30000 });
  await placeholder.evaluate(element => element.click());
}

(async () => {
  let browser;
  let page;
  const errors = [];
  const remoteFonts = [];
  try {
    browser = await chromium.launch({ channel: process.env.PBS_BROWSER_CHANNEL || 'msedge', headless: true });
    const context = await browser.newContext({ viewport: { width: 1365, height: 1000 } });
    await context.route(/https:\/\/fonts\.(googleapis|gstatic)\.com\//, route => {
      remoteFonts.push(route.request().url());
      return route.abort();
    });
    page = await context.newPage();
    page.on('pageerror', error => errors.push(error.message));
    await enableSemantics(page);
    await page.getByRole('button', { name: '设置我的薪资', exact: true }).click();
    // Focus Flutter's editing host before typing, rather than writing its
    // mirrored accessibility input with DOM fill events.
    for (const [name, value] of [['月薪（元）', '20000'], ['入职日期', '2026-01-01']]) {
      await page.getByRole('textbox', { name, exact: true }).click();
      await page.keyboard.press('ControlOrMeta+A');
      await page.keyboard.type(value, { delay: 20 });
      await page.keyboard.press('Tab');
    }
    await page.getByRole('button', { name: '开始累计', exact: true }).click();
    await page.getByRole('button', { name: '调整估算配置', exact: true }).waitFor();
    const stored = await page.evaluate(() => {
      const key = Object.keys(localStorage).find(k => k.endsWith('pay_by_second.profile.v1'));
      return key ? localStorage.getItem(key) : null;
    });
    assert(stored && stored.includes('20000'), 'Edited salary must persist in browser storage');
    const balance = page.getByText(/^¥ /).first();
    const before = await balance.innerText();
    await page.waitForTimeout(1400);
    const after = await balance.innerText();
    assert.notEqual(after, before, 'Amount must update without reloading');
    await page.getByRole('button', { name: '隐藏金额', exact: true }).click();
    await page.getByText('¥ ••••••', { exact: true }).first().waitFor();
    assert((await balance.innerText()).includes('••••'), 'Privacy toggle masks income');
    // Tooltip overlays may briefly retain their previous accessible label.
    await page.getByRole('button', { name: /显示金额|隐藏金额/ }).first().click();
    await page.getByText(/^¥ \d/).first().waitFor();
    await page.mouse.move(0, 0);
    await page.getByRole('button', { name: '开源许可', exact: true }).click();
    await page.getByText('许可', { exact: true }).first().waitFor();
    await page.getByRole('button', { name: '返回', exact: true }).click();
    await page.getByRole('button', { name: '调整估算配置', exact: true }).waitFor();
    await page.screenshot({ path: path.join(output, 'dashboard-desktop.png') });
    await enableSemantics(page);
    await page.getByRole('button', { name: '调整估算配置', exact: true }).waitFor();
    assert.equal(await page.getByRole('button', { name: '设置我的薪资', exact: true }).count(), 0, 'Reload restores profile');
    const storageState = await context.storageState();
    const mobile = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1, isMobile: true, hasTouch: true, storageState });
    await mobile.route(/https:\/\/fonts\.(googleapis|gstatic)\.com\//, route => {
      remoteFonts.push(route.request().url());
      return route.abort();
    });
    const mobilePage = await mobile.newPage();
    mobilePage.on('pageerror', error => errors.push(error.message));
    await enableSemantics(mobilePage);
    await mobilePage.getByRole('button', { name: '隐藏金额', exact: true }).waitFor();
    await mobilePage.screenshot({ path: path.join(output, 'dashboard-mobile.png') });
    assert.deepEqual(errors, [], 'No browser runtime exceptions');
    assert.deepEqual(remoteFonts, [], 'UI uses bundled fonts without remote fallback');
    const report = { status: 'PASS', browser: await browser.version(), viewport: ['1365x1000', '390x844'], checks: ['profile editing', 'local persistence', 'live update', 'privacy mask', 'license page navigation', 'reload recovery', 'mobile rendering', 'bundled fonts'], errors, remoteFonts };
    fs.writeFileSync(path.join(output, 'result.json'), JSON.stringify(report, null, 2));
    console.log(JSON.stringify(report, null, 2));
  } catch (error) {
    if (page && !page.isClosed()) {
      await page.screenshot({ path: path.join(output, 'failure.png') });
      console.error((await page.locator('body').innerText()).slice(-3000));
    }
    throw error;
  } finally {
    await browser?.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
