param(
    [string]$Apk = "$PSScriptRoot/../app/build/outputs/apk/mobile/release/mobile-arm64_v8a.apk",
    [string]$Output = "$PSScriptRoot/../Release/luoyuqiu-mobile-arm64_v8a.apk",
    [string]$SigningDirectory = 'D:/CodexWorkspace/Signing/Luoyuqiu',
    [string]$BuildTools = 'E:/DevTools/Android/sdk/build-tools/36.0.0'
)

$ErrorActionPreference = 'Stop'
$Apk = (Resolve-Path -LiteralPath $Apk).Path
$Output = [IO.Path]::GetFullPath($Output)
if ($Apk -eq $Output) { throw 'Signing output must be separate from the build APK.' }
if (Test-Path -LiteralPath $Output) { throw 'Output exists; choose a new output path.' }
$oldKey = Join-Path $SigningDirectory 'legacy-debug.jks'
$newKey = Join-Path $SigningDirectory 'release.p12'
$passwordFile = Join-Path $SigningDirectory 'release-password.txt'
$lineage = Join-Path $SigningDirectory 'debug-to-release.lineage'
$signer = Join-Path $BuildTools 'apksigner.bat'
$aapt = Join-Path $BuildTools 'aapt2.exe'
foreach ($file in @($oldKey, $newKey, $passwordFile, $lineage, $signer, $aapt)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Missing signing input: $file" }
}
$badging = & $aapt dump badging $Apk
if ($LASTEXITCODE -ne 0 -or $badging[0] -notmatch "^package: name='com\.jokers963\.luoyuqiu'") {
    throw 'Only the Luoyuqiu package may be signed.'
}
$null = New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($Output))
& $signer sign --ks $oldKey --ks-key-alias androiddebugkey --ks-pass pass:android `
    --next-signer --ks $newKey --ks-key-alias luoyuqiu --ks-pass "file:$passwordFile" `
    --lineage $lineage --rotation-min-sdk-version 28 --v4-signing-enabled false `
    --out $Output $Apk
if ($LASTEXITCODE -ne 0) { throw 'APK signing failed.' }
& $signer verify --verbose --print-certs $Output
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
$certificates = & $signer verify --min-sdk-version 28 --print-certs $Output
if ($LASTEXITCODE -ne 0 -or ($certificates -join "`n") -notmatch 'Signer #1 certificate SHA-256 digest: 83134ad0da0affc9b56943fda1a141201330f8874111c7b18cf4c8505debdec8') {
    throw 'Expected release certificate not found for Android 9+.'
}
$certificates
Get-FileHash -Algorithm SHA256 -LiteralPath $Output
