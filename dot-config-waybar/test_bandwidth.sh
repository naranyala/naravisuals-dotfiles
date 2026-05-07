#!/usr/bin/env bash
INTERFACE="wlp2s0"
STATS=$(grep "$INTERFACE" /proc/net/dev)
RX_CUR=$(echo "$STATS" | awk '{print $2}')
TX_CUR=$(echo "$STATS" | awk '{print $10}')
echo "RX: $RX_CUR, TX: $TX_CUR"
