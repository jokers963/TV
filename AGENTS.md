# 落雨秋定制播放器：AI 工作入口

本分支 `luoyuqiu` 是落雨秋定制手机版的源码入口；`fongmi` 仅作上游同步参考。本文件记录维护边界，不代替用户当次授权。

## 唯一现状卡（同步 CatVodSpider，2026-10-06）

- **正式配置**：`https://jokers963.github.io/CatVodSpider/json/luoyuqiu.json`（唯一；勿用 blob / CNAME 域 / 已清空的 `luoyuqiu-api`）。
- **接口 JAR**：`gm_subs-v40`，MD5 `c6a36e891a26e269300069fe7c317fef`；五站 MissAV / AV01 / 肉视频 / Hanime1 / JavGuru；**Jable 已关闭**（实现保留在接口仓）。
- **脚本 `?v=`**：MissAV 9、AV01 5、肉视频 6、Hanime1 3、JavGuru 4。
- **v40 手机 QA 未做**；发布≠本播放器或接口实机通过。权威详情见 [CatVodSpider AGENTS 现状卡](https://github.com/jokers963/CatVodSpider/blob/main/AGENTS.md) 与 [AI_HANDOFF 顶部](https://github.com/jokers963/CatVodSpider/blob/main/AI_HANDOFF.md)。

## 阅读顺序

1. 上表 + [共享 AI_HANDOFF 顶部](https://github.com/jokers963/CatVodSpider/blob/main/AI_HANDOFF.md)：唯一当前状态、任务登记和验证范围；下方旧记录是历史。
2. [README.md](README.md)、[签名说明](scripts/SIGNING.md) 和 [AAR 校验清单](app/libs/luoyuqiu-media3.sha256)。
3. 核对分支、HEAD、未提交改动和远程发布；按任务阅读源码及[历史原理文档](https://github.com/jokers963/TV/blob/fongmi/LUOYUQIU_ARCHITECTURE.md)，不重复全仓研究。

## 当前基线与工作边界

- 源码手机版为 `5.6.3-lyq.3` / `56303`，包名 `com.jokers963.luoyuqiu`；文档版本不证明手机实装版本或全站可播。
- SupJav 已移除、旧配置退役、MemoJav 取消、NBD-022 排查取消；**不按历史记录恢复**（含已关闭的 Jable）。
- 用户要求不要截图；未经新指示不采集手机截图。不清应用数据、不改变方向锁定、不用外部播放器、不自动点击验证。
- 保护用户未提交改动、旧工作树和签名材料；禁止 reset/clean、强推、未经请求同步上游或覆盖 AAR。
- JDK 21、Gradle Wrapper 与清单对应的 19 个 AAR 是当前构建基线；这些 AAR 不在 Git 中，不能把 clone 成功当成可重建。新版 libass／双字幕 API 尚未配齐。
- 正式手机版必须使用 `scripts/sign-mobile.ps1` 的输出；沿用既有密钥和证书沿袭。密钥、密码不得入库或写日志；签名不相容时停止，不卸载或清数据。
- 修改、安装和发布范围以用户当次授权为准；文档整理不授予运行修改权限。网站 userscript 由接口仓库的 GM 运行时加载，不是此仓库 QuickJS。

## 验证与交接

仅改 Markdown 时检查链接、差异和远程内容，不因此安装 APK。修改运行代码时使用项目 Wrapper 做匹配构建和测试，获得实机授权后再验证；编译或单个样本成功不能写成整站通过。

阶段结束将提交、验证、未完成项和下一步写入共享 AI_HANDOFF，不另建第二份当前状态表。多人协作时先登记文件范围、手机操作者和唯一发布人，不同时改共享文件或操作手机。
