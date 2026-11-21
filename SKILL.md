---
name: codex-iphone-wechat
description: Send WeChat messages, and do other tasks, on the user's real iPhone through macOS iPhone Mirroring and the mirroir MCP tools. Use when the user asks to message someone on WeChat (微信) or to operate their iPhone. Fast fixed route (wxsend), and text is always pasted, never typed.
---

# iPhone WeChat through iPhone Mirroring

The scripts sit in this skill's folder (the one this SKILL.md is in). Run them from there.

## Send a WeChat message: use the fixed route first

```bash
./wxsend "<contact name exactly as WeChat shows it>" "<message>"
```

- It replays deterministic mirroir routes (`routes/*.yaml`) with no model in the loop: about 23 s.
- Exit 0 prints `sent to <contact> in <s>s`. Any other exit means **nothing was sent**; the reason is printed and the steps are in `chat-log/route.log`. Do not retry in a loop; tell the user what failed.
- Every message goes into `chat-log/outbox.md` on the Mac.
- Before sending, make sure the user approved this contact and this exact text. A message is not something to send on your own initiative.
- A contact whose name is only emoji cannot be OCR-checked by wxsend: use the mirroir tools below and check the chat title in a screenshot.

## Anything else on the phone: the mirroir MCP tools, paste-only

1. **Never type on the phone.** `type_text` makes iOS autocorrect rewrite text (capitals, word swaps). Instead:
   - `./outbox "<where it goes>" "<text>"` puts the text on the clipboard (and logs it), waits for Universal Clipboard;
   - tap the field, then `press_key` key `v` with modifier `command` (⌘V);
   - read the screen and check the text before pressing Return.
2. Read the screen as text when you can: `describe_screen` with `omit_screenshot: true` is faster and much smaller.
3. Do several known steps at once with `run_steps` instead of one tool call per step.
4. Before sending, posting, buying or deleting, confirm with the user unless the request already names the exact item and text.
5. If a tap is refused because another window covers the mirror, tell the user to move that window or the iPhone Mirroring window; do not retry.

Setup and troubleshooting: README.md in this folder.
