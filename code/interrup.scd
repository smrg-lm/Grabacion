// interrupción al cotinuo filtrado simple
// archivo suelto

fork {
	6.do { arg i;
		Synth(\tick, [freq: 80.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
		(i * 0.02 + 0.01).wait;
		Synth(\tick, [freq: 42.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
		(i * 0.03 + 0.02).wait;
		Synth(\tick, [freq: 94.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
		2.wait;
	};
	Synth(\tick, [freq: 80.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	0.01.wait;
	Synth(\tick, [freq: 42.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	0.02.wait;
	Synth(\tick, [freq: 94.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
}

fork {
	Synth(\tick, [freq: 80.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	0.01.wait;
	Synth(\tick, [freq: 42.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	0.02.wait;
	Synth(\tick, [freq: 94.midicps, amp: 1, reso: 3.5, ata: 0.02, rel: 5.98]);
	Synth(\rango1035);
}
