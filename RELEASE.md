# Quick Charge v3.1.15-c (Native C)

基于上游 `XiaohaoQvQ/QuickCharge-C` 构建的 ARM64 原生 C 守护进程版发布包，更新通道 `c`（`versionCode: 3011500`）。

## 主要变更

- **新增物理高温断开兜底 (`hot_cutoff`)**：在 `qcmon.c`、`qc.sh`、`action.sh` 与 WebUI 同步支持 `42–55℃` 硬保护阈值及 `3℃` 降温滞回恢复，兼顾快充性能与热安全。
- **优化拔线状态恢复**：将 `scr.fail` 异常标记改为拔线时自动清理，并保留已校准的 `fcc.norm` 满充参考值。
- **精简安装流程**：移除 `customize.sh` 刷入弹窗。
- **ARM64 CI/CD 流水线**：使用 `aarch64-linux-gnu-gcc` 自动交叉编译 `bin/qcmon`，并通过 QEMU `tests/c-test.sh` 与全部单元测试后自动打包发布；更新源指向 `dkgks/QuickCharge-C`。

## 发布产物

- `QuickCharge-v3.1.15-c.zip`：内置 ARM64 `bin/qcmon` 的完整可刷入模块包
- `update.json`：模块在线更新元数据
- `RELEASE.md`：本版本更新说明
