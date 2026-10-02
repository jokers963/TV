# 影視TV

## 落雨秋定制版开发入口

本分支 `luoyuqiu` 是定制手机版的构建入口；`fongmi` 分支用于上游同步参考，不要直接合并或切换来替代本分支。当前源码版本为 `5.6.3-lyq.3`（versionCode `56303`），包名 `com.jokers963.luoyuqiu`；文档更新不代表已重新构建 APK。

先读 [AGENTS.md](AGENTS.md) 和[共享交接顶部](https://github.com/jokers963/CatVodSpider/blob/main/AI_HANDOFF.md)，再按任务阅读[历史播放器原理](https://github.com/jokers963/TV/blob/fongmi/LUOYUQIU_ARCHITECTURE.md)。唯一正式配置为 `https://jokers963.github.io/CatVodSpider/json/luoyuqiu.json`；SupJav 已移除，NBD-022 排查已取消。

构建使用 JDK 21、项目 Gradle Wrapper 和 [SHA-256 清单](app/libs/luoyuqiu-media3.sha256) 对应的 19 个 Media3 AAR。AAR 未纳入 Git，新 clone 须另备匹配依赖；目前尚未提供自动获取方式。该依赖基线不能直接承诺新版 libass／双字幕能力。

```powershell
git switch luoyuqiu
.\gradlew.bat :app:assembleMobileDebug --no-daemon
.\gradlew.bat :app:assembleMobileRelease --no-daemon
# Output 必须是尚不存在的新路径；沿用现有密钥及证书沿袭。
.\scripts\sign-mobile.ps1 -Output ./Release/luoyuqiu-mobile-new.apk
```

已有工作树先检查未提交改动，不强制切换。Debug APK 在 `app/build/outputs/apk/mobile/debug/`；正式手机版必须使用签名脚本输出，不发布 Gradle 原始 APK。详细步骤和恢复限制见[长期签名说明](scripts/SIGNING.md)。下方为通用上游说明，落雨秋手机版构建和签名以上述入口为准。

本机实际开发目录为 `D:/CodexWorkspace/Android/TV563Release`。旧工作树的未提交定制必须逐项比较后再移植，不混入文档同步；旧预览/封面分支的保留与恢复说明见 [BRANCH_ARCHIVE.md](BRANCH_ARCHIVE.md)。

適用於 Android TV 與手機的影音應用程式，整合媒體瀏覽與播放體驗，並支援外部配置與 [CatVod](https://github.com/CatVodTVOfficial/CatVodTVJarLoader) Spider 介面擴充。

**App 本身不內建或提供任何內容來源。** 外部內容需自行配置，也可開啟本地媒體檔案或推送媒體網址。

[使用與開發指南](https://fongmi.github.io/TV/) · [討論群組](https://t.me/fongmi_official)

## 開始使用

1. 安裝適合裝置的 APK：`leanback` 為電視版，`mobile` 為手機版；依 Android 系統支援的 ABI 選擇 `arm64-v8a` 或 `armeabi-v7a`。最低需求為 Android 7.0（API 24）。
2. 在設定中加入自己的配置，格式與欄位見[配置範例](https://fongmi.github.io/TV/config/#examples)。
3. 也可從系統檔案管理員開啟媒體檔案，或透過推送入口播放媒體網址。

## 主要功能

- **播放**：Media3／ExoPlayer、mpv、硬解與 FFmpeg 軟解；字幕、彈幕、音軌、倍速與片頭／片尾跳過。
- **瀏覽與管理**：分類篩選、搜尋、播放記錄、收藏與無痕模式。
- **播放清單**：M3U／TXT／JSON 格式、清單分組與 XMLTV 節目資訊。
- **操作**：電視遙控器、手機手勢、畫中畫與背景音訊。
- **互通**：DLNA 投放／接收、Android Auto、本地 HTTP 控制與裝置同步。

實際能力依配置、媒體、播放引擎與裝置而異；本地 HTTP API 僅供可信任區域網路使用，不要直接轉發到公網。

## 開發文件

| 文件 | 內容 |
| --- | --- |
| [App 功能](https://fongmi.github.io/TV/features/) | 操作與功能介紹 |
| [配置字典](https://fongmi.github.io/TV/config/) | 配置欄位、網路設定與 JSON 範例 |
| [擴充介接](https://fongmi.github.io/TV/spider/) | Java／Python／JavaScript 範例、方法與回傳格式 |
| [本地 API](https://fongmi.github.io/TV/local/) | 播放控制、推送、檔案與同步端點 |
| [網站維護](website/README.md) | 靜態網站建置與 GitHub Pages 發布 |

`app/src/main/` 為共用邏輯，`app/src/leanback/`、`app/src/mobile/` 為各自的 UI。模組清單見 [settings.gradle](settings.gradle)，SDK 與依賴版本見 [libs.versions.toml](gradle/libs.versions.toml)。

## Windows 建置

先準備以下環境與檔案：

- **JDK 21、Android SDK、Python 3.10**。SDK 平台版本依 `compileSdk` 設定；Python 可用 `py -3.10 --version` 確認，找不到時在 [chaquo/build.gradle](chaquo/build.gradle) 的 Python 區塊設定 `buildPython`。
- **配套 AAR**：放入 `app/libs/`。`lib-*.aar` 未納入 Git，單純 clone 不包含完整播放器依賴。
- **自己的簽章檔與 `local.properties`**：在儲存庫根目錄建立下列設定，將所有範例值替換成自己的資料。

```properties
sdk.dir=C:/Android/Sdk
storeFile=C:/keys/yingshi-tv.jks
keyAlias=your-key-alias
storePassword=your-keystore-password
```

金鑰密碼與 keystore 密碼共用 `storePassword`；不要提交簽章檔或真實密碼。

在儲存庫根目錄以 PowerShell 執行：

```powershell
# 電視版
.\gradlew.bat :app:assembleLeanbackRelease

# 手機版
.\gradlew.bat :app:assembleMobileRelease
```

APK 按 ABI 分包並輸出至 `Release/apk/`。簽章不同的 APK 不能直接覆蓋既有安裝。網站位於 `website/`，可獨立建置，不需編譯 Android App。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=FongMi/TV&type=Date)](https://www.star-history.com/#FongMi/TV&Date)
