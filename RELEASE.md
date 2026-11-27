# Quick Charge v3.1.16-c (Native C)

基于上游 `XiaohaoQvQ/QuickCharge-C` 构建的 ARM64 原生 C 守护进程版发布包，更新通道 `c`（`versionCode: 3011600`）。

## 主要变更

- **修复未插电 `vusb` 噪声放大与待机刷屏**：未插电时不再把 `µV` 级悬空噪声（如 `1000–8000 µV`）误判为 `mV` 放大成 `1~8V`；未充电判重签名忽略瞬时负载波动与悬空 `vusb` 跳变。
- **补齐骁龙新平台识别 (`plat_resolve`)**：新增 `canoe`（SM8850）、`kalama`、`crow` 等平台代号及 `ro.soc.model` / `ro.hardware` 识别，消除 C 守护误判 `other` 的问题。
- **修复默认 `fb` 节点路径**：更正为 `/sys/class/graphics/fb0/blank`，与 Shell 侧保持一致。
- **支持电芯数检测 (`cells_resolve`) 与双电芯功率计算**：不再硬编码 `cells=?`，同步支持 `cells_mode`、`aging_ffc_data`、`bcc_parms` 与包电压推断，并在 `pb` 计算中按双芯折算。
- **对齐输入电流候选 (`chg_input`)**：补齐 `oplus_chg` 及 `charger/battery` 输入电流节点并兼容负值归一。
- **继承 3.1.15-c 增强**：`hot_cutoff` 高温断开兜底、`scr.fail` 拔线清理、`customize.sh` 静默安装。

## 发布产物

- `QuickCharge-v3.1.16-c.zip`：内置 ARM64 `bin/qcmon` 的完整可刷入模块包
- `update.json`：模块在线更新元数据
- `RELEASE.md`：本版本更新说明
