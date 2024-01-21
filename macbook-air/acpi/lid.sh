#!/bin/sh
set $*

echo "Lid handler called"

case "$1" in
    button/lid)
        case "$3" in
            close)
                logger 'LID closed'
                /etc/acpi/brightness.sh 0
                ;;
            open)
                logger 'LID opened'
                /etc/acpi/brightness.sh 30
                ;;
            *)
                logger "ACPI action undefined: $3"
                ;;
        esac
    ;;
esac

# vim:set ts=4 sw=4 ft=sh et:
