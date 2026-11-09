# ADR-001: Web-first Flutter / ADR-001：统一 Flutter 客户端，Web 优先

## English

Date: 2026-11-09. Status: follows the confirmed Web-first direction; the technical split is the design decision.

### Context

APK is the main eventual delivery, with Web/desktop coverage required. Validate core behavior first while limiting resources/permissions and maintenance cost.

### Decision

Use one Flutter client, enabling Web before Android/desktop. Isolate salary calculations in pure-Dart earnings_core and platform differences in adapters. Put documentation, public configuration and environment guidance in docs/, config/ and env/. Keep platform projects in standard application-root locations. Create a backend only after choosing deployment/authentication; no empty backend scaffold.

This supersedes the APK-first development order in product-spec.md, without changing APK priority as a deliverable or money rules.

### Consequences

Share calculations/UI, reducing duplicate implementations. Flutter has engine overhead; Android Release measurements are still necessary. Passing Web functionality does not establish native memory/energy/permissions. Storage, credentials, visibility and packaging remain platform concerns.

### Alternatives

Native Android can reduce APK-specific resource overhead but needs separate Web/desktop UI. A separate Web framework plus native client doubles UI and consistency maintenance; neither is currently selected.

## 中文

日期：2026-11-09。状态：按用户确认的 Web 优先方向建立；技术拆分为当前设计建议。

### 背景

产品以 APK 为主要后续交付物，需要覆盖 Web 和桌面平台。当前先验证核心功能，强调低资源、无敏感权限和可维护性。

### 决策

使用单一 Flutter 客户端；先启用 Web，后启用 Android 和桌面平台。工资计算独立为纯 Dart earnings_core 包；平台差异通过适配器实现。文档、配置源和环境入口分别置于 docs、config、env。

Flutter 平台工程留在应用根，遵循原生工具链约定。认证服务在选择部署方式后再生成，不提前引入空后端。

本决策更新 product-spec.md 中 APK 优先开发的阶段排序；APK 仍是主要交付目标，业务计算口径不变。

### 影响

共享计算和 UI，减少重复实现。Flutter 引擎有基础开销，资源目标必须通过 Android Release 实测；Web 功能通过不等于 Android 内存、耗电和权限已验证。各平台仍需适配存储、凭证、可见性和打包环境。

### 替代方案

原生 Android 适合进一步压缩 APK 专属资源，但需要额外实现 Web/桌面 UI。独立 Web 框架加原生客户端会产生两套界面和计算一致性维护成本，因此当前不选。
