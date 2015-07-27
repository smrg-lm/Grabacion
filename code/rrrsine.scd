// rrrsine.scd synth and kagel def.

SynthDef(\rrrsine, { arg out = 0, freq = 440, amp = 0.1, pan = 0, ata = 0.02, rel = 1.48;
	var src, noise, env;
	
	env = EnvGen.kr(Env.perc(ata, rel), doneAction:2);
	noise = LFNoise2.kr(20000 * amp, 0.3, 0.7);
	src = SinOsc.ar(freq, 0, amp) * noise * env;
	
	Out.ar(out, Pan2.ar(src, pan));
}).send(s);

u = Environment.make({
	~outBus = 0;
	~grupo = nil;
	~instrumento = Pseq([\tick, \rrrsine, \tick], inf).asStream;
	~freq = Pseq([66, 60, 99].midicps, inf).asStream;
	~amp = Pseq([1, Prand([0.1, 0.5]), 1], inf).asStream;
	~pan = Pseq([
		Pseq([1, -1, 0]),
		Pseq([-1, 0, 1]),
		Pseq([0, -1, 1]),
		Pseq([-1, 1, 0])
	], inf).asStream;
	
	~ata = 0.02;
	~rel = Pseq([0.18, 1.48, 0.18], inf);
	~reso = 3.75;
	
	~ritmo = [0.4, 0.5, 0.45];
	~vel = 0.8;
	
	~task = Task.new({		
		inf.do { arg i;
			Synth(~instrumento.next, [
				out: ~outBus,
				freq: ~freq.next,
				amp: ~amp.next,
				pan: ~pan.next,
				ata: ~ata.next,
				rel: ~rel.next,
				reso: ~reso.next
			], ~grupo);
			(~ritmo[i % ~ritmo.size].next * ~vel.next).wait;
		}
	});
});

u.know = true;
