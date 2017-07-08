# echos_software
"Firmware" scripts for running the mobile Pi-based devices used in our Echos exhibit.

[https://github.com/sandeepmistry/node-bleacon](bleacon) and dependencies needs to be available in `node_modules`, 
and [https://love2d.org/](love) needs to be in the path. Also node, lua comes with love.

## Start scripts
`sudo node main.js`
starts the server and BLE scanner

### arguments 
`love` also starts the client
`gpio` starts with gpio input

`sudo love .`
starts the client who asks the server for signal strength of beacons and adjusts volumes accordingly.
