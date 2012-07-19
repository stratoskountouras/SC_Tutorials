//Example20 - starfield
//using a mask for non-square screens.  more abstract midi control
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example20 - starfield", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var index= 0;
	var indey= 0;
	var syn= SynthDef(\av, {|freq= 400, amp= 0.5, pan= 0, q= 0.1, a= 2pi, b= 400, c= 0|
		var x= (1..10)*20;
		var z= SinOsc.ar(c, BPF.ar(BPF.ar(LFSaw.ar(freq*x, 0, a), b), x, q), amp);
		z= Limiter.ar(Mix(z));
		Out.ar(0, Pan2.ar(z, pan));
	}, #[0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]).play(s);
	s.sync;
	
	//--interface
	~layers= 4;
	~balls= {|i| [width.rand, height.rand, ~layers.rand]}.dup(200);
	~dir= [1, 0];
	~radius= 2;
	
	//--main loop
	u.drawFunc= {
		Pen.moveTo(Point(width*0.05, height));	//trapezoid mask
		Pen.lineTo(Point(width*0.25, 0));
		Pen.lineTo(Point(width*0.75, 0));
		Pen.lineTo(Point(width*0.95, height));
		Pen.clip;								//comment out this line to see mask
		~balls.do{|ball, i|
			var r= ~radius*(ball[2]+1/10);
			var x= ball[0]+(index*(ball[2]+0.1))%width;
			var y= ball[1]+(indey*(ball[2]+0.1))%height;
			Pen.strokeColor= Color.grey(1, ball[2]+1/~layers);
			Pen.strokeOval(Rect.aboutPoint(Point(x, y), r, r));
		};
		index= index+~dir[0];
		indey= indey+~dir[1];
		syn.set(
			\freq, ~balls.size,
			\q, ~dir[1].atan2(~dir[0])+pi,			//map direction to filter q
			\a, ~radius.linlin(0, 50, 2pi, 0),		//size to modulator amp
			\b, ~dir[1].hypot(~dir[0])*400+200,		//speed to cutoff freq
			\c, ~layers-4
		);
	};
	
	//--window management
	u.clearOnRefresh= true;
	u.background= Color.black;
	w.onClose= {syn.free};
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/30).wait})}).play(AppClock);
};
)

(	//use midi input to control the program
MIDIIn.connect(device:1);							//edit to match your own setup
MIDIIn.control= {|src, chan, num, val|
	switch(num.postln,
		1, {~radius= val.linlin(0, 127, 0, 50)},		//ctrl number 1 sets the size
		2, {~dir= ~dir.put(0, val.linlin(0, 127, -pi, pi))},
		3, {~dir= ~dir.put(1, val.linlin(0, 127, -pi, pi))},
		4, {~layers= val.linlin(0, 127, 1, 50)}
	);
};
MIDIIn.noteOn= {|src, chan, num, vel|
	~dir= [
		num.linlin(0, 127, -pi, pi),				//note affects horizontal speed
		vel.linlin(0, 127, -pi, pi)					//velocity vertical speed
	];
	if(vel>115, {									//very high velocity rearranges
		~balls= {|i| [i*num%640, i*7%480, i%~layers]}.dup(400);
	});
};
)

//change these while the program is running
~balls= {|i| [i*10%640, i*12%480, i%~layers]}.dup(500);
~balls= {[640.rand, 480.rand, 20.rand]}.dup(50);
~dir= [0.1, 0.1];
~dir= [-0.2, 0];
~dir= [0.3, 0.5];
~dir= [0.5.rand2, 0.5.rand2];
~balls= {|i| [i*5%640, i*7%480, i%~layers]}.dup(500);
~radius= 5;
~radius= 10;
~radius= 40;
~dir= [1.0.rand2, 1.0.rand2];
~layers= 1;
~layers= 40;
~balls= {|i| [i*5%640, i*7%480, i%~layers]}.dup(100);
~dir= [1.0.rand2, 1.0.rand2];
~dir= [1.0.rand2, 1.0.rand2];

//close the window to stop
