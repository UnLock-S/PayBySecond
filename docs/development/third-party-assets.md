# 第三方字体

Web 首次加载时动态字体回退可能产生中文方框，因此当前 UI 内置精简字体，正常界面不依赖远程中文字体。它仅覆盖当前源码中的非 ASCII 字符及基本拉丁字符；新增文案后须更新子集。通用用户昵称/自由中文文本功能上线前需扩大字体策略。

来源：Google Fonts 仓库的 Noto Sans SC 可变字体。

- 上游地址：https://github.com/google/fonts/tree/main/ofl/notosanssc
- 原文件：https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf
- SHA256：`a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da`
- 许可证：SIL Open Font License 1.1；原许可正文保存在应用 assets/fonts/OFL.txt，并随应用打包。
- 派生字体命名为 PayBySecond Sans，生成 400/700 两种静态字重，只保留当前所需字符；未将上游完整字体加入仓库。

重建步骤：使用隔离 Python 环境安装 env/font-tooling-requirements.txt，将该 SHA256 的原文件下载到 .local/fonts/NotoSansSC.ttf，然后执行：

```powershell
python tools/build/subset_font.py --source .local/fonts/NotoSansSC.ttf
```

tools/check/font-coverage.ps1 检查当前源码非 ASCII 字符是否在已生成的覆盖清单内，无需 Python。它不替代字体渲染实测；最终仍需浏览器截图确认。正常 Flutter 构建只使用已提交字体，不需要下载上游文件或安装 fontTools。
