Update script that fetches the current IP address from api.ipify.org and then updates selected dns entries using the Hetzner DNS API (if necessary).

## Config
Create a bash-like file in `/etc/hetzner-dns/config` which can be sourced (see example_config)

## Usage
Run the script with one of these arguments:
  - `update` to force an update
  - `check` to check and update IPv4 and IPv6
  - `checkV4` to check and update IPv4
  - `checkV6` to check and update IPv6

