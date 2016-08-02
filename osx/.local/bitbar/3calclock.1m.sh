#!/usr/bin/env bash

cal_delta() {
  cal -m $(($(date +%-m) + ${1:-0}))
}

pad_cal() {
  tr '\n' '\0' | xargs -0 printf '%-20s\n'
}

LANG='ja_JP.UTF-8' date '+%a %-m/%-d %-H:%M'
echo '---'
paste <(cal_delta -1 | pad_cal) <(cal | pad_cal) <(cal_delta 1 | pad_cal) |
  awk 'NF {print $0, "|trim=false font=Menlo size=12"}'
