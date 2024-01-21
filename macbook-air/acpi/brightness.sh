#!/bin/bash

# Script for controlling display brightness on MacBookAir6,2
# by @jareddantis, 2024
#
# Usage: brightness.sh <brightness%>
# Example: brightness.sh 100

# Change to your display manager's binary name
DMGR="ly"

# Change to your backlight device name (usually acpi_video0 or intel_backlight)
BL_DEV="acpi_video0"

# Change to your keyboard backlight device name (usually smc::kbd_backlight)
KBD_DEV="smc::kbd_backlight"

BL_CTRL="/sys/class/backlight/${BL_DEV}/brightness"
KBD_CTRL="/sys/class/leds/${KBD_DEV}/brightness"
# Check if running as root
if [ "${EUID}" -ne "0" ]; then
  echo "Please run this script as root."
  exit 1
fi

# Check if arg is an int
RE='^[0-9]+$'
if ! [[ "$1" =~ $RE ]]; then
  echo "'$1' is not a valid integer."
  exit 1
fi

# Check if arg is in range
MAX_BL=$(cat "/sys/class/backlight/${BL_DEV}/max_brightness")
if [[ -z "$1" ]] || [[ "$1" -gt "${MAX_BL}" ]] || [[ "$1" -lt 0 ]]; then
  echo "Please enter a brightness value from 0 to ${MAX_BL}."
  exit 1
fi

# Set brightness
CUR_BL=$(cat "${BL_CTRL}")
echo "$1" > "${BL_CTRL}"

# Look for display manager TTY
DMGR_PID=$(pgrep "${DMGR}")
DMGR_TTY="/dev/$(ps -o tty= $DMGR_PID)"
if [[ -e "${DMGR_TTY}" ]]; then
  # If brightness is zero, blank display after a short delay
  if [[ "$1" -eq 0 ]]; then
    echo "Blanking display and powering off keyboard"
    echo 0 > "${KBD_CTRL}"
    sleep 2
    bash -c 'TERM=linux setterm --blank=force --powersave powerdown < /dev/tty2'
  elif [[ "$1" -gt 0 ]] && [[ "${CUR_BL}" -eq 0 ]]; then
    echo "Waking display and powering on keyboard"
    echo 127 > "${KBD_CTRL}"
    bash -c 'TERM=linux setterm --blank=poke < /dev/tty2'
  fi
else
  echo "Warning: Could not determine TTY. Skipping display wake/powerdown."
fi
