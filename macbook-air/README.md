# macbook-air

Files for my MacBook Air server running Debian 12.

## Required packages

- `mbpfan` - for fan control, otherwise the fans will run at minimum RPM all the time
- `msr-tools` - for `rdmsr` and `wrmsr`, see [prochot](#prochot) below
- `acpid` - for handling ACPI events, see [acpi](#acpi) below

## prochot

Clears the `bd_prochot` bit in the MSR, which is set by Apple's SMC to throttle the CPU when the system is under heavy load or if the system is running solely on AC (i.e., no battery connected).

This script is ideally run at boot via a systemd service. The supplied service assumes that the script is present at `/usr/local/etc/prochot.sh`.

### Notes

The values written to the register, 0x4005c for **off** and 0x4005d for **on (throttled)**, are hard-coded for my system. The script should be modified to write the correct values for your system.

## acpi

Contains a handler for the `lid` event, which is triggered when the lid is opened or closed. The handler is a simple script that turns the display off when closed and on when opened.

Normally this would be handled by the desktop environment, but I'm running a headless server, so I need to handle it myself.

The contents of the `acpi` directory should be copied to `/etc/acpi/`.

### Notes

Regardless of desktop environment, `systemd-logind` will put the system to sleep on lid close by default. Disable this behavior by editing `/etc/systemd/logind.conf` and uncommenting/setting `HandleLidSwitch=ignore`, then restart the `systemd-logind` service.
