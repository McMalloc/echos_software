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