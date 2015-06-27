// Main

(
// Grupos
g = Group.new(s); // generadores
h = Group.new(g, \addAfter); // procesadores

// Buses
b = Array.fill(3, { Bus.audio(s, 2) }); // canalización estéreo para rango0256

// Buffer
c = Buffer.read(s, "sounds/a11wlk01-44_1.aiff");

// Entornos/Materiales
// t = ticks, u = paneo rítmico, v = columbia, w = bins filtrado
"/Users/lucas/Desktop/Trabajo Final/ticks.rtf".load;
"/Users/lucas/Desktop/Trabajo Final/rrrsine.rtf".load;
"/Users/lucas/Desktop/Trabajo Final/columbia.rtf".load;
"/Users/lucas/Desktop/Trabajo Final/binsFiltrado.rtf".load;
"/Users/lucas/Desktop/Trabajo Final/binsFiltrado02.rtf".load;
s.volume.volume = -2;
)

(
fork {
	/*** Parte 1 ***/
	
	// ticks, objeto t, material por defecto
	t.task.play;
	20.wait;
	
	// cambio en el ataque y la resononcia
	t.ata = Prand([0.02, 0.02, 0.5], inf).asStream;
	10.wait;
	
	t.rel = Prand([0.18, 0.18, 0.18, 1], inf).asStream;
	10.wait;
	
	// cambio abrupto de la densidad cronométrica (más rápido)
	t.vel = 0.1;
	t.ata = 0.02;
	t.rel = 0.18;
	5.wait;
	
	// transición, se amplía el registro por octavas
	t.probOct[0] = 5.collect{ arg i;
		if ( i == 1) { 100 } { Pseg(Pseq([0, 100], inf), Pseq([20, inf], inf)).asStream }
	};
	t.probOct[1] = 5.collect{ arg i;
		if ( i == 4) { 100 } { Pseg(Pseq([0, 100], inf), Pseq([20, inf], inf)).asStream }
	};
	10.wait;
	
	// cambio en el ataque y la resononcia
	t.amp = 0.6;
	t.ata = Prand([0.02, 0.02, 0.5], inf).asStream;
	10.wait;
	
	t.rel = Prand([0.18, 0.18, 0.18, 1], inf).asStream;
	// transición, se vuelve a acotar el rango de octavas
	t.probOct[0] = 5.collect{ arg i;
		if ( i == 4) { 100 } { Pseg(Pseq([100, 0], inf), Pseq([15, inf], inf)).asStream }
	};
	t.probOct[1] = 5.collect{ arg i;
		if ( i == 1) { 100 } { Pseg(Pseq([100, 0], inf), Pseq([15, inf], inf)).asStream }
	};
	10.wait;
	
	// cambio abrupto en la densidad cronométrica (más lento)
	t.vel = 0.8;
	t.ata = 0.02;
	t.rel = 0.18;
	// transición rítmica, enlace con la segunda parte
	t.ritmo = Ppatlace([
		Pseg(Pseq([1, 0.4], inf), Pseq([10, inf], inf)),
		Pseg(Pseq([0.4, 0.4], inf), Pseq([8, inf])),
		Pseg(Pseq([0.7, 0.5], inf), Pseq([10, inf], inf))
	], inf).asStream;
	15.wait;
	
	t.task.stop;

	/*** Parte 2 ***/
	
	// aparición del material rrrsine (objeto u)
	u.grupo = g;
	u.outBus = 0;
	u.task.play;
	5.wait;
	u.task.stop;
	2.wait;
	u.task.play;
	3.wait;
	
	u.grupo = g;
	u.outBus = b[0];
	
	// configuración del objeto t (no suena inmediatamente)
	t.grupo = g;
	t.outBus = b[2];
	t.vel = 0.1;
	t.ata = 0.02;
	t.rel = 0.18;
	t.task.play;
	
	// configuración del material v, columbia (no suena inmediatamente)
	v.grupo = g;
	v.outBus = b[1];
	v.ritmo = Prand([0.3, 0.5], inf).asStream;
	v.vel = Pseg(Pseq([0.5, 5], inf), Pseq([80, inf], inf)).asStream;
	v.dust = Pseg(Pseq([60, 1], inf), Pseq([80, inf], inf)).asStream;
	v.ata = Pseg(Pseq([0.02, 1.0], inf), Pseq([80, inf], inf)).asStream;
	v.rel = Pseg(Pseq([2.48, 2.0], inf), Pseq([80, inf], inf)).asStream;
	v.amp = 2;
	v.task.play;
	
	// aparece el material binsFiltrado, objeto w
	w.grupo = h;
	w.inBus = b;
	w.amp = 0.6;
	// recorrido pos la matriz de materiales
	w.posy = Pseg(Pseq([0.000001, 2], inf), Pseq([10, inf], inf), \linear).asStream;
	w.posx = Pseg(Pseq([0.000001, 2], inf), Pseq([10, inf], inf), \exponential).asStream;
	w.task.play;
	10.wait;
		
	2.do { arg i;
		w.gesto = 1;
		(3 - i).wait;
	};
	
	w.gesto = 1;
	// recorrido por la matriz de materiales
	w.posy = Pseg(Pseq([2, 0.000001], inf), Pseq([5, inf], inf), \exponential).asStream;
	w.posx = Pseg(Pseq([2, 0.000001], inf), Pseq([5, inf], inf), \linear).asStream;
	5.wait;
	
	// vuelve el material rrrsines, objeto u, se detiene w
	w.task.stop;
	u.outBus = 0;
	10.wait;
		
	// mutación rítmica del material u
	u.ritmo = [
		Pseg( Pseq([0.5, 0.2], inf), Pseq([30, inf], inf) ).asStream,
		Pseg( Pseq([0.45, 0.3], inf), Pseq([30, inf], inf) ).asStream,
		Pseg( Pseq([0.4, 0.5], inf), Pseq([30, inf], inf) ).asStream
	];
	u.vel = Pseg(Pseq([0.8, 0.2], inf), Pseq([90, inf], inf)).asStream;
	5.wait;
	
	// transición de los materiales báscos, desaparece ticks.
	u.instrumento = Pseq([
		Pseq([\rrrsine, \rrrsine, \tick], 12),
		Pseq([\rrrsine, \rrrsine, \tick, \rrrsine], 4),
		Pseq([\rrrsine], inf)
	]).asStream;
	
	// aumento gradual en el tiempo de caida
	u.rel = Pseq([
		Pseq([1.48, 1.48, 0.18], 12),
		Pseq([1.48, 1.48, 0.18, 1.48], 4),
		Pseg(Pseq([1.48, 2.98], inf), Pseq([20, inf], inf))
	]).asStream;
	
	u.amp = Prand([0.1, 0.2, 0.3], inf).asStream;	
	// ampliación gradual del registro y las alturas del material u
	u.freq = Pseq([
		Pseq([54, 60, 99], 5),
		Pseq([54, 68, 99], 7),
		Pseq([54, 68, 99, 81], 4),
		Pseq([54, 68, 69, 81], 7),
		Pseq([66, 52, 79, 64], 3),
		Ppatlace([
			Pseq([Pshuf([54, 69, 83, 68])], inf),
			Pseq([Pshuf([66, 52, 81, 67])], inf)
		], inf)
	]).asStream.midicps;
	
	// material columbia, objeto v
	v.amp = Pseg(Pseq([0.1, 2.0], inf), Pseq([60, inf], inf)).asStream;
	v.outBus = 0;
	5.wait;
	3.do { arg i;
		v.task.stop; // viene tocando...
		(0.1 * i + 6).wait;
		v.task.play;
		(0.5 * i + 4).wait;
	};
	
	/*** Parte 3 ****/
	
	// interrupción en el objeto u, aparición del material x (variación de bindsFiltrado)
	// finaliza el objeto v
	v.task.stop;
	x.grupo = g;
	x.task.play; // genera un ataque
	
	// se restringe el registro del material u a una sola nota (síntesis granular)
	u.amp = Prand([0.1, 0.2, 0.3], inf).asStream;
	u.task.play;
	u.freq = 66.midicps;
	2.wait;
	
	// ampliación gradual en el ancho de banda +- un cuarto de tono desde fa#
	5.do { arg i;
		u.freq = Pseq([66 - (i + 1 * 0.1), 66 + (i + 1 * 0.1)], inf).asStream.midicps;
		2.5.wait;
	};
	2.5.wait;
		
	u.freq = Pseq([65.4, 66.5], inf).asStream.midicps;
	// interrupción de la nota tenida, ataques repetidos (como transición a la tercera parte)
	5.do { arg i;
		u.task.stop;
		2.5.wait;
		u.task.play;
		(i * rrand(0.01, 0.1)).wait;
		x.gesto = 1;
		0.25.wait;
	};
	
	u.task.stop;
	t.task.stop;
	
	// ataques repetidos del gesto en el material x
	2.do {
		2.5.wait;
		x.gesto = 1;
	};
	x.amp = Pseg(Pseq([0.000001, 1.5], inf), Pseq([20, inf], inf)).asStream;
	2.5.wait;
	7.do {
		x.gesto = 1;
		2.5.wait;
	};
	
	x.oscil = Pseg(Pseq([0.2, 0.6], inf), Pseq([5, inf], inf)).asStream;
	7.wait;
	
	x.gesto = 1;
	0.1.wait;
	x.amp = Pseg(Pseq([1.5, 0], inf), Pseq([2, inf], inf)).asStream;
	0.9.wait;
	
	/*** Parte 4 ***/
	
	// aparaición de los ataques repetidos
	10.do { arg i;
		Synth(\tick, [freq: 80.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
		(i * 0.01 + 0.01).wait;
		Synth(\tick, [freq: 42.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
		(i * 0.02 + 0.02).wait;
		Synth(\tick, [freq: 94.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
		2.wait;
	};
	
	Synth(\tick, [freq: 80.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	0.01.wait;
	Synth(\tick, [freq: 42.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	0.02.wait;
	Synth(\tick, [freq: 94.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	
/*
	t.grupo = g;
	u.grupo = g;
	v.grupo = g;
	w.grupo = h;
	w.inBus = b;
*/

	// configuración de los materiales t, u y v
	t.outBus = b[2];
	u.outBus = b[0];
	v.outBus = b[1];
	
	// t
	t.vel = Pseg(Pseq([0.1, 0.01], inf), Pseq([60, inf], inf)).asStream;
	t.probOct[0] = 5.collect{ arg i;
		if ( i == 4) { 100 } { Pseg(Pseq([0, 100], inf), Pseq([60, inf], inf)).asStream }
	};
	t.probOct[1] = 5.collect{ arg i;
		if ( i == 1) { 100 } { Pseg(Pseq([0, 100], inf), Pseq([60, inf], inf)).asStream }
	};
	t.probPcs[0] = 6.collect { arg i;
		if ( i == 2 ) { 100 } { Pseg(Pseq([0, 100], inf), Pseq([60, inf], inf)).asStream }
	};
	t.probPcs[1] = 6.collect { arg i;
		if ( i == 3 ) { 100 } { Pseg(Pseq([0, 100], inf), Pseq([60, inf], inf)).asStream }
	};
	t.task.play;
	
	// u
	u.vel = 0.2;
	u.freq = Pseq([Pseq([65.4, 66.5], 20), Pseq([65, 67], 20), Pseq([77, 55], 20)], inf).asStream.midicps;
	u.task.play;
	
	// v
	v.dust = Pseg(Pseq([60, 5], inf), Pseq([60, inf], inf)).asStream;
	v.task.play;
	
	// w
	w.task.play;
	// sección final, alterna ataques repetidos con el objeto w
	[3, 23].do { arg icant, count;
		w.amplitud = Pseg(Pseq([0.000001, 0.4], inf), Pseq([(0.333 * count + 2.5), inf], inf), \exponential).asStream;
		w.posx = Pseg(Pxrand([0.000001, 0.5, 1.0, 1.75], inf), Pgbrown(2.5, 5, length: inf), \exponential).asStream;
		w.posy = Pseg(Pxrand([0.000001, 0.5, 1.0, 1.75], inf), Pgbrown(2.5, 5, length: inf), \exponential).asStream;
		rrand(3, 5).wait;
		(1..6).do { arg idur;
			w.gesto = 1;
			rrand(idur, (0.5 * count + idur + 1)).wait;
		};
		w.gesto = 1;
		w.amplitud = Pseg(Pseq([0.4, 0.000001], inf), Pseq([2.5, inf], inf), \exponential).asStream;
		(0.5 * count + 1).wait;
		
		icant.do { arg i;
			Synth(\tick, [freq: 80.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
			(i * 0.01 + 0.01).wait;
			Synth(\tick, [freq: 42.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
			(i * 0.02 + 0.02).wait;
			Synth(\tick, [freq: 94.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
			2.wait;
		};
	};
	
	t.task.stop;
	u.task.stop;
	v.task.stop;
	w.task.stop;
};

// reloj
fork {
	var time = TempoClock.new;
	loop {
		time.beats.postln;
		1.wait;
	}
};
)
