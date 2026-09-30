# 落雨秋长期签名

手机版 Release 构建后运行 `scripts/sign-mobile.ps1`，发布它输出的 APK。
Gradle 原始 APK 仅是旧签名的中间产物，不应作为新正式版本发布。

```powershell
.\gradlew.bat :app:assembleMobileRelease --no-daemon
.\scripts\sign-mobile.ps1 -Output D:/CodexWorkspace/Android/TV563Release/Release/luoyuqiu-5.6.3-lyq.3-arm64.apk
```

脚本使用 Android 官方 `apksigner`。Android 9/API 28 及以上通过
`debug-to-release.lineage` 采用专用 `luoyuqiu` 证书，保留原包名与应用数据；
较老系统继续使用沿袭中的旧证书。新证书更新时始终保留同一沿袭，不能重新生成密钥。
验证成功才可执行 `adb install -r`，签名不相容时停止，不卸载或清数据。

密钥、密码和沿袭保存在仓库外的 `D:/CodexWorkspace/Signing/Luoyuqiu`：
`legacy-debug.jks`、`release.p12`、`release-password.txt`、`debug-to-release.lineage`。
密码是随机生成的恢复材料，该目录仅授权当前 Windows 用户与 SYSTEM。
密钥及密码不得提交到 Git、发布到 Release 或写入日志。
另一份本机备份在 `C:/Users/Administrator/.android/luoyuqiu-signing-backup`。
这些仍是本机保存；设备损坏后的恢复需要另行保管完整签名目录。

专用证书指纹及本次实机结果写入接口仓库 `AI_HANDOFF.md`。
签名方案依据：https://developer.android.com/tools/apksigner 。
