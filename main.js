var B = require('bleacon');
var com = require('./socket_com');
// var gpioscript = require('./gpio');
var k = 0.85; // time constant for filter function
    
beacons = {
  "1": { // Lobby oder rechter Flügel
    strength: 0, timeout: null
  },
  "2": { // Oben rechts
    strength: 0, timeout: null
  },
  "3": { // Hof
    strength: 0, timeout: null
  },
  "4": { // Eingangstuer
    strength: 0, timeout: null
  },
  "5": { // Cafeteria
    strength: 0, timeout: null
  },
  "6": { // Linker Flügel
    strength: 0, timeout: null
  },
  "7": { // WC
    strength: 0, timeout: null
  }
};

reedA = 0;
reedB = 1;
 
B.startScanning();
    
B.on('discover', function(b) {
  if (!beacons.hasOwnProperty(b.major)) return;
  var oldVal = beacons[b.major].strength;

  // single pole low pass filter, whatever the fuck that means
  // xf = k * xf + (1.0 - k) * x;

  var meassuredVal = (1/(b.accuracy+1))*100;
	beacons[b.major].strength = k * oldVal + (1 - k) * meassuredVal;

  if (beacons[b.major].timeout != null) clearTimeout(beacons[b.major].timeout);

  beacons[b.major].timeout = setTimeout(function() {
    beacons[b.major].strength = 0
  }, 2000);
});

// https://stackoverflow.com/a/23202637
var map = function (n, in_min, in_max, out_min, out_max) {
  return (n - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}