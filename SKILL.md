---
name: codex-iphone-wechat
description: Send WeChat messages and images, and do other tasks, on the user's real iPhone through macOS iPhone Mirroring and the mirroir MCP tools. Use when the user asks to message someone on WeChat (微信) or to operate their iPhone. Fixed steps run as fast deterministic scripts; you handle the flexible steps. Text and images are always pasted, never typed.
---

# iPhone WeChat through iPhone Mirroring

You are the planner. Hand every **fixed** step to the scripts in this skill's folder (they replay recorded routes in seconds, no tokens), and use the mirroir MCP tools only for the **flexible** steps: anything the scripts cannot see or decide (an emoji-only contact name, an image preview sheet, an unexpected dialog, choosing what to reply). Run the scripts from this folder.

## Scripts (fixed steps)

| Command | Does | Typical time |
|---|---|---|
| `./wx open "<contact>"` | open the chat after checking the result row and title | ~18 s |
| `./wx list` | get to the WeChat chat list | ~6 s |
| `./wx send "<text>" [--to "<contact>"]` | paste into the open chat, check its input box, press Return | ~6–10 s in observed successful runs |
| `./wx image <file> [--to "<contact>"]` | paste an image and tap Send on the preview | varies |
| `./outbox "<chat>" "<text>"` | log the text on the Mac and put it on the clipboard | 1.5 s |
| `./outbox "<chat>" --image <file>` | same for a PNG/JPG image | 1.5 s |

Raise iPhone Mirroring before every send. Paste once, keep the verified field focused, and use plain Return once. Allow the mirror to refresh and verify a new outgoing bubble. If the draft remains, inspect it. When the emoji panel shows a green Send button, tap it only after checking the draft and confirming there is no new bubble. Inspect the chat before retrying any interrupted action. Read `chat-log/route.log` for the input box OCR and route errors. On a paste permission prompt, ask the user to allow the paste.

Use the contact name exactly as WeChat shows it. For an emoji-only name, run `./wx list`, select the contact visually and check its title in a screenshot before using the open-chat commands.

## Flexible steps (mirroir tools), paste-only

1. **Never type on the phone** (`type_text` is disabled: iOS autocorrect rewrites typed text). To enter text or an image: `./outbox …`, tap the input field, then `press_key` key `v` with modifier `command`.
2. An image pasted into a WeChat chat shows a preview sheet: check it is the right picture, then tap its **Send** button.
3. Before each Return/Send: read the screen and check the chat title and the exact text.
4. Read the screen as text when you can (`describe_screen` with `omit_screenshot: true`); take a `screenshot` only when you need to see pictures or emoji.
5. Sending, posting, buying, deleting: only what the user approved (contact + exact text/file). Never on your own initiative.
6. A tap refused because another window covers the mirror: tell the user to move that window; do not retry.

Setup and troubleshooting: README.md in this folder.
