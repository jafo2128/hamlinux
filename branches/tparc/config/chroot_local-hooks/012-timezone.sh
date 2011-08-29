#!/bin/sh

echo -n "Setting Timezone to America/Vancouver ... "

TZ="America/Vancouver"
echo $TZ > /etc/timezone
rm -f /etc/localtime
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

echo "Done"
