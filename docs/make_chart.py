# Writes docs/speed.svg from the measured runs (2026-11-21, one run each). PNG: see README.
# Seconds: (label, model thinking, phone actions, start-up + clipboard sync)
ROWS = [
    ("固定路线 wxsend", 0, 19, 4),
    ("Terra 6.1", 35, 18, 7),
    ("Luna 6", 46, 18, 4),
    ("Sol 6.2", 63, 32, 5),
    ("Astra 6.2", 80, 15, 5),
]
SEGS = [("模型思考", "#2a78d6"), ("手机操作（mirroir）", "#eb6834"), ("启动 + 剪贴板同步", "#1baf7a")]
W, L, R, top, bh, gap, maxv = 760, 130, 70, 86, 30, 18, 110
H = top + 14 + len(ROWS) * (bh + gap) + 40
pw = W - L - R
sx = lambda v: v / maxv * pw
o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
     'font-family="-apple-system,PingFang SC,Helvetica,sans-serif">',
     f'<rect width="{W}" height="{H}" fill="#fcfcfb"/>',
     '<text x="24" y="34" font-size="18" font-weight="600" fill="#0b0b0b">发一条微信要多久：时间花在哪里</text>',
     '<text x="24" y="56" font-size="13" fill="#52514e">从 iPhone 主屏到发送成功 · 只粘贴不打字 · 单次运行 · 单位：秒</text>']
lx = 24
for name, c in SEGS:
    o.append(f'<rect x="{lx}" y="68" width="12" height="12" rx="2" fill="{c}"/>'
             f'<text x="{lx + 18}" y="79" font-size="12" fill="#52514e">{name}</text>')
    lx += 18 + len(name) * 12 + 30
bottom = top + 14 + len(ROWS) * (bh + gap) - gap
for t in range(0, 111, 20):
    x = L + sx(t)
    o.append(f'<line x1="{x}" y1="{top + 4}" x2="{x}" y2="{bottom + 6}" stroke="#e4e3df"/>'
             f'<text x="{x}" y="{bottom + 22}" font-size="11" fill="#52514e" text-anchor="middle">{t}</text>')
for i, (n, *vals) in enumerate(ROWS):
    y = top + 14 + i * (bh + gap)
    x = L
    o.append(f'<text x="{L - 10}" y="{y + bh / 2 + 5}" font-size="13" fill="#0b0b0b" text-anchor="end">{n}</text>')
    for v, (name, c) in zip(vals, SEGS):
        if not v:
            continue
        w = sx(v) - 2  # 2px surface gap between segments
        o.append(f'<rect x="{x}" y="{y}" width="{w}" height="{bh}" fill="{c}"><title>{n} · {name}: {v} 秒</title></rect>')
        if v >= 12:
            o.append(f'<text x="{x + w / 2}" y="{y + bh / 2 + 4}" font-size="11" fill="#fff" text-anchor="middle">{v}</text>')
        x += sx(v)
    o.append(f'<text x="{x + 6}" y="{y + bh / 2 + 5}" font-size="13" font-weight="600" fill="#0b0b0b">{sum(vals)} 秒</text>')
o.append('</svg>')
open(__file__.replace("make_chart.py", "speed.svg"), "w").write("\n".join(o))
