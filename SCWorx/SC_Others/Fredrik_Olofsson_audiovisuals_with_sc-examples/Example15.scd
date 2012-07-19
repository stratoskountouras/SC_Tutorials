//Example15 - whitney balls
(
s.waitForBoot{

	//--window setup
	var width= 500, height= 500;
	var w= Window("Example15 - whitney balls", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var theta= 0;
	var prev= ();									//keep previous theta
	SynthDef(\av, {|freq= 400, amp= 0, pan= 0|
		var e= EnvGen.kr(Env.perc, 1, amp, doneAction:2);
		var z= SinOsc.ar(freq, 0, e);
		Out.ar(0, Pan2.ar(z, pan));
	}).send(s);
	s.sync;
	
	//--interface
	~speed= 0.005;
	~radius= 3;
	~num= 20;
	~spread= 7;
	~factor= 100;
	~root= 100;
	
	//--main loop
	u.drawFunc= {
		Pen.rotate(2pi*0.75, width*0.5, height*0.5);
		Pen.translate(width*0.5, height*0.5);
		Pen.strokeColor= Color.red;
		Pen.line(Point(0, 0), Point(0, width*0.5));
		Pen.stroke;
		Pen.strokeColor= Color.grey(1, 0.7);
		~num.do{|i|
			var t= ~num-i*theta%2pi;				//theta for this ball
			var x= sin(t)*(i+1*~spread);
			var y= cos(t)*(i+1*~spread);
			if(prev[i].notNil and:{t-prev[i]<0}, {	//detect border
				Synth(\av, [\freq, i*~factor+~root, \amp, 0.1, \pan, 0.3.rand2]);
				Pen.strokeOval(Rect.aboutPoint(Point(x, y), ~radius*0.75, ~radius*0.75));
			});
			prev.put(i, t);
			Pen.strokeOval(Rect.aboutPoint(Point(x, y), ~radius, ~radius));
		};
		theta= theta+~speed%2pi;
	};
	
	//--window management
	u.clearOnRefresh= true;
	u.background= Color.black;
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/30).wait})}).play(AppClock);
};
)

//change these while the program is running
~speed= 0.001;
~num= 100;
~num= 200;
~spread= 1;
~radius= 40;
~radius= 5;
~factor= 80;
~factor= 50;
~speed= 0.005;
~spread= 2;
~num= 30;
~root= 40;
~spread= 6;
~factor= 25;

//close the window to stop
