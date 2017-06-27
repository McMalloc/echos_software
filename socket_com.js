var net = require('net');
var unixsocket = '/tmp/ble';

var write = function(socket) {
  console.log("init function");
  var interval = setInterval(function() {
    var msg = "";
    for (var key in beacons) {
      if (beacons.hasOwnProperty(key)) {
          msg = msg + key + " " + Math.floor(beacons[key].strength) + "\n";
      }
    }
    socket.write(msg);
  }, 100);
  
  socket.on('end', function() {
    // exec'd when socket other end of connection sends FIN packet
    console.log('[socket on end]');
    clearInterval(interval);
  });

  socket.on('timeout', log('socket', 'timeout'));

  socket.on('drain', function() {
    // emitted when the write buffer becomes empty
    console.log('[socket on drain]');
  });
  socket.on('error', function() {
    log('socket', 'error');
    clearInterval(interval);
    server.close(function() { console.log("shutting down the server!"); });
  });
  socket.on('close', log('socket', 'close'));
  socket.pipe(socket);
};

console.log("Starting Server");
server = net.createServer(write);
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

var log = function(who, what) {
  return function() {
    var args = Array.prototype.slice.call(arguments);
    console.log('[%s on %s]', who, what, args);
  };
};

// exit handling

process.stdin.resume();

function exitHandler(options, err) {
  console.log("\nFreeing sokcet address");
    server.close();
    if (options.cleanup) console.log('clean');
    if (err) console.log(err.stack);
    if (options.exit) process.exit();
}

//do something when app is closing
process.on('exit', exitHandler.bind(null,{cleanup:true}));

//catches ctrl+c event
process.on('SIGINT', exitHandler.bind(null, {exit:true}));

//catches uncaught exceptions
process.on('uncaughtException', exitHandler.bind(null, {exit:true}));