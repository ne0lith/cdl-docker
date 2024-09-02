#!/bin/sh

EXTERNAL_IPV4=$(curl -s https://api.ipify.org || echo "Unable to fetch IPv4")
EXTERNAL_IPV6=$(curl -s https://api6.ipify.org || echo "Unable to fetch IPv6")

echo "Exposed IPv4: $EXTERNAL_IPV4"
echo "Exposed IPv6: $EXTERNAL_IPV6"

exec "$@"
