#!/bin/bash

mounts=/etc/beegfs/beegfs-mounts.conf
service_cmd="/opt/beegfs/sbin/beegfs-helperd cfgFile=/etc/beegfs/beegfs-helperd.conf runDaemonized=true"

start() {
    if [ -f $mounts ]; then
        while read -r entry; do
            client_conf=$(echo $entry | tr -s ' ' | cut -d' ' -f 2)

            # Determine required BeeGFS file system information necessary for BeeGFS helperd instance.
            override_args=
            connAuthFile=$(grep "^connAuthFile" "$client_conf" | tr -d "[:space:]" | cut -f 2 -d "=")
            if [ -n "$connAuthFile" ]; then
                override_args="$override_args connAuthFile=$connAuthFile"
            fi
            connDisableAuthentication=$(grep "^connDisableAuthentication" "$client_conf" | tr -d "[:space:]" | cut -f 2 -d "=")
            if [ -n "$connDisableAuthentication" ]; then
                override_args="$override_args connDisableAuthentication=$connDisableAuthentication"
            fi
            connHelperdPortTCP=$(grep "^connHelperdPortTCP" "$client_conf" | tr -d "[:space:]" | cut -f 2 -d "=")
            if [ -n "$connHelperdPortTCP" ]; then
                override_args="$override_args connHelperdPortTCP=$connHelperdPortTCP"
            fi

            # Start instance of BeeGFS helperd unless already started
            instance_cmd="$(echo $service_cmd $override_args | tr -s ' ')"
            if pgrep -xf "$instance_cmd" > /dev/null; then
              echo "$instance_cmd is already started..."
            else
              echo "executing $instance_cmd"
              $instance_cmd
            fi
        done < $mounts
    fi
}

stop() {
    echo "Stopping BeeGFS helperd service instances..."
}

rc=0
case $1 in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    rc=1
esac

exit $rc
