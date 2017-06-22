local socket = require "socket"
local socket_unix = require "socket.unix"

c = assert(socket_unix())
--c:connect("/tmp/ble")

assert(socket:bind("/tmp/ble"))
assert(socket:listen())
conn = assert(socket:accept())

while 1 do
	local msg = "no data"
	msg = conn:receive("*l")
	if not(msg == nil) then
		-- talk:setVolume(tonumber(msg)/100)
	end
	print (msg)
	-- c:close()
end

--[[

function love.load()
	music = love.audio.newSource("music.ogg")
	talk = love.audio.newSource("talk.mp3")
	
	-- music:play()
	talk:play()

	talk:setVolume(0.5)
end

function love.update()
	local msg = "no data"
	msg = c:receive("*l")
	if not(msg == nil) then
		talk:setVolume(tonumber(msg)/100)
	end
	print (msg)
	-- c:close()
end


--]]