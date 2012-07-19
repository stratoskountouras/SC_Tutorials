//Example10a - voices are objects
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example10a - voices are objects", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var syns= {
		SynthDef(\av, {|freq= 300, amp= 0, pan= 0|
			var z= LPF.ar(LFSaw.ar(freq), freq+2000, amp);
			Out.ar(0, Pan2.ar(z, pan));
		}).play(s);
	}.dup(50);		//max 50 voices
	
	//--interface
	~num= 2;
	~spreadx= 100;
	~spready= 150;
	
	//--main loop
	u.drawFunc= {
		Pen.translate(width*0.5, height*0.5);		//offset drawing to the centre
		Pen.fillColor= Color.white;				//always fill with white color
		50.do{|i|
			var x= (i*~spreadx).fold(width* -0.4, width*0.4);
			var y= (i*~spready).fold(height* -0.4, height*0.4);
			if(i<~num, {
				Pen.fillOval(Rect.aboutPoint(Point(x, y), 10, 10));
				syns[i].set(
					\freq, y.linexp(height* -0.4, height* 0.4, 2000, 200),
					\amp, 0.05,
					\pan, x.linlin(width* -0.4, width*0.4, -1, 1)
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
	Routine({while({w.isClosed.not}, {u.refresh; (1/10).wait})}).play(AppClock);
};
)

//change these while the program is running
~num= 3;
~num= 4;
~num= 10;
~num= 20;
~spreadx= 150;
~spreadx= 5;
~spready= 180;
~spready= 179;
~num= 50;
~spreadx= 3;
~spready= 3;
~spready= 30;
~num= 4;
~num= 2;
~num= 1;

Routine({101.do{|i| ~num= i.fold(0, 50)+1; 0.1.wait}}).play(AppClock);

//close the window to stop
