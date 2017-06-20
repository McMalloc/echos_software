local socket = require "socket"
local socket_unix = require "socket.unix"

c = assert(socket.unix())
c:connect("/tmp/foo")

-- funktioniert!
