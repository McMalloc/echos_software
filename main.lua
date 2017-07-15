local socket = require "socket"
local socket_unix = require "socket.unix"
log = require "log"

local samples
local cue
local state = 0

c = assert(socket_unix())
c:connect("/tmp/ble")
log.outfile = "log.txt"
log.trace("STARTED")

function love.load(arg)
	samples = {
		a0 = love.audio.newSource("sounds/a0.wav"),
		a1 = love.audio.newSource("sounds/a1.wav"),
		a1_hint = love.audio.newSource("sounds/a1_hint.wav"),
		a2 = love.audio.newSource("sounds/a2.wav"),
		a3 = love.audio.newSource("sounds/a3.wav"),
		b  = love.audio.newSource("sounds/b.wav"),
		b_hint  = love.audio.newSource("sounds/b_hint.wav"),
		c1 = love.audio.newSource("sounds/c1.wav"),
		c2 = love.audio.newSource("sounds/c2.wav"),
		c2_hint = love.audio.newSource("sounds/c2.wav"),
		d0  = love.audio.newSource("sounds/d0.wav"),
		dc = love.audio.newSource("sounds/dc.wav"),
		d1  = love.audio.newSource("sounds/d1.wav"),
		e0 = love.audio.newSource("sounds/e0.wav"),
		e0_hint = love.audio.newSource("sounds/e0.wav"),
		e1 = love.audio.newSource("sounds/e1.wav"),
		z1 = love.audio.newSource("sounds/z1.wav"),
		z2 = love.audio.newSource("sounds/z2.wav")
	}
	
	idle = love.audio.newSource("sounds/idle.wav", "static")
	cue = love.audio.newSource("sounds/cue.wav")
	outro = love.audio.newSource("sounds/outro.wav")
	
	idle:setLooping(true)
	samples.dc:setLooping(true)
	cue:setLooping(true)
end


local beacons = {"B_RECHTS","B_OBEN","B_HOF","B_FOYER","B_CAFE","B_LINKS","B_WC"}
local states = {"S_IDLE","S_READY","S_START","S_KRITIK","S_IMHOF","S_WARUM","S_LOST","S_GUSTAV","S_CHANCE","S_TELEFON","S_TELEFONB","S_GEHEIMNIS","S_BRIEF","S_ENDE"}

-- Beacons: 
local B_RECHTS = 	1 -- rechter Fluegel
local B_OBEN = 	 	2 -- Oben rechts
local B_HOF = 	 	3 -- Hof
local B_FOYER = 	4 -- Eingangstuer Hof--Lobby
local B_CAFE = 		5 -- Cafeteria
local B_LINKS = 	6 -- Linker Fluegel
local B_WC = 		7 -- WC
local B_STORE =		8 -- Concept Store
local thresholds = {
	80, -- RECHTS
	90, -- OBEN
	80, -- HOF
	80, -- FOYER
	80, -- CAFE
	80, -- LINKS
	80, -- WC
	80 -- STORE
}

-- Minimum State bei Z1 und Z2 
--					State 		Szene	Beacon 	Beschreibung
local S_IDLE =		0 --		-		-		Buch liegt auf der Stele
local S_READY =	   	1 --		-		-		Buch ist hochgenommen
local S_START = 	2 -- 	 	A0 (Z2)		-		Buch aufgeschlagen
local S_KRITIK = 	3 --	 	A1 		2		Max kritisiert Kaethe 
local S_IMHOF = 	4 --	 	A2 		3		Treffen im Hof 
local S_WARUM = 	5 --	 	A3 		3		beim Entfernen: State 2 abgeschlossen, Tagebuchmonolog 
local S_LOST = 		6 --	 	B  		4		Tagebuch Max ist verschwunden 
local S_GUSTAV = 	7 --	 	C1 		5		Unterhaltung mit Gustav
local S_CHANCE = 	8 --	 	C2 (Z1)		1		Tagebuch Gelegenheit gefunden, länger sitzenbleiben
local S_TELEFON = 	9 --	 	D  		2		Gespräch belauscht
local S_TELEFONB =	10 --	 	D  		8		Gespräch belauscht, am Telefon
local S_GEHEIMNIS =	11 --		E0		2		beim Entfernen: Tagebuch Geheimnis
local S_BRIEF =		12 --		E1 		6		Max' Brief
local S_ENDE =		13 --		-		-		Abspann läuft, warte auf Reset
local S_Z1 = false    	   -- 		Z1		1		Zusatzdialog 1 beendet
local S_Z2 = false	   -- 		Z2		7		Zusatzdialog 2 beendet
local S_end = false

-- state override
state = S_IMHOF

