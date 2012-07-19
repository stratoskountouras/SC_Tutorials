//Example00 - structure
(
s.waitForBoot{

	//--window setup
	var width= 500, height= 500;
	var w= Window("Example00 - structure", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var theta= 0;	//will be used as a counter. no external access at runtime
	var syn= SynthDef(\av, {|freq= 400, amp= 0, pan= 0|
		var z= SinOsc.ar(0, BPF.ar(Pulse.ar(freq, amp)*2pi), amp);
		Out.ar(0, Pan2.ar(z, pan));
	}, #[0.05, 0.05, 0.05]).play(s);
	s.sync;
	
	//--interface
	~speed= 0.05;		//it is possible to change these at runtime
	~radius= 20;
	~spreadx= 20;
	~spready= 20;
	
	//--main loop
	u.drawFunc= {
		var x= sin(theta)*~spreadx;		//calculate coordinates
		var y= cos(x)*~spready;
		var a= x.hypot(y)/1.42/~spreadx;
		syn.set(						//update the synth with mapped parameters
			\freq, y.linexp(height.neg*0.5, height*0.5, 100, 1000),
			\amp, a.min(0.995),
			\pan, x.linlin(width.neg*0.5, width*0.5, -1, 1)
		);
		Pen.translate(width*0.5, height*0.5);	//offset all drawing to the middle
		Pen.fillColor= Color.red;	//set the fill color
		Pen.fillOval(Rect.aboutPoint(Point(x, y), ~radius*a, ~radius*a));
		theta= theta+~speed%2pi;		//our counter counts in radians
	};
	
	//--window management
	u.clearOnRefresh= true;		//erase view for each refresh
	u.background= Color.white;	//set background color
	w.onClose= {syn.free};		//stop the sound when window closed
	w.front;					//make the window appear
	Routine({while({w.isClosed.not}, {u.refresh; (1/30).wait})}).play(AppClock);
};
)

//change these while the program is running
~spreadx= 150;
~spready= 100;
~speed= pi*0.9;
~speed= 2pi/3;
~speed= pi*0.45;
~radius= 80;
~spreadx= 60;
~speed= pi*0.99;
~speed= pi*0.99/4;
~radius= 40;
~spreadx= 10;
~spready= 40;
~speed= 0.05
~speed= pi*0.8;

//close the window to stop
