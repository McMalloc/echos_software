local socket = require "socket"
local socket_unix = require "socket.unix"

local samples
local state = 0

c = assert(socket.unix())
c:connect("/tmp/ble")

function love.load()
	samples = {
		a0 = love.audio.newSource("placeholder/a0.wav"),
		a1 = love.audio.newSource("placeholder/a1.wav"),
		a2 = love.audio.newSource("placeholder/a2.wav"),
		a3 = love.audio.newSource("placeholder/a3.wav"),
		b  = love.audio.newSource("placeholder/b.wav"),
		c1 = love.audio.newSource("placeholder/c1.wav"),
		c2 = love.audio.newSource("placeholder/c2.wav"),
		d  = love.audio.newSource("placeholder/d.wav"),
		e1 = love.audio.newSource("placeholder/e1.wav"),
		e2 = love.audio.newSource("placeholder/e2.wav"),
		z1 = love.audio.newSource("placeholder/z1.wav"),
		z2 = love.audio.newSource("placeholder/z2.wav"),
	}

	samples.a0:setLooping(true)
	samples.a1:setLooping(true)
	samples.a2:setLooping(true)
	samples.a3:setLooping(true)
	samples.b:setLooping(true)
	samples.c1:setLooping(true)
	samples.c2:setLooping(true)
	samples.d:setLooping(true)
	samples.e1:setLooping(true)
	samples.e2:setLooping(true)
	samples.z1:setLooping(true)
	samples.z2:setLooping(true)
end

function updateVolumes(id, val)
	if (val > 0) then
		if     id == 0 then 
			if state == 1 then
				updateVolume(samples.a1, val)
			end
	    elseif id == 1 then print("bee")
	    elseif id == 2 then print("bee")
	    elseif id == 3 then print("bee")
	    elseif id == 4 then print("bee")
	    elseif id == 5 then print("bee")
	    elseif id == 6 then print("bee")
	    elseif id == 7 then print("bee")
	    end
	end
end

-- für die coolen kids mit Coroutinen
function observe(sample)
	local max = sample:getDuration()
	local current = sample:tell()
	if 
end

function updateVolume(sample, val)
	if sample:isPlaying() then
		sample.setVolume(val)
	else 
		sample:play()
		observe(sample)
	end
end

function love.update(dt)
	-- limit at 10 fps
	if dt < 1/10 then
      love.timer.sleep(1/10 - dt)
   	end

	local msg, id, val
	msg = c:receive("*l")

	local idx = 0;
	for i in string.gmatch(msg, "%S+") do
   		if idx == 0 then id = tonumber(i) end
   		if idx == 1 then val = tonumber(i) end
   		idx = idx + 1
	end
	updateVolumes(id, val);

	print (id, val)
	-- c:close()
end