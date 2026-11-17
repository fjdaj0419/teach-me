# Teach Me · 零基础比喻教学

一个 WorkBuddy 技能（Skill）：把任何概念、公式、知识点讲给零基础的学习者听，支持**轻度 / 中档 / 深度**三档教学。

核心思路：**用比喻把人讲懂，用彩图把人看透，用动画让人玩明白，再用公式把人讲准。**

## 三档模式

开场会先弹出选择框让你定档，选定后全程按该档执行：

| 档位 | 适合场景 | 产出 | 大致耗时 |
|---|---|---|---|
| **轻度** | 快速搞懂大概，不需要细节 | 一段大白话 + 1 张导图 + 1 个 h5 演示 | 3–5 分钟 |
| **中档**（默认推荐） | 想把一个知识点完整吃透 | 四阶段完整教学 + 多张彩色图 + ≥3 个 h5 + 公式落地 | 10–15 分钟 |
| **深度** | 想彻底搞懂一个大问题，愿意分多轮学 | 拆成若干子问题逐个精讲 + 每节小测与答疑 + 合并总结 | 25 分钟以上、多轮 |

## 它能做什么

- **开场双闸门（两次弹框）**：先弹档位选择框，紧接着再弹一次需求追问框（轻度 2 题 / 中档 3 题 / 深度 4 题，都是选择题）——不会上来就讲，也不会用文字罗列选项糊弄你。
- **比喻先行**：先用生活场景建立直觉，零术语、零符号。
- **彩色可视化**：思维导图、关系图、流程图、对照表，用多色区分层级。
- **多彩互动动画**：中档至少 3 个 h5 演示，每个 4–6 种配色 + 多种动效 + 可交互。
- **阶段进度**：4 个学习阶段（建立直觉 → 搭建桥梁 → 落地精确 → 收口锚定），阶段之间用空行 + 加粗标题断开，配进度条，不堆分隔线。
- **强制落地**：结尾一定回到精确定义 / 公式 / 可核对的具体物，不只停在概念层面。
- **深度模式特色**：把大问题拆成 2–5 个子问题，先给拆分导图与**彩色大号总进度条**；每个子问题按完整四阶段讲一遍；结尾连出两题——一道选择题考你、一道问你哪里不懂，**两题都是纯文字、你在对话里直接打字回答，不弹任何选项框**；下一节开头先公布答案、解答疑问；**阶段之间只用空行 + 标题断开、不画线**，只有子问题之间用一行内联横幅（`══════ ▶ 子问题 2/4 · 标题 ══════`）——线条少但一眼能看出换节；全部学完做文字总结 + 子问题合并导图。
- **两条进度条分主次**：总进度用 `## 🟪🟦🟩🟨⬜⬜⬜⬜⬜⬜  总进度 2/4 · 子问题二`（彩色色块 + 标题级字号），子进度用 `【▓▓░░░░░░░░】阶段 2/4`（细字符、正文级）——总进度永远更大更彩色。

## 怎么用

这是一个**可选调用**技能，不会在普通对话里自动触发。需要你主动点名：

```
@skill:teach-me 讲讲梯度下降
```

或者：

```
/teach-me 什么是傅里叶变换
```

也可以直接说「教我」「给我讲讲」「零基础解释一下」「用比喻讲」「帮我搞懂 XX」等。

如果你不想被追问、想直接开讲，加一句「别问了，直接讲」即可（档位选择框仍会弹出）。

## 装到别的 AI 工具（跨工具使用）

`SKILL.md` 是开放的 **Agent Skills** 标准格式，Claude Code、Cursor、Codex、Gemini CLI、GitHub Copilot 等几十个工具都读同一份文件——区别只在**放在哪个目录**。仓库里带了安装脚本，一条命令搞定。

### 快速开始

```bash
# 1. 克隆仓库
git clone git@github.com:fjdaj0419/teach-me.git
cd teach-me

# 2. 装到当前项目下的所有工具目录（.claude / .cursor / .agents / .codex / .gemini / .github）
./scripts/install.sh

# 3. 或者只装给某个工具，并且装成"全局可用"（对这台机器所有项目生效）
./scripts/install.sh -g -a claude,cursor
```

