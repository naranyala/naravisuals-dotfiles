#!/usr/bin/env bash
set -euo pipefail

ncdu / --exclude /media --exclude /run/media
