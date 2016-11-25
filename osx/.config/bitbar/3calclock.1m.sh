#!/usr/bin/env bash

pad_cal() {
  cat - <(echo ' ') | tr '\n' '\0' | xargs -0 printf '%-20s\n'
}

# http://unix.stackexchange.com/a/182545
m=$(date +%m) y=$(date +%Y)
m=${m#"${m%%[!0]*}"}
if ((m == 1)); then
  pm=12       py=$((y-1))
else
  pm=$((m-1)) py=$y
fi
if ((m == 12)); then
  nm=1        ny=$((y+1))
else
  nm=$((m+1)) ny=$y
fi

LANG='ja_JP.UTF-8' date '+%a %-m/%-d %-H:%M'
echo '---'
paste <(cal $pm $py | pad_cal) <(cal | pad_cal) <(cal $nm $ny | pad_cal) |
  awk 'NF {print $0, "|trim=false font=Menlo size=12"}'