装完在对应工具里用 `/teach-me`（Claude Code、Cursor）或 `$teach-me`（Codex）点名调用。

### 全部参数

| 参数 | 作用 |
|---|---|
| 无参数 | 装到**当前项目**下所有工具目录（只对这个仓库生效） |
| `-g` / `--global` | 装到**用户主目录**（这台机器所有项目都能用） |
| `-a` / `--agents LIST` | 指定工具，逗号分隔：`claude,cursor,agents,codex,gemini,copilot,workbuddy` |
| `-f` / `--force` | 目标已存在时覆盖（默认跳过，不碰已有文件） |
| `-n` / `--dry-run` | 只打印要写入的位置，不实际复制 |
| `-u` / `--uninstall` | 从目标目录卸载本技能 |
| `--list` | 打印各工具的路径对照表 |
| `-h` / `--help` | 显示帮助 |

### 各工具路径对照

| 工具 | 项目级 | 用户级 | 调用方式 |
|---|---|---|---|
| WorkBuddy | —（仅用户级） | `~/.workbuddy/skills/` | `@skill:teach-me` |
| Claude Code | `.claude/skills/` | `~/.claude/skills/` | `/teach-me` |
| Cursor | `.cursor/skills/` / `.agents/skills/` | `~/.cursor/skills/` / `~/.agents/skills/` | `/` 菜单选 |
| Codex | `.codex/skills/` / `.agents/skills/` | `~/.codex/skills/` / `~/.agents/skills/` | `$teach-me` |
| Gemini CLI | `.gemini/skills/` / `.agents/skills/` | `~/.gemini/skills/` / `~/.agents/skills/` | 模型自动识别 |
| GitHub Copilot | `.github/skills/` | `~/.copilot/skills/` | `/` 菜单选 |

### 几个实际使用注意

- **脚本只复制 `SKILL.md` 和 `README.md`**，不会碰 `.git`、`.github`、`scripts/`；目标目录里已有同名技能时默认**跳过**，要覆盖请显式加 `-f`。
- **卸载有护栏**：只删「文件夹名恰好等于技能名」的目录，路径不符会拒绝执行。
- **会自动降级，不会卡住**：本技能依赖 WorkBuddy 的 `show_widget`（内联画图）和 `AskUserQuestion`（弹框）。换到别的工具后，SKILL.md 里的「跨平台降级」章节会自动接管——图改成可运行的 SVG / HTML 代码块（或 Mermaid），弹框改成编号文字问题，流程不中断。
- **扩展字段被忽略**：`slug`、`displayName`、`summary`、`tags`、`disable-model-invocation` 是 WorkBuddy 侧的字段，标准里没有；其他工具会静默跳过，不报错，只是不生效（比如「不自动触发」这条在 Codex 里无效）。
- 合规性已核对：`name: teach-me` 与目录同名、`description` 621 字符（上限 1024），符合 Agent Skills 规范。

## 适用学科

数学、编程、物理、化学、生物、历史、经济、语言学……不限领域，只要是需要"从零讲懂"的知识点都适用。

## 文件说明

- `SKILL.md` —— 技能定义（YAML 头部 + 核心规则 + 三档流程 + h5 硬指标 + 排版规范），版本 v2.5.0。
- `scripts/install.sh` —— 跨工具安装脚本：一条命令把技能装到 Claude Code / Cursor / Codex / Gemini CLI / Copilot / WorkBuddy 的 skills 目录，支持 dry-run、覆盖、卸载。
- `scripts/validate_skill.py` —— 纯标准库校验脚本，检查 frontmatter、必填字段、版本号格式、关键章节是否齐全。
- `.github/workflows/validate.yml` —— CI：每次 push / PR 到 main 自动跑一次校验。

## 本地校验

```bash
python3 scripts/validate_skill.py
```

## License

MIT
