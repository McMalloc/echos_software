var GPIO = require('rpi-gpio');

GPIO.on('change', function(channel, value) {
    switch (value) {
		case 7:
			console.log("7: " + value);
			reedA = value;
			break;
		case 8:
			console.log("8: " + value);
			reedB = value;
			break;
		default: break;
	}
});

GPIO.setup(7, GPIO.DIR_IN, GPIO.EDGE_BOTH);
GPIO.setup(8, GPIO.DIR_IN, GPIO.EDGE_BOTH);
