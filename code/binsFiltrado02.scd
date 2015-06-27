// binsFiltrado02.scd synth and event def.

SynthDef(\rango1035, { arg out = 0, amp = 1, oscil = 0.2, t_gesto = 1;
	var in, chain1, chain2, envgesto, geoscil, geamp;

	envgesto = EnvGen.kr(Env.perc(0.02, 1.98), gate: t_gesto);
	geoscil = envgesto * 2 + oscil;
	geamp = envgesto + amp;
	
	in = BrownNoise.ar * geamp;
	chain1 = FFT(LocalBuf(1024), in);
	chain2 = FFT(LocalBuf(1024), in); //PV_Copy(chain1, LocalBuf(1024));
	
	chain1 = chain1.pvcollect(1024, { arg mag, phase, i;
		if(i.even) {
			[mag * SinOsc.kr(geoscil + rand2(0.01), 2pi.rand, 0.5, 0.5), phase]
		} {
			[0, 0]
		}
	}, frombin: 10, tobin: 35, zeroothers: 1);
	
	chain2 = chain2.pvcollect(1024, { arg mag, phase, i;
		if(i.odd) {
			[mag * SinOsc.kr(geoscil + rand2(0.01), 2pi.rand, 0.5, 0.5), phase]
		} {
			[0, 0]
		}
	}, frombin: 10, tobin: 35, zeroothers: 1);

	
	Out.ar(out, [IFFT(chain1), IFFT(chain2)]);
}).load(s);

x = Environment.make({
	~outBus = 0;
	~grupo = nil;
	~synth = nil;
	~oscil = 0.2;
	~amp = 0;
	~gesto = 0;
	
	~task = Task.new({
		~synth = Synth(\rango1035, [
			out: ~outBus,
			amp: 0,
		], ~grupo);
		s.sync;
		loop {
			~synth.set(*[
				out: ~outBus,
				amp: ~amp.next,
				oscil: ~oscil.next,
				t_gesto: if(~gesto > 0) { ~gesto = 0; 1 }
			]);
			0.05.wait;
		}
	});
});

x.know = true;
