--local socket = require "socket"
--local socket_unix = require "socket.unix"

local samples
local cue
local state = 0

--c = assert(socket_unix())
--c:connect("/tmp/ble")

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
		z2 = love.audio.newSource("placeholder/z2.wav")
	}

	cue = love.audio.newSource("placeholder/z2.wav")
	cue:setLooping(true)
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
local S_ENDE =		10

function updateVolumes(id, val)
	--if (val > 0) then
	    if 	   id == B_LOBBY then 
			if state == S_CHANCE then
				local finished = updateVolume(samples.c2, val)
				if finished then state = S_TELEFON end
			elseif state > S_CHANCE then
				updateVolume(samples.z1, val)
			end
	    ------------------------------------------
	    elseif id == B_OBEN  then 
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
	    elseif id == B_HOF   then 
	    	if state == S_IMHOF then
				updateVolume(samples.a2, val)
				state = S_WARUM
			elseif state == S_WARUM then
				updateVolume(samples.a3, val)
				state = S_LOST
			end
	    ------------------------------------------
	    elseif id == B_TUER  then 
	    	if state == S_LOST then
	    		updateVolume(samples.b, val)
				state = S_GUSTAV
	    	end
	    ------------------------------------------
	    elseif id == B_CAFE  then 
			if state == S_GUSTAV then
	    		updateVolume(samples.c1, val)
				state = S_CHANCE
	    	end
	    ------------------------------------------
	    elseif id == B_LINKS then 
			if state == S_BRIEF then
	    		updateVolume(samples.e1, val)
				state = S_ENDE
	    	end
	    ------------------------------------------
	    elseif id == B_WC    then 
			if state > 0 then
	    		updateVolume(samples.z2, val)
	    	end
	    end
	--end
end

-- für die coolen kids mit Coroutinen
function observe(sample)
	local max = sample:getDuration()
	local current = sample:tell()
end

function updateVolume(sample, val)
	-- gleiches cue für jede source?
	-- TODO: variable, die weiß, ob das sample schon begonnen hat
	if val > 70 then
		cue:stop();
		if sample:isPlaying() then
			sample:setVolume(val)
		else 
			sample:play()
		end
	else
		if cue:isPlaying() then
			cue:setVolume(val)
		else 
			cue:play()
		end
	end
	return sample:tell() == sample:getDuration()
end

local id, val = 1,0

function love.update(dt)
	-- limit at 20 fps
	if dt < 1/3 then
      --love.timer.sleep(1/3 - dt)
   	end

   	--local id, val = read()

   	
   	-- TODO: Alles auf einmal lesen, dann einzeln updaten
	if state == S_START then
		local finished = updateVolume(samples.a0, val)
		if finished then state = S_KRITIK end
	end

	updateVolumes(id, val);

	--print (id, val)
	-- c:close()
end

function love.draw() 
	love.graphics.print(state, 10, 10)
	love.graphics.print(id .. ": " .. val, 10, 30)

	love.graphics.print(samples.a0:getVolume(), 30, 50)
	love.graphics.print(samples.a1:getVolume(), 30, 65)
	love.graphics.print(samples.a2:getVolume(), 30, 80)
	love.graphics.print(samples.a3:getVolume(), 30, 95)
	love.graphics.print( samples.b:getVolume(), 30, 110)
	love.graphics.print(samples.c1:getVolume(), 30, 125)
	love.graphics.print(samples.c2:getVolume(), 30, 140)
	love.graphics.print( samples.d:getVolume(),  30, 155)
	love.graphics.print(samples.e1:getVolume(), 30, 170)
	love.graphics.print(samples.e2:getVolume(), 30, 185)
	love.graphics.print(samples.z1:getVolume(), 30, 200)
	love.graphics.print(samples.z2:getVolume(), 30, 215)
	love.graphics.print(beacons[1], 300, 50)
	love.graphics.print(beacons[2], 300, 65)
	love.graphics.print(beacons[3], 300, 80)
	love.graphics.print(beacons[4], 300, 95)
end

function love.keypressed(key)
    if key == "up" then
    	val = val + 10
    end    
    if key == "down" then
    	val = val - 10
    end    
    if key == "1" then
    	id = 1
    end    
    if key == "2" then
    	id = 2
    end    
    if key == "3" then
    	id = 3
    end     
    if key == "4" then
    	id = 4
    end           
    if key == "escape" then
    	love.event.quit()
    end
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