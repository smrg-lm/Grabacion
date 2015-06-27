// binsFiltrado.scd synth and event def.

SynthDef(\rango0256, {
	arg out = 0, inBus = #[0, 0, 0], amp = 0.2, oscil = 0.2, t_gesto = 0, posx = 1, posy = 1, amplitud = 1;
	var in, chain1, chain2, envgesto, geoscil, geamp;
	
	envgesto = EnvGen.kr(Env.perc(0.2, 1.98), gate: t_gesto);
	geoscil = envgesto * 2 + oscil;
	geamp = envgesto * 0.5 + amp;
		
	in = SelectX.ar(posy, [
		SelectX.ar(posx, [
			Mix.new(In.ar(inBus[0])) * geamp, // paneo rítmico
			Mix.new(In.ar(inBus[1])) * geamp // columbia
		]),
		SelectX.ar(posx, [
			Mix.new(In.ar(inBus[2])) * geamp, // ticks
			BrownNoise.ar * geamp
		])
	]);
	
	chain1 = FFT(LocalBuf(1024), in);
	chain2 = FFT(LocalBuf(1024), in); //PV_Copy(chain1, LocalBuf(1024));
	
	chain1 = chain1.pvcollect(1024, { arg mag, phase, i;
		if(i.even) {
			[mag * SinOsc.kr(geoscil + rand2(0.1), 2pi.rand, 0.5, 0.5), phase]
		} {
			[0, 0]
		}
	}, frombin: 0, tobin: 256, zeroothers: 1);
	
	chain2 = chain2.pvcollect(1024, { arg mag, phase, i;
		if(i.odd) {
			[mag * SinOsc.kr(geoscil + rand2(0.1), 2pi.rand, 0.5, 0.5), phase]
		} {
			[0, 0]
		}
	}, frombin: 0, tobin: 256, zeroothers: 1);

	
	Out.ar(out, [IFFT(chain1), IFFT(chain2)] * amplitud);
}).load(s);

w = Environment.make({
	~outBus = 0;
	~grupo = nil;
	~inBus = [0, 0, 0];
	~synth = nil;
	
	~amp = 0.6;
	~oscil = 0.2;
	~posx = 0;
	~posy = 0;
	~gesto = 0;
	~amplitud = 0.8;
	
	~task = Task.new({
		~synth = Synth(\rango0256, [
			out: ~outBus,
			inBus: ~inBus,
			amp: 0,
			posx: 0,
			posy: 0,
			amplitud: 0
		], ~grupo);
		s.sync;
		loop {
			~synth.set(*[
				out: ~outBus,
				amp: ~amp.next,
				oscil: ~oscil.next,
				t_gesto: if(~gesto > 0) { ~gesto = 0; 1 },
				posx: ~posx.next,
				posy: ~posy.next,
				amplitud: ~amplitud
			]);
			0.05.wait;
		};
	});
});

w.know = true;
