//Example13 - balls
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example13 - balls", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var maxNum= 30;
	var pats= {Pstutter(3, Pshuf(#[0, 0, 0, 0.1, 0.25, 0.5, 0.75, 1], inf)).asStream}.dup(maxNum);
	var syns= {
		SynthDef(\av, {|freq= 300, amp= 0, pan= 0|
			var z= SinOsc.ar(0, BPF.ar(LFSaw.ar(freq, 0, 2pi), freq));
			Out.ar(0, Pan2.ar(z, pan, amp));
		}, #[0.02, 0.05, 0.05]).play(s);
	}.dup(maxNum);
	s.sync;
	
	//--interface
	~num= 1;
	~radius= 20;
	~fps= 30;
	~spread= 0.3;
	~max= 4000;
	
	//--main loop
	u.drawFunc= {
		Pen.translate(width*0.5, height*0.5);
		Pen.strokeColor= Color.black;
		maxNum.do{|i|
			var a= pats[i].next;
			var x= sin(i/maxNum*2pi)*a;
			var y= cos(i/maxNum*2pi)*a;
			if(i<~num, {
				syns[i].set(
					\freq, y.linexp(-1, 1, ~max, 80),
					\amp, a*(1-(i/maxNum)*0.5),
					\pan, x
				);
				p= Point(x, y)*[width, height]*~spread;
				Pen.fillColor= Color.hsv(x*0.5+0.5, y*0.5+0.5, 0.8, a);
				Pen.fillOval(Rect.aboutPoint(p, ~radius*a, ~radius*a));
				Pen.line(p, p*a);
				Pen.stroke;
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
~num= 7;
~num= 15;
~num= 30;
~spread= 0.1;
~max= 2000;
~max= 8000;
~spread= 0.4;
~num= 4;

//close the window to stop
