# unbound

This folder contains configurations for running Unbound as a recursive resolver, for use with DNS-based adblockers like AdGuard Home and Pi-hole.

## Main unbound container

The `cachedb` and `nocachedb` folders contain Docker Compose and unbound.conf files for running Unbound with and without support for [CacheDB](https://nlnetlabs.nl/documentation/unbound/unbound.conf/#backend).

Notable changes to default configuration include [Extended DNS Errors (RFC8914)](https://www.rfc-editor.org/rfc/rfc8914.html) reporting enabled by default to demystify `SERVFAIL` responses, and logging to `/var/log/unbound.log` enabled by default. This log file should be rotated at least daily, as Unbound can be quite chatty. Otherwise, feel free to disable logging.

### `cachedb`

[Matthew Vance](https://github.com/MatthewVance/unbound-docker) maintains an Unbound Docker image, which works well enough for the most part, but it is not built with support for CacheDB.

I [forked](https://github.com/jareddantis/unbound-docker-cachedb) their repository and modified the existing (latest) Dockerfile to compile Unbound with `--with-libhiredis` and `--enable-cachedb`, along with the necessary dependencies. These images are available from [GitHub Container Registry](https://github.com/jareddantis/unbound-docker-cachedb/pkgs/container/unbound-docker-cachedb).

Accordingly, the `cachedb` folder also includes configuration for Redis Stack. It is configured to have a maximum cache size of 2 MB. Feel free to change it, but avoid excessively large cache sizes, since Unbound will not evict old data and will therefore happily serve stale DNS records.

### `nocachedb`

This configuration uses Matthew Vance's image without modification.

## Ad-blockers

This folder also contains sample Docker Compose configurations for running AdGuard Home and Pi-hole, although I use the former almost exclusively these days. Pi-hole's access control is quite lacking and it does not support encrypted DNS, which makes it less than practical for deployment off-premises.

Please proceed with caution when using my provided configuration for Pi-hole, as I do not maintain it anymore.

Both Compose files assume that Unbound is running on a network `unbound` with subnet `192.168.2.0/24`, and that the Unbound container is at the IP address `192.168.2.2`. 
