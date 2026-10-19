---
name: speak
description: 'Explain the most recent output in plain human language and read it out loud with espeak-ng. Use when the user asks what the last output/result means, wants it spoken, or says things like "explain that", "say it out loud", "talk me through the last output", or "/speak".'
allowed-tools: Bash
---

# Speak — explain the last output out loud

Turn the newest output into a short, plain-language explanation and speak it with espeak-ng.

## 1. Pick what to explain

- Use the **last thing that produced output** in this conversation: the most recent shell/tool result, or the last command's stdout/stderr.
- If the last turn was only prose with no output, walk back to the newest actual output.
- If several outputs are plausible, explain the newest and name the command it came from.
- If there is nothing to explain (fresh session), ask which output they mean.

## 2. Write the explanation for the ear, not the eye

- 2–5 short sentences. Say what the output **means**, not what it printed.
- Plain prose only: no markdown, no bullet characters, no backticks, no emoji or Nerd Font glyphs — espeak-ng reads them badly or drops them.
- Phrase it the way you'd say it aloud: "the Wi-Fi module now stays visible when Wi-Fi is off", not `#network.disabled { color: #ff453a; }`.
- Spell out what speech mangles: flags as "dash dash verbose", paths as "the waybar config in dot config", symbols as words ("greater than", "pipe", "slash").
- Numbers, versions and percentages are fine as digits.
- Lead with the answer. Leave detail for a follow-up if they ask for more.

## 3. Speak it

Write the text to a file first (keeps it out of the process list, avoids quoting problems), then hand it to this skill's helper:

```bash
cat > /tmp/opencode/speak-say.txt <<'EOF'
<plain-language explanation>
EOF
bash ~/.config/opencode/skills/speak/say.sh /tmp/opencode/speak-say.txt
```

- Default engine is **piper** (neural: `~/.local/share/piper/venv/bin/piper` + `voices/en_US-ryan-high.onnx`, `--length-scale 1.3`), falling back to espeak-ng (`-v en-us+m7 -s 115 -p 50 -a 180`) when piper is missing; `AI_ENGINE=piper|espeak` forces one.
- Piper overrides: `AI_PIPER`, `AI_PIPER_VOICE`, `AI_LENGTH_SCALE` (higher = slower). Espeak overrides: `AI_VOICE` (from `espeak-ng --voices`, variants `+f1`–`+f5`, `+m1`–`+m7`, `+croak`, `+whisper`), `AI_SPEED`, `AI_PITCH`, `AI_AMPL`, `AI_SSML=1`, `AI_PATH`.
- Pronunciation: `pronounce.tsv` holds `word<TAB>espeak<TAB>ipa` and say.sh substitutes the column for the active engine. Permanent espeak-only fixes live in `~/.local/share/espeak-ng-custom` (compiled dictionary via `--path`; piper ignores it — it phonemizes with bundled data, hence the ipa column).
- Mispronounced word? `bash …/say.sh --phonemes <file>` prints what the active engine will say.
- This **blocks until speech finishes** (piper adds a second of synthesis before playback). Keep the text under ~250 words; for longer, run it in the background and stop it with `pkill -x piper` (or `pkill -x espeak-ng`).
- No audio? Prove synthesis with `espeak-ng -f /tmp/opencode/speak-say.txt -w /tmp/opencode/speak-say.wav`, then check the output device with `-d`.

## 4. Also show it

Print the same text in chat as normal prose so it can be read or copied. Once is enough — don't repeat it twice.

## Notes

- Explain, never dictate: no raw command dumps, secrets, tokens, or long file contents.
- If the user says "just say it", skip the chat text and only speak.
