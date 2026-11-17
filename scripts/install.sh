#!/usr/bin/env bash
# ============================================================
# teach-me · 跨工具安装脚本
# 把本技能（SKILL.md + README.md）复制到各个 AI 工具读取的 skills 目录
# Agent Skills 是开放标准，同一份 SKILL.md 换个目录就能被别的工具加载
# ============================================================
set -eu

SRC_DIR=$(cd "$(dirname "$0")/.." && pwd)
SKILL_FILE="$SRC_DIR/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "✗ 找不到 ${SKILL_FILE}，请在技能目录内运行" >&2
  exit 1
fi

# 从 SKILL.md 的 frontmatter 读技能名（必须与目标文件夹同名）
NAME=$(awk -F': *' '/^name:/{print $2; exit}' "$SKILL_FILE" | tr -d '\r')
if [ -z "$NAME" ]; then
  echo "✗ 无法从 SKILL.md 读取 name 字段" >&2
  exit 1
fi

SCOPE="local"     # local = 当前项目；global = 用户主目录
AGENTS=""
FORCE=0
DRY=0
UNINSTALL=0

usage() {
  cat <<'EOF'
用法: scripts/install.sh [选项]

选项:
  -g, --global           安装到用户主目录（对这台机器的所有项目生效）
                         不加此参数 = 安装到当前目录（只对这个项目生效）
  -a, --agents LIST      指定工具，逗号分隔（默认全部）
                         可选: claude, cursor, agents, codex, gemini, copilot, workbuddy
  -f, --force            目标已存在时覆盖（默认跳过，不碰已有文件）
  -n, --dry-run          只打印将要写入的位置，不实际复制
  -u, --uninstall        从目标目录卸载本技能
      --list             打印各工具的安装路径对照表
  -h, --help             显示本帮助

示例:
  scripts/install.sh                          # 装到当前项目下所有工具目录
  scripts/install.sh -a claude,cursor -g      # 只装到 Claude Code + Cursor（全局）
  scripts/install.sh -g -a workbuddy -f       # 覆盖安装到 WorkBuddy（全局）
  scripts/install.sh -u -g -a claude          # 从全局 Claude Code 卸载
EOF
}

# 各工具的 skills 目录：第一个参数=工具，第二个参数=local|global
dest_dir() {
  _agent=$1
  _scope=$2
  if [ "$_scope" = "global" ]; then
    case "$_agent" in
      claude)    echo "$HOME/.claude/skills" ;;
      cursor)    echo "$HOME/.cursor/skills" ;;
      agents)    echo "$HOME/.agents/skills" ;;
      codex)     echo "$HOME/.codex/skills" ;;
      gemini)    echo "$HOME/.gemini/skills" ;;
      copilot)   echo "$HOME/.copilot/skills" ;;
      workbuddy) echo "$HOME/.workbuddy/skills" ;;
    esac
  else
    case "$_agent" in
      claude)    echo "$PWD/.claude/skills" ;;
      cursor)    echo "$PWD/.cursor/skills" ;;
      agents)    echo "$PWD/.agents/skills" ;;
      codex)     echo "$PWD/.codex/skills" ;;
      gemini)    echo "$PWD/.gemini/skills" ;;
      copilot)   echo "$PWD/.github/skills" ;;
      workbuddy) echo "" ;;   # WorkBuddy 只读用户级目录
    esac
  fi
}

print_list() {
  echo "工具            项目级目录                用户级目录"
  echo "--------------  ------------------------  ------------------------"
  echo "claude          .claude/skills            ~/.claude/skills"
  echo "cursor          .cursor/skills            ~/.cursor/skills"
  echo "agents          .agents/skills            ~/.agents/skills   （Codex / Gemini / Cursor 共享路径，推荐只装这个）"
  echo "codex           .codex/skills             ~/.codex/skills"
  echo "gemini          .gemini/skills            ~/.gemini/skills"
  echo "copilot         .github/skills            ~/.copilot/skills"
  echo "workbuddy       —（仅用户级）            ~/.workbuddy/skills"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -g|--global)    SCOPE="global" ;;
    -a|--agents)    shift; AGENTS="${1:-}" ;;
    --agents=*)     AGENTS="${1#*=}" ;;
    -f|--force)     FORCE=1 ;;
    -n|--dry-run)   DRY=1 ;;
    -u|--uninstall) UNINSTALL=1 ;;
    --list)         print_list; exit 0 ;;
    -h|--help)      usage; exit 0 ;;
    *) echo "✗ 未知参数: $1（用 -h 看用法）" >&2; exit 2 ;;
  esac
  shift
