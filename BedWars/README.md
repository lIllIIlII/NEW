# DeepSeek BedWars

## 使用

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lIllIIlII/NEW/refs/heads/main/BedWars/BedWars.lua"))()
```

## 功能

### 战斗

| 功能 | 说明 |
| --- | --- |
| 杀戮光环 | 轮转发包，多目标，可调范围 / 数量 / 角度 |
| 静默瞄准 | 改写命中校验参数，不动视角 |
| 视角自瞄 | 平滑锁定，可调 FOV 与平滑度 |
| 弹道自瞄 | 弹道类武器瞬锁 |
| 自动转向 | 命中时面向目标 |

### 视觉

| 功能 | 说明 |
| --- | --- |
| ESP 玩家 | 红色像素标签 + 血条 + 距离 |
| ESP 怪物 | 橙色，BOSS 单独标记 |
| ESP 训练场人机 | 蓝色 |
| 显示血量 | 像素血条 + 数值 |
| 显示手持物品 | 标签附加武器名 |
| 床透视 | 按队配色，被拆转灰 |
| 床顶浮字 | TEAM N · ALIVE / DEAD |
| 容器透视 | 箱子 / 幸运方块 / 售货机 |
| 道具透视 | 本命 Kit 目标高亮 |
| 屏幕血量 | 屏幕中央 HP 数字 |

### 自动

| 功能 | 说明 |
| --- | --- |
| 自动拾取 | 扫描 ItemDrops，跳过刚掉落物 |
| 自动生成器 | 升级范围内己方发电机 |
| 自动护甲 | 装备最高级护甲 |
| 自动商店 | 按顺序购买剑类 |
| 自动换工具 | 切最佳镐子 |
| 自动吃药 | 血量阈值触发 |
| 自动开箱 | 观察箱内物品自动搬走 |
| 掉落丢弃 | 掉虚空自动丢手持 |
| 加速 | WalkSpeed |
| 防掉落 | 救援状态机，回到地面才停 |
| 防踢 | 定时清除 AFK 标记 |

### 奖励

| 功能 | 说明 |
| --- | --- |
| 领取全部 | 里程碑 + 成就 + 活动 + 团队 |
| 自动领奖 | 按间隔循环 |
| 全解锁 | 皮肤 / 特效 / 宠物 / 称号 / 床皮 / 徽章 |

### 设置

- 配色：14 套内置主题
- 强调色：自定义主色
- 走马灯：右侧屏幕滚动已开启功能
- 桌宠贴纸：7 个装饰部件独立开关
- 字体：字体家族 + 字号比例
- 声音：欢迎音效

## UI 库

```
https://raw.githubusercontent.com/lIllIIlII/NEW/refs/heads/main/deepseek-ui/main.lua
```

## 结构

```
BedWars/
  BedWars.lua   主脚本
  README.md     说明
```

## 说明

- 所有远程调用自动判别 RemoteEvent / RemoteFunction
- 命中载荷按服务端 sendServerRequest 校验链构造
- selfPosition 沿视线前推，保证距离校验通过
- ESP 使用 Roblox 内置像素字体 Enum.Font.Arcade
