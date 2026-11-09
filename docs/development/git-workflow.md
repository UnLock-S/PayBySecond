# Git workflow / Git 维护约定

## English

Maintain main directly. Origin is https://github.com/UnLock-S/PayBySecond.git. The initial Web MVP branch was fast-forwarded into main; subsequent work continues there.

- Commit reviewable documentation/requirements, source features and fixes.
- Before committing inspect status, whitespace, static analysis and relevant tests.
- Commit application/core dependency locks for reproducibility.
- Exclude SDKs, machine paths, actual browser salary data, outputs, caches and secrets.
- Verify checks before integration; no force push or overwriting existing commits.
- Fetch/check origin/main before pushing. Integrate and validate upstream changes instead of replacing others' work.
- Follow AGENTS.md and THIRD_PARTY_NOTICES.md for dependencies.

Historical commits retain their original author identities by the owner's explicit choice. New publication commits use the GitHub public username/noreply address without changing global Git identity. File privacy checks cannot remove metadata already in preserved history. Repository visibility changes do not choose a project license.

## 中文

按项目所有者要求直接维护 main。远端 origin 为 https://github.com/UnLock-S/PayBySecond.git。初始 Web MVP 功能分支已快进合入 main，后续提交直接在 main 进行。

- 文档/需求基线、源码功能、后续修复按可审查的范围提交。
- 提交前检查 git status、git diff --check、静态分析和相关测试。
- Flutter 应用与计算包的依赖锁文件均提交，便于复现。
- 不提交 SDK、本机绝对路径、浏览器薪资数据、构建产物、缓存或密钥。
- 主分支集成前确认检查记录；不使用 force push 或覆盖已有提交。
- 推送前检查 origin/main 是否前进；有远端变更时先整合并验证，不覆盖他人提交。
- 第三方依赖维护遵守根目录 AGENTS.md 与 THIRD_PARTY_NOTICES.md。

按所有者明确选择，历史提交保留原身份；后续公开提交使用GitHub公开用户名及noreply邮箱，不修改全局身份。正文隐私清理不能移除保留历史中的作者元数据。仓库公开不代表已选择项目许可证。
