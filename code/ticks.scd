// Ticks.scd synth and event def.

SynthDef(\tick, {
	arg out = 0, freq = 400, amp = 1, pan = 0,
		ata = 0.02, rel = 0.18, reso = 3.5;
	var src, fil, env;
	
	src = BrownNoise.ar;
	fil = MoogFF.ar(
		src,
		freq,
		reso
	);
	env = EnvGen.kr(Env.perc(ata, rel), doneAction:2);
	
	Out.ar(out, Pan2.ar(fil * env * amp, pan));
}).memStore;

t = Environment.make({
	~outBus = 0;
	~grupo = nil;
	~vel = Pseg(Pseq([0.01, 0.6], inf), Pseq([20, inf], inf)).asStream;
	~amp = Pseg(Pseq([0.5, 1], inf), Pseq([20, inf], inf)).asStream;
	~pan = [0, 0];
	~pan[0] = Pseg(Pseq([1, -0.8], inf), Pseq([5, inf], inf)).asStream;
	~pan[1] = Pseg(Pseq([-1, 0.8], inf), Pseq([5, inf], inf)).asStream;
	~reso = Pseg(Pseq([2, 3.75], inf), Pseq([5, inf], inf)).asStream;
	~rel = Pseg(Pseq([1, 0.18], inf), Pseq([5, inf], inf)).asStream;
	~ata = 0.02;
	~ritmo = Prand([1, 0.7, 0.4], inf).asStream;
	
	~transp = [0, 0];
	~pcs = [0, 0];
	~probPcs = [0, 0];
	~probPcsWFunc = [0, 0];
	~oct = [0, 0];
	~probOct = [0, 0];
	~probOctWFunc = [0, 0];
	
	// Uno
	~transp[0] = 48; // do2
	
	~pcs[0] = [0, 1, 3, 7, 9, 11];
	~probPcs[0] = 6.collect { arg i;
		if ( i == 2 ) { 100 } { Pseg(Pseq([100, 0], inf), Pseq([15, inf], inf)).asStream }
	};
	~probPcsWFunc[0] = { ~probPcs[0].collect { arg i; i.next } };
	
	~oct[0] = [0, 12, 24, 36, 48];
	~probOct[0] = 5.collect{ arg i;
		if ( i == 1) { 100 } { Pseg(Pseq([100, 0], inf), Pseq([15, inf], inf)).asStream }
	};
	~probOctWFunc[0] = { ~probOct[0].collect { arg i; i.next } };
	
	// Dos
	~transp[1] = 48; // do2
	
	~pcs[1] = [2, 4, 5, 6, 8, 10];
	~probPcs[1] = 6.collect { arg i;
		if ( i == 3 ) { 100 } { Pseg(Pseq([100, 0], inf), Pseq([15, inf], inf)).asStream }
	};
	~probPcsWFunc[1] = { ~probPcs[1].collect { arg i; i.next } };
	
	~oct[1] = [0, 12, 24, 36, 48];
	~probOct[1] = 5.collect{ arg i;
		if ( i == 4) { 100 } { Pseg(Pseq([100, 0], inf), Pseq([15, inf], inf)).asStream }
	};
	~probOctWFunc[1] = { ~probOct[1].collect { arg i; i.next } };
	
	/*** Task ***/
	~task = Task.new({
		loop {
			2.do { arg i;
				Synth(\tick, [
					out: ~outBus,
					freq:
						(~pcs[i].wchoose(~probPcsWFunc[i].value.normalizeSum) +
						~transp[i] + ~oct[i].wchoose(~probOctWFunc[i].value.normalizeSum)).midicps,
					amp: ~amp.next,
					reso: ~reso.next,
					ata: ~ata.next,
					rel: ~rel.next,
					pan: ~pan[i].next
				], ~grupo);
				(~ritmo.next * ~vel.next).wait;
			}
		}
	});
});

t.know = true;

