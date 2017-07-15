var B = require('bleacon');
var com = require('./socket_com');
var gpioscript;
if (process.argv[3] && (process.argv[3] == 'gpio')) {
  gpioscript = require('./gpio');
}
var k = 0.9; // time constant for filter function
    
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
  },
  "8": { // STORE
    strength: 0, timeout: null
  }
};

// beide sind aktiv, d.h. das Buch liegt zugeklappt auf der Stele
reedA = 0; // 1!!
reedB = 1;
 
B.startScanning();

setInterval(function() {
	console.log("\n---------\n");
 	for (var i = 1; i<9; i++) {
        	console.log(i+": " + beacons[i+""].strength);
 	}
}, 100);
    
B.on('discover', function(b) {
  if (!beacons.hasOwnProperty(b.major)) return;
  var oldVal = beacons[b.major].strength;
  // console.log(b.major+": "+beacons[b.major].strength);
  

  // single pole low pass filter, whatever the fuck that means
  // xf = k * xf + (1.0 - k) * x;

  var meassuredVal = (10-b.accuracy)*10;
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
