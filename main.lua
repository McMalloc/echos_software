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
end

local beacons = {"B_LOBBY","B_OBEN","B_HOF","B_TUER","B_CAFE","B_LINKS","B_WC"}
-- Beacons: 
local B_LOBBY = 1 -- Lobby oder rechter Flügel
local B_OBEN = 	2 -- Oben rechts
local B_HOF = 	3 -- Hof
local B_TUER = 	4 -- Eingangstür Hof
local B_CAFE = 	5 -- Cafeteria
local B_LINKS = 6 -- Linker Flügel
local B_WC = 	7 -- WC

-- Minimum State bei Z1 und Z2 
local states = {"S_START","S_KRITIK","S_IMHOF","S_WARUM","S_LOST","S_GUSTAV","S_CHANCE","S_TELEFON","S_GEHEIMNIS","S_BRIEF","S_ENDE"}

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
				local finished = updateVolume(samples.a1, val)
				if finished then state = S_IMHOF end
			elseif state == S_TELEFON then
				local finished = updateVolume(samples.d, val)
				if finished then state = S_GEHEIMNIS end
			elseif state == S_GEHEIMNIS then
				local finished = updateVolume(samples.e0, val)
				if finished then state = S_BRIEF end
			end
	    ------------------------------------------
	    elseif id == B_HOF   then 
	    	if state == S_IMHOF then
				local finished = updateVolume(samples.a2, val)
				if finished then state = S_WARUM end
			elseif state == S_WARUM then
				local finished = updateVolume(samples.a3, val)
				if finished then state = S_LOST end
			end
	    ------------------------------------------
	    elseif id == B_TUER  then 
	    	if state == S_LOST then
	    		local finished = updateVolume(samples.b, val)
				if finished then state = S_GUSTAV end
	    	end
	    ------------------------------------------
	    elseif id == B_CAFE  then 
			if state == S_GUSTAV then
	    		local finished = updateVolume(samples.c1, val)
				if finished then state = S_CHANCE end
	    	end
	    ------------------------------------------
	    elseif id == B_LINKS then 
			if state == S_BRIEF then
	    		local finished = updateVolume(samples.e1, val)
				if finished then state = S_ENDE end
	    	end
	    ------------------------------------------
	    elseif id == B_WC    then 
			if state > 0 then
	    		local finished = updateVolume(samples.z2, val)
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
	if sample == nil then return false end
	if val > 70 or sample:isPlaying() then
		cue:stop();
		if sample:isPlaying() then
			sample:setVolume(val/100)
		else 
			sample:play()
		end
	else
		if cue:isPlaying() then
			cue:setVolume(val/100)
		else 
			cue:play()
		end
	end
	return sample:tell() + 0.4 > sample:getDuration()
end

local id, val = 1,0

local ii = 0
local fakeinput = {0,0,0,0,0,0,0}
function love.update(dt)
	-- limit at 20 fps
	if dt < 1/5 then
      	--love.timer.sleep(1/5 - dt)
   	end

   	--local id, val = read()

   	local id, val = ii+1, fakeinput[ii+1]

   	
   	-- TODO: Alles auf einmal lesen, dann einzeln updaten
	if state == S_START then
		local finished = updateVolume(samples.a0, 100)
		if finished then state = S_KRITIK end
	end

	updateVolumes(id, val);

	ii = (ii + 1) % 7
	--print (id, val)
	-- c:close()
end

function love.draw()
	local width = 1000 / 7

	for i=1,table.getn(states) do

		if state == i-1 then
			love.graphics.setColor(230,0,120)
			love.graphics.rectangle("fill", width*(i-1)+40, 300, width-55, 30)
		end

		love.graphics.setColor(255,255,255)
		love.graphics.print(states[i], width*(i-1)+50, 300)
	end

	for i=1,table.getn(beacons) do
		love.graphics.print(beacons[i] .. ": " .. fakeinput[i], width*(i-1), 430)
		love.graphics.rectangle("fill", width*(i-1), 450, width-5, fakeinput[i])
	end
end

function love.keypressed(key)         
    if key == "escape" then
    	love.event.quit()
    end
end

function love.mousemoved( x, y, dx, dy, istouch )
	local segment = (math.floor((x/1000) * 7)) + 1
	fakeinput[segment] = math.floor(((600-y)/600)*100)
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