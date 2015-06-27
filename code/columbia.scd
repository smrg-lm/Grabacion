// columbia.scd synth and event def.

//c = Buffer.read(s, "sounds/a11wlk01-44_1.aiff");

SynthDef(\columbia, {
	arg out = 0, amp = 0.1, wipe = 1.0, width = 1.0, ata = 0.02, rel = 2.48, dust = 20;
	var in, chain1, chain2, env;
	
	env = EnvGen.kr(
		Env.new([0, 1, 0.9, 0], [ata, 0.2, rel], [3, -3, -3]),
		doneAction: 2
	);
			
	in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop:1) * env;
	chain1 = FFT(LocalBuf(1024), in);
	chain1 = PV_BinScramble(chain1, wipe, width, Dust.kr(dust));
	
	chain2 = FFT(LocalBuf(1024), in); // PV_Copy(chain1, LocalBuf(1024));
	chain2 = PV_BinScramble(chain2, wipe, width, Dust.kr(dust));

	chain1 = chain1.pvcollect(1024, { arg mag, phase, i;
		if(i.even) {
			[mag * Line.kr(1, 0, Rand(0.02, ata + rel)), phase]
		} {
			[0, 0]
		}
	}, frombin: 5, tobin: 160, zeroothers: 1);
	
	chain2 = chain2.pvcollect(1024, { arg mag, phase, i;
		if(i.odd) {
			[mag * Line.kr(1, 0, Rand(0.02, ata + rel)), phase]
		} {
			[0, 0]
		}
	}, frombin: 5, tobin: 160, zeroothers: 1);
		
	Out.ar(out, [IFFT(chain1), IFFT(chain2)]);
}).load(s);

v = Environment.make({
	~outBus = 0;
	~grupo = nil;
	
	~amp = 1;
	~wipe = 1.0;
	~width = 1.0;
	~ata = 0.02;
	~rel = 2.48;
	~dust = 20;
	
	~ritmo = 1;
	~vel = 1;
	
	~task = Task.new({
		loop {
			Synth(\columbia, [
				out: ~outBus,
				amp: ~amp.next,
				wipe: ~wipe.next,
				width: ~width.next,
				ata: ~ata.next,
				rel: ~rel.next,
				dust: ~dust.next
			], ~grupo);
			(~ritmo.next * ~vel.next).wait;
		};
	});
});

v.know = true;
