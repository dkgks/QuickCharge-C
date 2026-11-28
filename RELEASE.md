# Quick Charge v3.1.17-c (Native C)

整合上游 `3.1.16–3.2.0` 启动可靠性增强，保留旧版 `state.conf` 兼容性及本分支全部 C 守护优化（`versionCode: 3011700`）。

## 主要变更

- **C 守护 `qcmon` 同步上游 `3.1.18-c` 增强**：
  - `log_env()` 新增 `overrides=N mounts=N nm=bind|nomount alive=yes|partial|no|-`，支持 NoMount / 元模块准确判活。
  - `plat_resolve()` 探测窗口调整为 `300s`（新增 `alor`），并在认对后打印候选表重算日志；`screen_sample()` 保留 `/sys/graphics/fb0/blank` 兜底路径。
- **启动与覆盖层同步上游 `3.1.16–3.2.0`**：
  - `post-fs-data.sh` 写入单调时钟 `phase.pfs`；`service.sh` 精确区分 `done` / `safe-mode` / 异常未完成并自动补建补挂；`lib/qc.sh` 改查 `mountinfo` 三态判活。
- **保留 3.1.16-c Fork 修复**：未插电 `vusb` 悬空 `µV` 噪声防放大与待机去重、`cells_resolve` 双电芯折算、`chg_input` 全候选兼容、`hot_cutoff` 高温安全断开、精简 WebUI/README。

## 发布产物

- `QuickCharge-v3.1.17-c.zip`：内置 ARM64 `bin/qcmon` 的完整可刷入模块包
- `update.json`：模块在线更新元数据
- `RELEASE.md`：本版本更新说明
