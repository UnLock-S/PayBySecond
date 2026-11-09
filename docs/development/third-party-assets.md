# Third-party fonts / 第三方字体

## English

Bundle compact Chinese/Japanese fonts so normal pages do not fetch remote fonts. Chinese/English use PayBySecond Sans; Japanese prioritizes PayBySecond Sans JP, with local SC fallback for native-language names.

| Source | Upstream file | SHA256 |
|---|---|---|
| Noto Sans SC | https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf | a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da |
| Noto Sans JP | https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf | c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f |

Both are SIL OFL-1.1. Preserve original OFL.txt/OFL-JP.txt in app assets and register them on the license page. Derived fonts use renamed families and static 400/700 weights; full upstream fonts stay out of Git. Upstream copyright/author information is a required legal notice, not material to anonymize.

### Rebuild

Install env/font-tooling-requirements.txt in an isolated Python environment, download matching upstream files into .local/fonts, then run:

```powershell
python tools/build/subset_font.py --source .local/fonts/NotoSansSC.ttf --source-jp .local/fonts/NotoSansJP.ttf
```

The generator collects Dart/ARB and config/app/font-extra-characters.txt, adding supported hiragana/katakana and basic copyright symbols for framework controls. SC covers the shared set; JP uses supported source glyphs and asserts that every Japanese message is covered by the original JP font instead of substituting Chinese glyph forms.

tools/check/font-coverage.ps1 checks new UI characters. check.ps1 generates localizations first so ARB edits cannot bypass coverage. Subsets cover the current UI, not arbitrary full Chinese/Japanese text. Expand this strategy before adding free text. Checks do not replace visual review. Normal builds consume committed fonts and need no Python/full fonts/remote font downloads.

## 中文

界面内置中文和日文精简字体，常规页面不依赖远程字体下载。中文/英语使用 PayBySecond Sans，日语优先使用 PayBySecond Sans JP，少量简体中文原生语言名称可回退到本地 SC 字体。

| 字体源 | 上游文件 | SHA256 |
|---|---|---|
| Noto Sans SC | https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf | `a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da` |
| Noto Sans JP | https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf | `c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f` |

两个上游均为 SIL OFL-1.1。原始许可保存在应用 assets/fonts/OFL.txt 和 OFL-JP.txt，随应用打包，并注册到应用内许可页面。派生字体采用新名称，生成400/700两个静态字重，上游完整字体不进入仓库。

### 重建

使用隔离 Python 环境安装 env/font-tooling-requirements.txt，将校验和匹配的原文件下载至 .local/fonts，然后执行：

```powershell
python tools/build/subset_font.py --source .local/fonts/NotoSansSC.ttf --source-jp .local/fonts/NotoSansJP.ttf
```

生成器收集 Dart 源码、ARB 翻译和 config/app/font-extra-characters.txt 的字符，并补入上游支持的平假名/片假名及基础版权符号，覆盖框架内置日语控件。SC 覆盖共享集合；JP 生成本地支持的子集，并额外断言每条日语翻译的字形均由 JP 原字体支持，避免用中文字形替代正常日语文案。

tools/check/font-coverage.ps1 在常规检查中确认新增文案的字符已纳入覆盖清单。tools/check/check.ps1 先重新生成本地化源码，防止翻译变更绕过字形检查。

子集只覆盖当前界面及补充菜单字符，不是通用中文/日文全文字库。未来加入自由文本时需扩大策略；检查不替代浏览器截图验证。普通 Flutter 构建只使用已提交字体，不需要 Python、完整原字体或额外网络请求。
