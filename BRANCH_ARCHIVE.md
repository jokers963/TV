# 旧分支整理与恢复（2026-10-02）

当前定制版开发分支是 `luoyuqiu`，`fongmi` 用作上游同步参考。以下旧分支有独有提交，不把它们标为已合并，也不直接合入现有播放器。归档标签在删除旧预览分支之前已推送并核对远程提交。

| 旧分支 | 保留的提交 | 恢复标签 | 处理结果 |
| --- | --- | --- | --- |
| `build/luoyuqiu-preview` | `1306d40a3b779f458adf7d9bb32b065c64b59656` | `archive/luoyuqiu-preview-2026-10-02` | 完整历史保存到标签；无打开 PR，已删除远程及当前仓库的本地分支引用 |
| `fix/search-cover-fit` | `98fcdd14615e498a6522796296c35f8cc9a0197e` | `archive/search-cover-fit-2026-10-02` | 因 [PR #1](https://github.com/jokers963/TV/pull/1) 仍打开，保留分支和 PR，不关闭、合并或改写 |

需要回看旧预览源码时，先检查工作树未提交改动，再获取对应标签、使用独立工作树或新分支；不要将标签当作当前正式版本。示例（仅恢复查看，不合并）：

```powershell
git fetch origin tag archive/luoyuqiu-preview-2026-10-02
git worktree add --detach ../TV-preview-history archive/luoyuqiu-preview-2026-10-02
```

`build/luoyuqiu-563-searchfix` 在旧 `TV-cover-sync` 脏工作树中使用，仍有 staged/unstaged 定制，本轮不删除该工作树、分支或未提交文件。`TVUpstreamCompatibility` 及运行所需 AAR/签名材料同样保留。

实际开发目录的旧 README 已先保存到 stash `10660a9fd805f122750dd8791185e3bd97856a4a`，然后快进同步远程文档，并将开发目录/旧定制移植边界补入当前 README。stash 作为恢复证据保留，不重复 apply 造成重复段落。当前任务状态仍只维护在接口仓库的 [AI_HANDOFF](https://github.com/jokers963/CatVodSpider/blob/main/AI_HANDOFF.md)。