done

if [ -z "$AGENTS" ]; then
  # 默认装 agents 这个共享路径（Codex / Gemini / Cursor 都会读 .agents/skills），
  # 不再同时装 codex、gemini，否则同一个技能会在它们的清单里出现两遍。
  AGENTS="claude,cursor,agents,copilot,workbuddy"
fi

# 重叠检测：.agents/skills 是 Codex / Gemini / Cursor 的共享路径，
# 同时指定 agents 和它们中的任何一个，会导致技能被列出两次。
case ",${AGENTS}," in
  *,agents,*)
    for other in codex gemini; do
      case ",${AGENTS}," in
        *",${other},"*)
          echo "⚠️  同时指定了 agents 和 ${other}：${other} 会读两处同名技能，清单里会出现两条 teach-me。建议只留 agents。" >&2
          ;;
      esac
    done
    ;;
esac

OLD_IFS=$IFS
IFS=','
set -- $AGENTS
IFS=$OLD_IFS

echo "技能: $NAME"
echo "来源: $SRC_DIR"
if [ "$SCOPE" = "global" ]; then
  echo "范围: 用户级（${HOME}）"
else
  echo "范围: 项目级（${PWD}）"
fi
[ "$DRY" -eq 1 ] && echo "模式: dry-run（只打印，不写入）"
echo ""

OK=0
SKIPPED=0
FAILED=0

for agent in "$@"; do
  dir=$(dest_dir "$agent" "$SCOPE")

  if [ -z "$dir" ]; then
    echo "  - ${agent}：仅支持用户级安装，本次跳过（加 -g 再试）"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  target="$dir/$NAME"

  # 卸载
  if [ "$UNINSTALL" -eq 1 ]; then
    if [ ! -d "$target" ]; then
      echo "  - ${agent}：未安装，跳过"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
    if [ "$DRY" -eq 1 ]; then
      echo "  - ${agent}：[dry-run] 将删除 $target"
      OK=$((OK + 1))
      continue
    fi
    # 安全护栏：只删「名字恰好等于技能名」的目录
    case "$target" in
      */"$NAME")
        rm -rf "$target"
        echo "  - ${agent}：🗑  已卸载 $target"
        OK=$((OK + 1))
        ;;
      *)
        echo "  - ${agent}：✗ 路径不符合预期，拒绝删除：$target"
        FAILED=$((FAILED + 1))
        ;;
    esac
    continue
  fi

  # 源目录 == 目标目录（例如仓库就放在 ~/.workbuddy/skills/teach-me 里）
  if [ -d "$target" ] && [ "$target" -ef "$SRC_DIR" ]; then
    echo "  - ${agent}：就是当前目录，无需安装 → $target"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # 安装
  if [ -d "$target" ] && [ "$FORCE" -eq 0 ]; then
    echo "  - ${agent}：已存在，跳过（要覆盖加 -f）→ $target"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  if [ "$DRY" -eq 1 ]; then
    echo "  - ${agent}：[dry-run] 将写入 $target"
    OK=$((OK + 1))
    continue
  fi

  if mkdir -p "$target" && cp "$SKILL_FILE" "$target/SKILL.md"; then
    if [ -f "$SRC_DIR/README.md" ]; then
      cp "$SRC_DIR/README.md" "$target/README.md"
    fi
    echo "  - ${agent}：✅ $target"
    OK=$((OK + 1))
  else
    echo "  - ${agent}：✗ 写入失败 $target" >&2
    FAILED=$((FAILED + 1))
  fi
done

echo ""
if [ "$UNINSTALL" -eq 1 ]; then
  echo "完成：卸载 $OK 个 · 跳过 $SKIPPED 个 · 失败 $FAILED 个"
else
  echo "完成：安装 $OK 个 · 跳过 $SKIPPED 个 · 失败 $FAILED 个"
fi

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
