# 落雨秋播放器：AI 工作入口

本 fork 默认分支是 `fongmi`。本文件不扩大用户授权，不代表手机 APK 与当前源码完全对应。

## 阅读顺序

1. [共享 AI_HANDOFF](https://github.com/jokers963/CatVodSpider/blob/main/AI_HANDOFF.md)：唯一的当前状态、协作登记及交接记录。
2. [LUOYUQIU_ARCHITECTURE.md](LUOYUQIU_ARCHITECTURE.md)：按任务选章节，不重复研究全仓。
3. 只读核对 HEAD、脏工作树、实装 APK 与远程配置；差异查清后继续用户具体任务。

## 权限与核心边界

- 此 TV 本地工作树及运行文件保持只读，除非用户另行明确授权。当前仅允许远程 Markdown 更新，不能提交本地已有定制或安装/发布 APK。
- 保留所有用户改动；禁止 reset/clean/强推、未经请求同步上游或覆盖已有 AAR。远程文档提交不代表本地已更新。
- 正式配置来自 `https://jokers963.github.io/CatVodSpider/json/supjav.json`。手机本地 `/proxy` 是媒体代理，不是电脑配置入口。
- 调用链入口：`VodConfig` → `BaseLoader/JarLoader` → `SiteApi`；播放入口：`VodPlaybackController` → `VideoViewModel` → `PlaybackActivity` → `PlaySpec/MediaItemFactory` → `PlayerManager` → 内置引擎。完整路径和协议见原理文档。
- 网站 userscript 实际由配套 GM 运行时加载，不是此仓库 QuickJS；SupJav 的“TV 线路”不是直播或 leanback 版本。
- 不混用上游、fork、脏工作树、AAR 和实装 APK 的能力；未证明版本对应时明确注明。
- 不清应用数据、不盲改配置历史、不改变方向锁定、不用外部播放器、不自动点击验证；不要公开 Cookie、凭据、签名媒体地址或设备标识，不遗留调试。
- 实机至少两次观察播放状态与进度增长，覆盖首次、切换、持续、快进、返回重播；编译成功或一个视频成功不是整站验收。

## 双 AI 工作

默认本仓库承担只读分析/审查；获得代码修改授权后才进行实现。双方在共享 AI_HANDOFF 中登记文件范围、手机操作者与唯一发布人，独立分支/工作树，不同时改同一文件或操作手机。

共享协议变动先约定兼容性；发布基于最新远程版本，不覆盖对方提交。阶段结束把证据、未完成项和下一步写回唯一共享记录，不复制出互相矛盾的状态文档。
