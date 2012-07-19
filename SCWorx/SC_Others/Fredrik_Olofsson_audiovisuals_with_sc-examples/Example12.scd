//Example12 - many mappings
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example12 - many mappings", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var maxNum= 30;
	var theta= 0;
	var prev= {Point(0, 0)}.dup(maxNum);	//store previous position
	var pats= {Pstutter(3, Pshuf(#[0, 0, 0, 0.1, 0.25, 0.5, 0.75, 1], inf)).asStream}.dup(maxNum);
	var syns= {
		SynthDef(\av, {|freq= 300, amp= 0, pan= 0, rate= 1, width= 0.2, addcf= 200|
			var z= LPF.ar(Pulse.ar(freq, width), freq+addcf, amp);
			Out.ar(0, Pan2.ar(z, pan));
		}, #[0.05, 0.05, 0.05, 0.05, 0.01, 0.05]).play(s);
	}.dup(maxNum);
	s.sync;
	
	//--interface
	~num= 1;
	~radius= 70;
	~spread= 1;
	~spreadx= 0.4;
	~spready= 0.6;
	~speed= 0.05;
	~fps= 30;
	
	//--main loop
	u.drawFunc= {
		var x, y, a, p, d, tt, ox= 0, oy= 0;
		Pen.translate(width*0.5, height*0.5);
		Pen.strokeColor= Color.blue(1, 0.5);			//set outer ring color
		tt= theta;
		theta= theta+~speed;
		maxNum.do{|i|
			if(i<~num, {
				ox= ox+cos(tt);					//phase offset x
				oy= oy+sin(tt);					//phase offset y
				x= sin(tt+ox)*~spreadx;
				y= cos(tt+oy)*~spready;
				tt= tt-~spread;
				a= i.linexp(0, maxNum-1, 1, 0.01);	//amplitude
				a= a*pats[i].next;					//amp rhythm pattern
				a= a*y.linlin(-1, 1, 1, 0.1);		//amp screen position
				p= Point(x, y);					//position
				d= (p-prev[i]).asPolar.magnitude;	//delta
				Pen.fillColor= Color.blue(1, a);
				Pen.fillOval(Rect.aboutPoint(p*[width, height]*0.5, ~radius*a, ~radius*a));
				Pen.line(Point(0, 0), p*[width, height]*0.5);
				Pen.stroke;
				syns[i].set(
					\freq, y.linexp(-1, 1, i+2*80, 80)+d.linexp(0, 2.83, 0.001, 10000),
					\addcf, a.linexp(0, 1, 100, 8000),
					\width, 0.2+d.min(0.79),
					\amp, a,
					\pan, x
				);
				prev= prev.put(i, p);
			}, {
				syns[i].set(\amp, 0);
			});
		};
	};
	
	//--window management
	u.clearOnRefresh= true;
	u.background= Color.white;
	w.onClose= {syns.do{|x| x.free}};
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/~fps).wait})}).play(AppClock);
};
)

//change these while the program is running
~num= 2;
~num= 3;
~num= 4;
~num= 5;
~num= 6;
~spread= 0;
~spready= -0.1
~speed= 0.2
~spread= 1;
~spready= 2
~speed= 0.05;
~spready= 0.6
~speed= 0.01
~spready= 0.1;
~spreadx= 0.1;
~spread= 0.1
~spread= pi;
~num= 12;
~spread= pi*0.9;
~spreadx= 0.9;
~spready= 0.9;
~spread= 2pi
~num= 3;
~num= 30;

//close the window to stop
