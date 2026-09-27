# 落雨秋：播放器与配置加载底层原理

记录日期：2026-09-27。本文区分远程 fork、上游、本地定制和手机安装版本；它是研究说明，不是播放器或所有站点的完整验收报告。

配套文档：[配置、Spider 与网站脚本原理](https://github.com/jokers963/CatVodSpider/blob/main/LUOYUQIU_ARCHITECTURE.md)。

## 1. 研究基线与不能混用的版本

| 层 | 研究快照 |
| --- | --- |
| 本 TV fork | `fongmi` 分支，源码基线 `4afc4473e22a7ed3d98ee12233e0c2a490061000` |
| 上游 FongMi/TV | 对照 `bed6ef2b7fa6a1022cdd8682fac7a04d5a514ba2` |
| 配套 CatVodSpider fork | `main`，源码基线 `1d97a24cab319345218cc58b80091b9b1c1af879` |
| 正式接口 | `https://jokers963.github.io/CatVodSpider/json/supjav.json` |
| 研究时手机已装 APK | `com.fongmi.android.tv`，版本 5.6.5 |
| 研究时本地构建文件 | 标注 5.6.3，并有未提交的播放器定制 |

上游对照提交相对本 fork 的研究源码基线多 145 个提交，新增了 Node Spider、解码回退等实现；这不是自动升级理由。对比见[固定提交比较](https://github.com/FongMi/TV/compare/4afc4473e22a7ed3d98ee12233e0c2a490061000...bed6ef2b7fa6a1022cdd8682fac7a04d5a514ba2)。

手机 APK、远程已提交源码、本地工作树和 AAR 依赖之间的精确构建关系尚未证明。不能用其中一个版本的实现解释另一个版本的每个行为。本文提交只是文档变更，不同步上游，不提交本地定制，不改变运行逻辑。

## 2. 模块职责

TV 是宿主，不自带内容来源；外部配置定义来源，Spider 提供统一数据，内置播放引擎负责媒体读取与播放。

| 模块/目录 | 主要职责 |
| --- | --- |
| `app/src/main` | 配置、数据、播放服务、播放引擎适配和通用业务 |
| `app/src/mobile` | 手机界面与手势 |
| `app/src/leanback` | TV 界面与遥控器操作 |
| `catvod` | Spider 契约、网络工具、代理等宿主公共能力 |
| `quickjs` | 直接执行 JavaScript Spider，不是浏览器 DOM |
| `chaquo` | Python Spider 与 Java 之间的桥接 |
| `app/libs` | Media3、mpv、FFmpeg 等配套 AAR，以及特定播放组件 |
| `website` | 开发与使用指南网站，不是 Android 播放核心 |

当前 fork 基线的模块清单见 [settings.gradle](settings.gradle)。较新上游增加 Node 运行时，不表示当前基线或实装 APK 已支持 `node:` Spider。

部分底层能力来自配套 AAR/原生库，不是本仓库 Java 适配层的全部源码。单纯 clone 也不保证具有完整构建依赖；需同时记录 AAR、ABI、SDK、签名和构建版本。

## 3. 远程配置如何成为应用里的站点

主要入口：[BaseConfig](app/src/main/java/com/fongmi/android/tv/api/config/BaseConfig.java)、[VodConfig](app/src/main/java/com/fongmi/android/tv/api/config/VodConfig.java)、[Decoder](app/src/main/java/com/fongmi/android/tv/api/Decoder.java)。

```text
设置中选定配置 URL
  → Config 持久化配置记录与选择
  → BaseConfig 异步加载，启动手机本地服务
  → Decoder 下载并处理配置文本及相对路径
  → VodConfig 解析 sites / spider / parses / rules 等
  → BaseLoader 加载所需运行时
  → SiteApi 将界面任务转成站点调用
```

配置可能是普通 JSON，也可能是包含 `urls` 的配置仓库入口；不能将两者混为一个站点。配置历史、选中站点、搜索开关、播放历史与收藏存在本地数据库/设置中，不能随意清数据来代替诊断。

`type: 0` 主要走 XML 采集 API，`type: 1` 走 JSON 采集 API，`type: 3` 走 Spider，`type: 4` 走扩展 HTTP JSON。`api`、`ext` 在不同类型下含义不完全相同。全局 `spider` 是默认 JAR，站点 `jar` 可以覆盖。

## 4. Spider 运行与数据协议

[BaseLoader](app/src/main/java/com/fongmi/android/tv/api/loader/BaseLoader.java) 按 API 形式路由：`csp_` 对应 Java JAR，`.js` 对应 QuickJS，`.py` 对应 Python。当前落雨秋四站选择 `csp_GMSubs`，所以其 `.user.js` 是 GM 插件加载的网页脚本，并未由 QuickJS 直接执行。

[JarLoader](app/src/main/java/com/fongmi/android/tv/api/loader/JarLoader.java) 下载 JAR、标记只读，通过 `DexClassLoader` 和宿主类加载器加载 DEX，按 `com.github.catvod.spider.` 加类名实例化，设置 `siteKey` 并调用 `init(context, ext)`。加载器及站点实例会缓存；JAR URL、站点键和可选 MD5 影响缓存处理。

动态加载依赖约定的类名、方法签名和宿主公共 API，混淆规则不能破坏这些入口。重新加载会清理插件，但不能因此假设所有正在进行的网络/网页任务都已安全退出。

[SiteApi](app/src/main/java/com/fongmi/android/tv/api/SiteApi.java) 调用首页、分类、搜索、详情和 `playerContent`，将返回 JSON 转为 [Result](app/src/main/java/com/fongmi/android/tv/bean/Result.java) 与 [Vod](app/src/main/java/com/fongmi/android/tv/bean/Vod.java)。

详情线路通过 `vod_play_from`/`vod_play_url` 组织：`$$$` 分隔线路、`#` 分隔集数、`$` 分隔名称与播放 ID。线路名是 `flag`，站点是 `key`，播放 ID 是 `id`；三者不是同一概念。SupJav 的“TV 线路”是网站线路名称，也不是应用的直播功能或 `leanback` 版本。

## 5. 从点击播放到内置引擎

```text
VideoActivity / VodPlaybackController 选择线路与集数
  → VodPlayRequest(key, flag, id)
  → VideoViewModel → SiteApi.playerContent
  → Spider 返回 Result
  → 核对结果仍属于当前任务
  → PlaybackActivity 检查消息、地址与 DRM
  → 必要时 ParseJob 进一步解析
  → PlaySpec → MediaItemFactory
  → PlaybackService / PlayerManager
  → ExoPlayerEngine 或 MpvPlayerEngine
```

核心文件：[VodPlaybackController](app/src/main/java/com/fongmi/android/tv/playback/vod/VodPlaybackController.java)、[VideoViewModel](app/src/main/java/com/fongmi/android/tv/model/VideoViewModel.java)、[PlaybackActivity](app/src/main/java/com/fongmi/android/tv/ui/activity/PlaybackActivity.java)、[PlayerManager](app/src/main/java/com/fongmi/android/tv/player/PlayerManager.java)。

| 播放结果字段 | 实际含义 |
| --- | --- |
| `url` | 媒体地址、待解析地址，或宿主支持的多画质表示 |
| `header` | 媒体请求参数，如 User-Agent、Referer；不是只用于网页 |
| `format` | 完整媒体 MIME 提示，影响媒体源/容器识别 |
| `parse`、`jx` | 是否进一步解析；`parse=0` 不保证永远绕过全部解析条件 |
| `playUrl` | 解析前缀或具名解析方式 |
| `subs` | 外挂字幕候选 |
| `drm` | DRM 参数，需要引擎与设备支持 |
| `position` | 可选播放起点，毫秒 |

`Site.header` 在播放结果请求头为空时作为默认，并不是逐键合并，也不会自动控制 Spider 自己创建的所有 HTTP 请求。

[ParseJob](app/src/main/java/com/fongmi/android/tv/player/parse/ParseJob.java) 支持 WebView、JSON API、JAR 扩展及并行解析等分支。宿主 [CustomWebView](app/src/main/java/com/fongmi/android/tv/ui/custom/CustomWebView.java) 通过请求拦截、规则和脚本嗅探媒体；它和 GM 的 WebView 是不同实现。修改一套实现不能假定另一套也受影响。

## 6. 播放引擎、字幕与生命周期

ExoPlayer 和 mpv 都是应用内置引擎，不等于启动外部播放器。应用另有显式分享/选择外部播放的入口；落雨秋项目的日常验证不使用该路径。

[PlaySpec](app/src/main/java/com/fongmi/android/tv/player/media/PlaySpec.java) 保存 URL、请求头、格式、字幕、DRM 等；[MediaItemFactory](app/src/main/java/com/fongmi/android/tv/player/media/MediaItemFactory.java) 转成媒体项。Exo 媒体源将请求头交给数据源，再处理清单、分片、容器和解码。拿到 m3u8 不等于分片可读，更不等于解码已经成功。

播放服务持有播放器与媒体会话，界面通过控制器观察和控制；页面返回、后台、重建、画中画、服务所有权和释放逻辑都会影响播放。快进主要作用于播放器时间轴，但带签名的地址过期或分片访问异常仍可能导致失败。

`subs` 最终变成外挂字幕配置，包含 URL、名称、语言、格式与选择标志。字幕候选、字幕下载、字幕解析、默认选轨和画面渲染是不同步骤。研究时本地的 Exo 字幕适配与远程基线存在差异，双字幕/libass 等能力不能未经确认就承诺给实装 APK。

引擎选择和解码回退随版本变化。较新上游已有独立的音视频解码回退逻辑；不能把较新源码的全部能力写成当前 fork 已实现。

## 7. 手机本地 HTTP 服务与代理

[Server](app/src/main/java/com/fongmi/android/tv/server/Server.java) 从 9978 起尝试可用端口，实际端口需查询，不能永远写死。服务还提供本地控制、状态、推送、文件与缓存等功能。

```text
内置播放器请求 http://127.0.0.1:实际端口/proxy
  → Nano / process.Proxy
  → BaseLoader.proxy
  → 带 siteKey 时路由到对应 Spider.proxy
  → 返回状态、MIME、内容流和可选响应头
```

没有 `siteKey` 的部分 JAR 代理会走静态 Proxy 入口及最近加载的 JAR。多站并用时必须区分这些路由。

手机的 `127.0.0.1` 指手机本身；它可以合法用于媒体代理，但不能被误当成电脑的配置文件地址。正式配置仍通过远程 GitHub Pages 获取。服务只应用于可信网络，不应向公网转发。

## 8. 超时与旧任务保护

| 阶段 | 研究基线中的限时/保护 |
| --- | --- |
| 首页、详情、播放结果任务 | `Constant.TIMEOUT_VOD` 为 30 秒 |
| 宿主默认解析/WebView | 通常为独立的 15 秒常量 |
| 播放器启动准备 | 点播直接播放路径使用 `Site.getTimeout()`，默认 15 秒；当前四站配置为 60 秒 |
| GM 网页等待 | 第三方插件有独立约 40 秒超时处理 |
| SupJav/MissAV 脚本等待 | 普通页面可等 35 秒，验证页面可等 55 秒 |
| GMSubs 字幕请求 | 同步查询，总调用超时三秒 |

依据：[Constant](app/src/main/java/com/fongmi/android/tv/Constant.java)、[ViewModelTaskRunner](app/src/main/java/com/fongmi/android/tv/model/ViewModelTaskRunner.java)、[配套网站脚本](https://github.com/jokers963/CatVodSpider/tree/main/js)。

站点 `timeout: 60` 不是整条链路统一等待 60 秒；进一步解析后启动也有自己的默认处理。外层 30 秒可能早于脚本预设等待结束，这是静态源码发现的潜在冲突，不是某次实机失败的已证实原因。

任务运行器为同类任务递增编号、取消旧 Future，并只接收当前编号的回调；播放控制器还核对站点、线路与播放 ID。旧结果保护和资源清理是两个问题：丢弃旧回调不意味着插件后台线程、WebView 和请求已经安全取消。预加载也有独立任务，不能忽略其并发影响。

## 9. 网络与安全边界

至少应分别看 WebView、宿主 OkHttp、插件自建 OkHttp 和播放引擎请求。Cookie、DNS、代理、请求头和授权不自动在所有通道间互通。当前 GMSubs 使用自己的客户端，宿主网络配置不能被假定自动应用于它。

远程 JSON 可以引入可执行 JAR、Python、JavaScript；它不是没有执行风险的静态清单。研究到的源码中，宿主 OkHttp 有宽松证书信任实现，CustomWebView 有继续处理 SSL 错误的行为，属于需评估的安全风险，本文没有修复它们。

本地定制还包含媒体响应处理等差异，不能假定远程 fork 已拥有相同修复。日志应脱敏，不公开凭据、Cookie、签名播放地址或设备标识；正式发布不留临时调试开关。

## 10. 后续诊断与验收

按证据定位，而不是同时修改所有层：

1. 核对 APK、配置入口、远程 JSON/JAR/脚本版本，以及选中站点和线路。
2. 区分配置下载失败、插件加载失败、网页验证未完成、播放结果为空。
3. 拿到地址后分别检查主清单、子清单、分片、密钥、字幕及代理响应。
4. 区分 HTTP/授权错误、容器/清单错误和解码错误。
5. 检查旧任务、预加载、页面生命周期和服务状态的影响。
6. 修改后执行匹配的构建/测试，再从正式远程入口在手机回归首次播放、切换、持续播放、快进及返回重播。

Media3 内部状态、媒体会话 `PlaybackState` 和本地 HTTP 状态的数字含义并不完全相同。至少两次观察播放状态与进度增长并结合日志；只出现画面、缓冲或某个数字，不足以判定通过。单样本成功不代表整站稳定。

本项目不通过清应用数据、错误配置历史、解除系统方向锁定或外部播放器来绕过问题。保留用户未提交改动；本轮仅获授权发布 Markdown，不修改本地 TV 工作树或任何运行文件。

参考：本仓库 [README](README.md)、[上游 TV](https://github.com/FongMi/TV)、[配套接口说明](https://github.com/jokers963/CatVodSpider/blob/main/LUOYUQIU_ARCHITECTURE.md)。
