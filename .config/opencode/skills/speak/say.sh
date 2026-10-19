#!/usr/bin/env bash
# say.sh — speak a text file with the speak skill's voice settings and custom pronunciations.
#
#   say.sh <text-file>             speak it
#   say.sh --phonemes <text-file>  print phonemes instead of speaking (debug a word)
#
# Engines (AI_ENGINE picks one; default is piper when installed, else espeak):
#   piper   neural voice — AI_PIPER (venv bin), AI_PIPER_VOICE (model),
#           AI_LENGTH_SCALE (1.3 = slower)
#   espeak  espeak-ng formant voice, always available — AI_VOICE (en-us+m7),
#           AI_SPEED (115), AI_PITCH (50), AI_AMPL (180), AI_SSML=1, AI_PATH
#
# Pronunciation fixes:
#   pronounce.tsv   word<TAB>espeak<TAB>ipa — say.sh substitutes the column for
#                   the active engine before speaking
#   ~/.local/share/espeak-ng-custom   compiled espeak-ng dictionary, used via
#                   --path (espeak only: piper phonemizes with its own bundled
#                   data and ignores it)
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out=/tmp/opencode/speak-say

mode=speak
if [ "${1:-}" = "--phonemes" ]; then
  mode=phonemes
  shift
fi
file="${1:?usage: say.sh [--phonemes] <text-file>}"

# Engine: piper when installed, otherwise espeak-ng.
piper_bin="${AI_PIPER:-$HOME/.local/share/piper/venv/bin/piper}"
piper_voice="${AI_PIPER_VOICE:-$HOME/.local/share/piper/voices/en_US-ryan-high.onnx}"
engine="${AI_ENGINE:-}"
if [ -z "$engine" ]; then
  if [ -x "$piper_bin" ] && [ -f "$piper_voice" ]; then engine=piper; else engine=espeak; fi
fi

text="$(cat "$file")"
if [ -f "$dir/pronounce.tsv" ]; then
  while IFS=$'\t' read -r word espeak_phon ipa_phon; do
    case "$word" in '' | '#'*) continue ;; esac
    if [ "$engine" = piper ]; then phon="${ipa_phon:-}"; else phon="${espeak_phon:-}"; fi
    [ -n "$phon" ] || continue
    text="${text//"$word"/"$phon"}"
  done < "$dir/pronounce.tsv"
fi

printf '%s\n' "$text" > "$out.txt"

if [ "$engine" = piper ]; then
  if [ "$mode" = phonemes ]; then
    "$piper_bin" -m "$piper_voice" --debug -f "$out.wav" < "$out.txt" 2>&1 |
      grep -o 'phonemes=.*' || true
    exit 0
  fi
  "$piper_bin" -m "$piper_voice" --length-scale "${AI_LENGTH_SCALE:-1.3}" \
    -f "$out.wav" < "$out.txt"
  if command -v pw-play >/dev/null 2>&1; then
    exec pw-play "$out.wav"
  else
    exec paplay "$out.wav"
  fi
fi

espeak_args=()
if [ -n "${AI_PATH:-}" ]; then
  espeak_args+=(--path "$AI_PATH")
elif [ -f "$HOME/.local/share/espeak-ng-custom/espeak-ng-data/en_dict" ]; then
  espeak_args+=(--path "$HOME/.local/share/espeak-ng-custom")
fi
espeak_args+=(-v "${AI_VOICE:-en-us+m7}" -s "${AI_SPEED:-115}"
              -p "${AI_PITCH:-50}" -a "${AI_AMPL:-180}")
if [ "${AI_SSML:-0}" = "1" ]; then
  espeak_args+=(-m)
fi

if [ "$mode" = phonemes ]; then
  exec espeak-ng -q -x "${espeak_args[@]}" -f "$out.txt"
else
  exec espeak-ng "${espeak_args[@]}" -f "$out.txt"
fi
