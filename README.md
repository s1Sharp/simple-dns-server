To start DNS server, add your dns entries to `dns_addresses.conf` file and execute `run.sh` script.

It will process docker build and run docker container with name my-dns-server.

This container will have all dns entries.

This entries can be easy resolved by command `nslookup testhostname.local <ip of my-dns-server container>
