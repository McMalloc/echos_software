    // var ipc=require('node-ipc');
    var B = require('bleacon');
    var net = require('net'),
    unixsocket = '/tmp/ble';
    
    var beacons = {
			"1": 0,
			"2": 0
		};
    
    B.startScanning();
    
    B.on('discover', function(beacon) {
		beacons[beacon.major] = parseInt((1/(beacon.accuracy+1))*100);
		console.log(beacons[beacon.major]);
	});

var log = function(who, what) {
  return function() {
    var args = Array.prototype.slice.call(arguments);
    console.log('[%s on %s]', who, what, args);
  };
};

var echo = function(socket) {
	setInterval(function() {
		socket.write(beacons["1"] + "\n");
	}, 100)
	
  socket.on('end', function() {
    // exec'd when socket other end of connection sends FIN packet
    console.log('[socket on end]');
  });

  socket.on('timeout', log('socket', 'timeout'));

  socket.on('drain', function() {
    // emitted when the write buffer becomes empty
    console.log('[socket on drain]');
  });
  socket.on('error', function() {
	  log('socket', 'error');
	  server.close(function() { console.log("shutting down the server!"); });
	});
  socket.on('close', log('socket', 'close'));
  socket.pipe(socket);
};

var server = net.createServer(echo);
server.listen(unixsocket); // port or unix socket, cannot listen on both with one server

server.on('listening', function() {
  var ad = server.address();
  if (typeof ad === 'string') {
    console.log('[server on listening] %s', ad);
  } else {
    console.log('[server on listening] %s:%s using %s', ad.address, ad.port, ad.family);
  }
});

server.on('connection', function(socket) {
  server.getConnections(function(err, count) {
    console.log('%d open connections!', count);
  });
});

server.on('close', function() { console.log('[server on close]'); });
server.on('err', function(err) { 
  console.log(err);
  server.close(function() { console.log("shutting down the server!"); });
});
