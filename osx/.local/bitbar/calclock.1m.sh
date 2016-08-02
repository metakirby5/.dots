#!/usr/bin/env bash

LANG='ja_JP.UTF-8' date '+%a %-m/%-d %-H:%M'
echo '---'
cal | awk 'NF {print $0, "|trim=false font=Menlo"}'
