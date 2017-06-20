# echos_software
"Firmware" scripts for running the mobile Pi-based devices used in our Echos exhibit.

[https://github.com/sandeepmistry/node-bleacon](bleacon) and dependencies needs to be available in `node_modules`, 
and [https://love2d.org/](love) needs to be in the path. Also node, lua comes with love.

## Free sockets in use
`sudo rm /tmp/ble`

## Start scripts
`sudo node main.js`
starts the server and BLE scanner

`sudo love .`
starts the client who asks the server for signal strength of beacons and adjusts volumes accordingly.
