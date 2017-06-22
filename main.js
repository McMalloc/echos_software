// var ipc=require('node-ipc');
var B = require('bleacon');
var com = require('./socket_com');
var k = 0.9; // time constant for filter function
    
var beacons = {
  "1": {
    strength: 0,
    audible: false
  },
	"2": {
    strength: 0,
    audible: false
  }
};
    
B.startScanning();
    
B.on('discover', function(beacon) {
  beacons[beacon.major].audible = true;
  var oldVal = beacons[beacon.major];
  // single pole low pass filter, whatever the fuck that means
  // xf = k * xf + (1.0 - k) * x;
  var meassuredVal = (1/(beacon.accuracy+1))*100;
	beacons[beacon.major].strength = k * oldVal + (1 - k) * meassuredVal;
	// console.log(beacons[beacon.major]);
});

