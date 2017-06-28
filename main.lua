local socket = require "socket"
local socket_unix = require "socket.unix"

local samples
local state = 0

c = assert(socket_unix())
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

-- Beacons: 
local B_LOBBY = 1 -- Lobby oder rechter Flügel
local B_OBEN = 	2 -- Oben rechts
local B_HOF = 	3 -- Hof
local B_TUER = 	4 -- Eingangstür Hof
local B_CAFE = 	5 -- Cafeteria
local B_LINKS = 6 -- Linker Flügel
local B_WC = 	7 -- WC

-- Minimum State bei Z1 und Z2 
--					State 		Szene	Beacon 	Beschreibung
local S_START = 	0 -- 	 	A0 (Z2)	-		Buch hochgenommen
local S_KRITIK = 	1 --	 	A1 		2		Max kritisiert Kaethe 
local S_IMHOF = 	2 --	 	A2 		3		Treffen im Hof 
local S_WARUM = 	3 --	 	A3 		3		beim Entfernen: State 2 abgeschlossen, Tagebuchmonolog 
local S_LOST = 		4 --	 	B  		4		Tagebuch Max ist verschwunden 
local S_GUSTAV = 	5 --	 	C1 		5		Unterhaltung mit Gustav
local S_CHANCE = 	6 --	 	C2 (Z1)	1		Tagebuch Gelegenheit gefunden
local S_TELEFON = 	7 --	 	D  		2		Gespräch belauscht
local S_GEHEIMNIS =	8 --		E0		2		beim Entfernen: Tagebuch Geheimnis
local S_BRIEF = 	9 --		E1 		6		Max' Brief

function updateVolumes(id, val)
	if (val > 0) then
	    if 	   id == B_LOBBY then 

	    ------------------------------------------
	    elseif id == B_OBEN then 
	    	if state == S_KRITIK then
				updateVolume(samples.a1, val)
				state = S_IMHOF
			elseif state == S_TELEFON then
				updateVolume(samples.d, val)
				state = S_GEHEIMNIS
			elseif state == S_GEHEIMNIS then
				updateVolume(samples.e0, val)
				state = S_BRIEF
			end
	    ------------------------------------------
	    elseif id == B_HOF then 
	    	if state == S_IMHOF then
				updateVolume(samples.a2, val)
				state = S_WARUM
			elseif state == S_WARUM then
				updateVolume(samples.a3, val)
				state = S_LOST
			end
	    ------------------------------------------
	    elseif id == B_TUER then 
	    	if state == S_LOST then
	    		updateVolume(samples.b, val)
				state = S_GUSTAV
	    	end
	    ------------------------------------------
	    elseif id == B_CAFE then 
			if state == S_GUSTAV then
	    		updateVolume(samples.c1, val)
				state = S_CHANCE
	    	end
	    ------------------------------------------
	    elseif id == B_LINKS then 
			if state == S_CHANCE then
	    		updateVolume(samples.c2, val)
				state = S_TELEFON
	    	end
	    ------------------------------------------
	    elseif id == B_WC then 

	    end
	end
end

-- für die coolen kids mit Coroutinen
function observe(sample)
	local max = sample:getDuration()
	local current = sample:tell()
end

function updateVolume(sample, val)
	if sample:isPlaying() then
		sample:setVolume(val)
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

   	local id, val = read()

	if state == 0 then
		updateVolume(samples.a0, val)
	end

	updateVolumes(id, val);

	print (id, val)
	-- c:close()
end

function read()
	local msg, id, val
	msg = c:receive("*l")

	local idx = 0;
	for i in string.gmatch(msg, "%S+") do
   		if idx == 0 then id = tonumber(i) end
   		if idx == 1 then val = tonumber(i) end
   		idx = idx + 1
	end
	return id, val
end