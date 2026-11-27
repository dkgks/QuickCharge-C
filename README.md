# Quick Charge C (Native Daemon)

适用于 OPPO / 一加 / realme（ColorOS / RealmeUI）的轻量级温控伪装与快充解锁模块（原生 ARM64 C 语言守护进程 `qcmon`），支持 **Magisk / KernelSU / APatch**。

> 本仓库 Fork 自 [XiaohaoQvQ/QuickCharge-C](https://github.com/XiaohaoQvQ/QuickCharge-C)，提供纯 C 原生守护进程以降低唤醒与内存开销，并新增高温断开兜底与 ARM64 交叉编译 CI/Release 流水线。Shell 脚本版见 [dkgks/QuickCharge](https://github.com/dkgks/QuickCharge)。

## 核心特性

- **原生 `qcmon` ARM64 守护进程**：由 C 实现主循环与传感器读取，显著降低 Shell 子进程频繁 `fork` 带来的能耗与延迟。
- **壳温伪装与物理高温断开（Fork 新增）**：默认 `charge` 模式（基准 `30℃`，可调 `20–33℃`）；支持 `hot_cutoff`（`off` 或 `42–55℃`），超温恢复真实温控并在降温 `3℃` 后自动重接。
- **全套温控与快充解锁**：支持核温（`core` / `noncore` `20–100℃`）、电池温度（`batt` `20–45℃`）及快充电流限制解除（`unlock`）。
- **高刷锁定与守护**：支持 `90–185Hz`（`soft` / `hard`）锁定与 `hzguard` 掉刷监控。
- **安全与体验优化**：移除安装期弹窗；拔线时清理 `scr.fail` 并保留 `fcc.norm`。

## 快速上手

1. 前往 [Releases](https://github.com/dkgks/QuickCharge-C/releases/latest) 下载 `QuickCharge-v3.1.16-c.zip`。
2. 在 Magisk / KernelSU / APatch 中刷入模块并重启（模块内已内置经 CI 静态/交叉编译验证的 ARM64 `bin/qcmon`）。
3. 通过 **WebUI** 或 `action.sh` / `qcmon` 命令行管理。

### 默认配置

| 配置项 | 默认值 | 可调范围 / 说明 |
| --- | --- | --- |
| 壳温模式 (`temp_mode`) | `charge` | `off` / `static` / `charge` |
| 基准壳温 (`shell_temp`) | `30℃` | `20–33℃`（动态曲线偏移 `+12℃`） |
| 物理高温断开 (`hot_cutoff`) | `off` | `off` / `42–55℃`（滞回 `3℃`） |
| 电池/核温伪装 | `off` | 电池 `20–45℃`，核心/非核心 `20–100℃` |
| 快充解锁 (`chg_unlock`) | `0`（关） | `on` / `off` |
| 轮询周期 (`tick`) | `15s` | 守护进程巡检间隔 |

## 命令行参考

### 模块控制 (`action.sh`)

```sh
sh action.sh temp [off|static|charge [T]]   # 切换温控模式
sh action.sh base <20-33>                   # 设置基准壳温
sh action.sh cutoff <off|42-55>             # 设置物理高温断开阈值
sh action.sh batt <off|20-45>               # 电池温度伪装
sh action.sh core <off|20-100>              # 核心温度伪装
sh action.sh noncore <off|20-100>           # 非核心温度伪装
sh action.sh unlock <on|off>                # 快充限制解锁
sh action.sh hz <off|90..185> [soft|hard]   # 刷新率锁定
sh action.sh hzguard <on|off>               # 刷新率守护
sh action.sh overrides <on|off>             # 覆盖层开关
sh action.sh status | chg | tiers | zones   # 状态与节点诊断
sh action.sh logs [i|w|e|boot|daemon] [N]   # 查看日志
sh action.sh level <0-4>                    # 调整日志等级
sh action.sh rebuild | restart | reset      # 重建映射 / 重启 / 重置
```

### 原生守护进程工具 (`bin/qcmon`)

```sh
qcmon zones       # 列出识别到的 thermal_zone 及权重排序
qcmon once        # 执行单次巡检并输出决策结果
qcmon chg         # 读取当前充电状态与电流/电压
qcmon sensor      # 采集并打印核心温度传感器读数
qcmon bench [N]   # 运行 N 轮轮询性能基准测试
qcmon -v          # 查看 qcmon 版本信息
```

## CI 与上游致谢

- GitHub Actions 在 `aarch64-linux-gnu` 工具链下自动编译 `bin/qcmon`，并通过 QEMU user-mode 运行 `tests/c-test.sh` 及全部 Shell 单元测试验证。
- 上游致谢：[XiaohaoQvQ/QuickCharge-C](https://github.com/XiaohaoQvQ/QuickCharge-C)
