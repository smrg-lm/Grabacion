// Gráfico recorrido posx posy

(
y = Pseg(Pseq([1, 0.000001], inf), Pseq([1, inf], inf), \exponential).asStream;
x = Pseg(Pseq([1, 0.000001], inf), Pseq([1, inf], inf)).asStream;

~resy = [];
~resx = [];
fork {
	~resy = [];
	~resx = [];
	150.do { arg i;
		~resy = ~resy ++ y.next;
		if(i > 0.33) {
			~resx = ~resx ++ x.next;
		} {
			~resx = ~resx ++ 1;
		};
		0.01.wait;
	};
	"listo".postln;
};
)

(
~resy.plot;
~resx.plot;
)

(
w = Window.new("Recorrido", Rect(0, 0, 500, 500));
u = UserView.new(w, Rect(0, 0, 500, 500));
u.background = Color.white;

u.drawFunc = {
	Pen.strokeColor = Color.black;
	//Pen.strokeRect(Rect(10, 10, 480, 480));
	Pen.moveTo(475@475);
	
	150.do { arg i;
		Pen.lineTo((~resx[i] * 450 + 25)@(~resy[i] * 450 + 25)); // 450 = 150 * 3
	};
	Pen.stroke;
};

w.front;
)
