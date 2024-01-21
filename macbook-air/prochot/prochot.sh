#!/bin/bash
SCRIPT_NAME="$(basename "$0")"
PROCHOT_MSR="0x1FC"
force_quit() {
  EXIT_CODE="$1"
  shift
  echo "$@"

  if [ "$EXIT_CODE" -eq 2 ]; then
    echo "Usage: $SCRIPT_NAME <old_value> <new_value>"
    echo "Example: $SCRIPT_NAME 4005d 4005c"
  fi
  exit $EXIT_CODE
}

# Check if we are root
[ $EUID -eq 0 ] || force_quit 1 "Error: must be root"

# Check if needed binaries are present
if ! command -v rdmsr &> /dev/null; then force_quit 1 "Error: rdmsr not in \$PATH, please install msr-tools"; fi
if ! command -v wrmsr &> /dev/null; then force_quit 1 "Error: wrmsr not in \$PATH, please install msr-tools"; fi

# Read args
EXPECTED_OLD="$1"
EXPECTED_NEW="$2"
[ -z "$EXPECTED_NEW" ] && force_quit 2 "Error: please specify a new value"
[[ "$EXPECTED_OLD" == "$EXPECTED_NEW" ]] && force_quit 2 "Nothing to do, trying to set same old value"
(( 16#$EXPECTED_OLD ))
[ $? -eq 0 ] || force_quit 2 "Error: $EXPECTED_OLD is not a valid unprefixed (i.e., no '0x') hex value"
(( 16#$EXPECTED_NEW ))
[ $? -eq 0 ] || force_quit 2 "Error: $EXPECTED_NEW is not a valid unprefixed (i.e., no '0x') hex value"

# Get old value
OLD_VAL="$(rdmsr $PROCHOT_MSR)"
[[ "$OLD_VAL" == "$EXPECTED_NEW" ]] && force_quit 0 "Nothing to do"
[[ "$OLD_VAL" == "$EXPECTED_OLD" ]] || force_quit 1 "Error: expecting old value $EXPECTED_OLD, got $OLD_VAL"

# Set new value
echo "Writing 0x$EXPECTED_NEW to MSR $PROCHOT_MSR"
wrmsr "$PROCHOT_MSR" "0x$EXPECTED_NEW"

# Make sure value is correct
NEW_VAL="$(rdmsr $PROCHOT_MSR)"
[[ "$NEW_VAL" == "$EXPECTED_NEW" ]] || force_quit 1 "Error: failed to write to register"

# Success
force_quit 0 "Done"
