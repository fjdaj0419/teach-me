#!/usr/bin/env python3
"""校验 teach-me skill 的 SKILL.md：frontmatter、必填字段、版本号、关键章节。"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILL = ROOT / "SKILL.md"

REQUIRED_KEYS = [
    "slug", "displayName", "name", "version", "summary",
    "license", "description", "disable-model-invocation",
]
REQUIRED_SECTIONS = [
    "## 定位", "## 核心规则", "## 执行流程",
    "## 轻度模式流程", "## 深度模式流程",   # 三档模式（v2.0.0+）
    "## 风格约束", "## 不适合的场景",
]
VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")

errors = []


def fail(msg):
    errors.append(msg)


def main():
    if not SKILL.exists():
        fail("缺少 SKILL.md")
        return report()

    text = SKILL.read_text(encoding="utf-8")
    lines = text.splitlines()

    if not lines or lines[0].strip() != "---":
        fail("SKILL.md 必须以 --- 开头（YAML frontmatter）")
        return report()

    try:
        end = lines.index("---", 1)
    except ValueError:
        fail("frontmatter 没有闭合的 ---")
        return report()

    head = {}
    for raw in lines[1:end]:
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        if ":" in raw:
            key, value = raw.split(":", 1)
            head[key.strip()] = value.strip()

    for key in REQUIRED_KEYS:
        if key not in head or not head[key]:
            fail(f"frontmatter 缺少必填字段或为空: {key}")

    if "version" in head and not VERSION_RE.match(head["version"]):
        fail(f"version 格式应为 x.y.z，当前: {head['version']}")

    if "disable-model-invocation" in head and head["disable-model-invocation"].lower() not in ("true", "false"):
        fail("disable-model-invocation 必须是 true 或 false")

    body = "\n".join(lines[end + 1:])
    for section in REQUIRED_SECTIONS:
        if section not in body:
            fail(f"正文缺少章节: {section}")

    if "第 0 步" not in body:
        fail("执行流程缺少第 0 步（开场硬闸门）")

    # v2.2.0：深度模式的「小测验 + 疑点确认」必须靠打字，不许弹框
    deep2 = slice_between(body, "### 深度-2", "### 深度-3")
    if not deep2:
        fail("缺少深度-2 小节（小测验 + 疑点确认）")
    else:
        if "禁止用 AskUserQuestion" not in deep2:
            fail("深度-2 必须明确「禁止用 AskUserQuestion」（手打回答，不弹框）")
        for tag in ("环节 A", "环节 B"):
            if tag not in deep2:
                fail(f"深度-2 缺少 {tag}")
        if "用 **AskUserQuestion** 出" in deep2:
            fail("深度-2 仍在用 AskUserQuestion 出选择题，应改为纯文字让用户打字")

    # v2.2.0：总进度条必须彩色（emoji 色块）+ 标题级，且与子进度条分主次
    for name, start, end in (
        ("深度-0", "### 深度-0", "### 深度-1"),
        ("深度-1", "### 深度-1", "### 深度-2"),
    ):
        sec = slice_between(body, start, end)
        if "## 🟪" not in sec:
            fail(f"{name} 的总进度条必须是「## + 彩色 emoji 色块」（如 ## 🟪🟦🟩🟨⬜...），不能退回单色 ▓░")
    if "总进度" not in body or "子进度" not in body:
        fail("必须同时存在「总进度」与「子进度」两级进度条描述")

    return report()


def slice_between(text, start_marker, end_marker):
    """取 start_marker 到 end_marker 之间的正文，找不到返回空串。"""
    start = text.find(start_marker)
    if start == -1:
        return ""
    end = text.find(end_marker, start + len(start_marker))
    return text[start:end] if end != -1 else text[start:]


def report():
    if errors:
        print("SKILL.md 校验失败：")
        for i, err in enumerate(errors, 1):
            print(f"  {i}. {err}")
        return 1
    print("SKILL.md 校验通过 ✅  frontmatter / 必填字段 / 版本号 / 关键章节均正常")
    return 0


if __name__ == "__main__":
    sys.exit(main())