function updateVolumes(id, val)
	print(id, val)
	    if 	   id == B_RECHTS then 
			if state == S_CHANCE then
				local finished = updateVolume(samples.c2, val, id, true)
				if finished then state = S_TELEFON end
			elseif state > S_CHANCE and not S_Z2 then
				S_Z2 = updateVolume(samples.z2, val, id, false)
			end
	    ------------------------------------------
	    elseif id == B_OBEN  then 
	    	if state == S_KRITIK then
				local finished = updateVolume(samples.a1, val, id, true)
				if finished then state = S_IMHOF end
			end
	    ------------------------------------------
	    elseif id == B_HOF   then 
	    	if state == S_IMHOF then
				local finished = updateVolume(samples.a2, val, id, true)
				if finished then state = S_WARUM end
			elseif state == S_WARUM then
				local finished = updateVolume(samples.a3, val, id, true)
				if finished then state = S_LOST end
			elseif state == S_TELEFON then
				local finished = updateVolume(samples.d0, val, id, true)
				if finished then state = S_TELEFONB end
			elseif state == S_GEHEIMNIS then
				local finished = updateVolume(samples.e0, val, id, true)
				if finished then state = S_BRIEF end
			end
	    ------------------------------------------
	    elseif id == B_STORE   then 
	    	if state == S_TELEFONB then
				local finished = updateVolume(samples.d1, val, id, true)
				if finished then state = S_GEHEIMNIS end
			end
	    ------------------------------------------
	    elseif id == B_FOYER  then 
	    	if state == S_LOST then
	    		local finished = updateVolume(samples.b, val, id, true)
				if finished then state = S_GUSTAV end
	    	end
	    ------------------------------------------
	    elseif id == B_CAFE  then 
			if state == S_GUSTAV then
	    		local finished = updateVolume(samples.c1, val, id, true)
				if finished then state = S_CHANCE end
	    	end
	    ------------------------------------------
	    elseif id == B_LINKS then 
			if state == S_BRIEF then
	    		local finished = updateVolume(samples.e1, val, id, true)
				if finished then state = S_ENDE end
	    	end
	    ------------------------------------------
	    elseif id == B_WC    then 
			if state > S_START and not S_Z1 then
	    		S_Z1 = updateVolume(samples.z1, val, id, false)
	    	end
	    end
end

function volumeMap(value, cutoff)
	-- Processings Implementierung
	-- static public final float map(float value, float istart, float istop, float ostart, float ostop) {
    --  return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
	-- }
	if value < cutoff then return 0 end
	if value > 100 then return 100 end
	return 100 * ((value-cutoff)/(100-cutoff))
end

function updateVolume(sample, val, beaconId, playCue)
	-- TODO. dry/wet
	if sample == nil then return false end
	if val > thresholds[beaconId] or sample:isPlaying() then
		if state == S_TELEFONB then
			samples.dc:stop() 
		else
			cue:stop()
		end
		if sample:isPlaying() then
			sample:setVolume(volumeMap(val, 40)/100)
		else 
			sample:play()
		end
	elseif playCue then
		if state == S_TELEFONB then
			if samples.dc:isPlaying() then
				samples.dc:setVolume(val/100)
			else 
				samples.dc:play()
			end
		else
			if cue:isPlaying() then
				cue:setVolume(volumeMap(val, 40)/100)
			else 
				cue:play()
			end
		end
	end
	return sample:tell() + 0.4 > sample:getDuration()
end

function playHint()
	if 	samples.a1_hint:isPlaying() or
		samples.b_hint:isPlaying() or
		samples.c2_hint:isPlaying() or
		samples.b_hint:isPlaying() then
		return
	end

	log.trace("* played hint")
	if state == S_KRITIK then
		samples.a1_hint:play()
	elseif state == S_LOST then
		samples.b_hint:play()
	elseif state == S_CHANCE then
		samples.c2_hint:play()
	elseif state == S_GEHEIMNIS then
		samples.e0_hint:play()
	end
end

local prev_state = 0
function love.update(dt)
	-- limit at 6 fps
	if dt < 1/6 then
      	love.timer.sleep(1/6- dt)
   	end

   	local msgs = {}
	msgs = read()

	for k, v in pairs(msgs) do
		local id, val = v[1], v[2]
		-- node sendet Signal vom Reed-Schalter "Aufheben"
		-- 1: liegend, 0: aufgehoben
		if id == 90 then
			if val == 1 then
				state = S_IDLE
			elseif val == 0 and state < S_START then
				state = S_READY
			end
		end
		
		-- node sendet Signal vom Reed-Schalter "Aufschlagen"
		-- 1: geschlossen, 0: geöffnet
		if id == 91 and val == 0 then	
			if state == S_READY then
				state = S_START
			end
			playHint()
		end

		if not (id == 91 or id == 90) then
			updateVolumes(id, val)
		end
	end
	
	if state == S_IDLE then
		updateVolume(idle, 100)
	elseif idle:isPlaying() then
		idle:stop()
	end
	
	if state == S_START then
		local finished = updateVolume(samples.a0, 100)
		if finished then state = S_KRITIK end
	end
	
	if state == S_ENDE and not S_end then
		S_end = updateVolume(outro, 100)
	end
	
	if not (prevstate == state) then
		prevstate = state
		print(state)
		print(states[state])
		log.trace("Switched to #" .. state .. " " .. states[state+1])
	end
end

function read()
	local msg, id, val
	msg = c:receive("*l")
	
	if msg == nil then return {} end
	local msgs = {}

	for m in string.gmatch(msg, "([^,]+)") do
		-- id[space]value(,)
		local first = true
		local id, val
		for f in string.gmatch(m, "%S+") do
	   		if first then 
	   			id = tonumber(f)
	   			first = false 
	   		else
	   			val = tonumber(f) 
	   			first = true
	   		end
	   		--print(id, val)
		end
		table.insert(msgs, {id, val})
	end

	return msgs
end
