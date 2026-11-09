# Git 维护约定

按项目所有者要求直接维护 main。远端 origin 为 https://github.com/UnLock-S/PayBySecond.git。初始 Web MVP 功能分支已快进合入 main，后续提交直接在 main 进行。

- 文档/需求基线、源码功能、后续修复按可审查的范围提交。
- 提交前检查 git status、git diff --check、静态分析和相关测试。
- Flutter 应用与计算包的依赖锁文件均提交，便于复现。
- 不提交 SDK、本机绝对路径、浏览器薪资数据、构建产物、缓存或密钥。
- 主分支集成前确认检查记录；不使用 force push 或覆盖已有提交。
- 推送前检查 origin/main 是否前进；有远端变更时先整合并验证，不覆盖他人提交。
- 第三方依赖维护遵守根目录 AGENTS.md 与 THIRD_PARTY_NOTICES.md。

首次基线提交沿用机器现有 Git 用户身份；没有修改全局 Git 配置。
