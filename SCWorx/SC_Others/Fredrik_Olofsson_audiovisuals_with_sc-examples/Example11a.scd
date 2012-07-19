//Example11a - harmonicity is order
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example11a - harmonicity is order", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var disorder= {1.0.rand2}.dup(30);	//array of random values
	var syns= {
		SynthDef(\av, {|freq= 300, amp= 0, pan= 0|
			var z= LPF.ar(LFSaw.ar(freq), freq+2000, amp);
			Out.ar(0, Pan2.ar(z, pan));
		}).play(s);
	}.dup(30);		//max 30 voices
	
	//--interface
	~num= 6;
	~columns= 10;
	~dist= 0;
	
	//--main loop
	u.drawFunc= {
		Pen.translate(60, 60);
		Pen.fillColor= Color.white;					//always fill with white color
		30.do{|i|
			var x= i%~columns+(disorder[i]*~dist);
			var y= i.div(~columns)+1*100;
			x= x+(i.div(~columns)*0.25);			//shift each row a little
			if(i<~num, {
				Pen.fillOval(Rect.aboutPoint(Point(x*60, y), 20, 20));
				syns[i].set(
					\freq, x+1*y,
					\amp, 0.5/~num,
					\pan, i%~columns/~columns*2-1
				);
			}, {
				syns[i].set(\amp, 0);
			});
		};
	};
	
	//--window management
	u.clearOnRefresh= true;
	u.background= Color.black;
	w.onClose= {syns.do{|x| x.free}};
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/20).wait})}).play(AppClock);
};
)

//change these while the program is running
~dist= 0.5;
~dist= 0;
~dist= 1;
~num= 13;
~dist= 0;
~num= 25;
~dist= 0.1;
~dist= 0.2;
~dist= 0.3;
~columns= 8;
~num= 4;
~dist= 0;
~dist= 1;

(
Routine{
	~columns= 9;
	400.do{|i|
		~num= i.div(10).min(30)+1;
		~dist= 1-cos(i%200/200*2pi).abs;
		(1/20).wait;
	};
	"done".postln;
}.play(AppClock)
)

//close the window to stop
