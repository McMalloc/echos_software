var GPIO = require('rpi-gpio');

//GPIO.setMode("MODE_BCM");

GPIO.on('change', function(channel, value) {
    switch (channel) {
		case 24:
			//console.log("7: " + value);
			if (value) {
				reedA = 1;
			} else {
				reedA = 0;
			}
			break;
		case 26:
			//console.log("8: " + value);
			if (value) {
				reedB = 1;
			} else {
				reedB = 0;
			}
			break;
		default: break;
	}
});

console.log("Setting up gpio");
GPIO.setup(24, GPIO.DIR_IN, GPIO.EDGE_BOTH);
GPIO.setup(26, GPIO.DIR_IN, GPIO.EDGE_BOTH);
