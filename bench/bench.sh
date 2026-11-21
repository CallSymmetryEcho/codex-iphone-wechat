#!/bin/zsh
# Same WeChat task, one Codex model after another, through mirroir-mcp (paste-only).
# Usage: bench/bench.sh gpt-6.1-terra gpt-6-luna gpt-6.2-sol gpt-6.2-astra
# Runs from bench/: mirroir reads bench/.mirroir-mcp/permissions.json (no type_text, no launch_app).
cd "${0:A:h}"
export PATH=$HOME/.local/bin:$PATH   # codex
M=(${=MIRROIR:-$(command -v mirroir-mcp || echo npx -y mirroir-mcp@0.50.3)})
mkdir -p results
for m in "$@"; do
  (cd ../routes && $M test iphone-home.yaml >/dev/null 2>&1)   # same starting point for every model
  msg="mirroir test $m"
  t0=$(date +%s)
  ../outbox "File Transfer" "$msg" >/dev/null   # the Mac prepares and logs the text; the phone only pastes it
  prompt="用 mirroir 的 MCP 工具操作我的 iPhone（iPhone 镜像已连接）。任务：打开微信 → 进入文件传输助手对话（手机是英文界面，叫 File Transfer）→ 把已经放在剪贴板里的消息「$msg」粘贴进输入框并发送。
不能在手机上打字（type_text 已经禁用）。输入的唯一办法是：点输入框，然后 press_key 按 v 加 command 修饰键（也就是 ⌘V）粘贴。
规则：只能发给 File Transfer，绝对不要发给任何其他联系人；发送前先读屏，确认对话标题是 File Transfer，并确认输入框里正好是「$msg」（如果有残留文字，先按 ⌘A 再按 delete 清空，然后重新粘贴）；确认无误后按 return 发送（我已经批准发送这一条消息到 File Transfer，不用再问我；只要标题或文字不对就不要发），发送后再读屏，确认消息已经出现在对话里。提示：手机从主屏开始，微信图标在底部 Dock 栏（绿色气泡图标）。不要运行 shell 命令。最后用一句话报告：成功或失败，以及卡在哪里。"
  # Only mirroir: other MCP servers just burn tokens here. Edit the list to match `codex mcp list`.
  off=(); for s in ${=BENCH_DISABLE_MCP:-}; do off+=(-c "mcp_servers.$s.enabled=false"); done
  # approval_policy=never + mirroir tools pre-approved: permissions.json, not per-call prompts, decides what the model may do
  codex exec -m "$m" "${off[@]}" -c approval_policy='"never"' -c 'mcp_servers.mirroir.default_tools_approval_mode="approve"' \
    -s read-only --skip-git-repo-check \
    --json -o "results/$m.last.md" "$prompt" > "results/$m.jsonl" 2> "results/$m.err"
  echo "$m exit=$? seconds=$(( $(date +%s) - t0 ))" >> results/summary.txt
done
echo done >> results/summary.txt
