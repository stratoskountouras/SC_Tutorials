//Example04b - higher is lower
//only one line differs from Example04b.  the one in the main loop where we invert the mapping.
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example04b - higher is lower", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var pat= Pn(Pshuf(#[0, 0, 0, 0, 0.1, 0.25, 0.5, 0.75, 1, 1], 8), inf).asStream;
	var syn= SynthDef(\av, {|scaleFreq= 0|
		var z= LPF.ar(LFSaw.ar(#[300, 301, 80, 81]*(scaleFreq+0.5)).mean, 2000);
		Out.ar(0, Pan2.ar(z));
	}, #[0.05]).play(s);		//short lag time to avoid clipping
	
	//--interface
	~radius= 50;
	~fps= 10;
	~spready= 240;
	
	//--main loop
	u.drawFunc= {
		var fre= pat.next;							//get the next value from the stream
		syn.set(\scaleFreq, fre);					//send to the synth
		Pen.translate(width*0.5, height*0.5);		//offset drawing to the centre
		Pen.fillColor= Color.white;				//always fill with white color
		fre= 1-fre;								//here we invert the mapping
		Pen.fillOval(Rect.aboutPoint(Point(0, 1-fre-0.5*~spready), ~radius, ~radius));
	};
	
	//--window management
	u.clearOnRefresh= true;
	u.background= Color.black;
	w.onClose= {syn.free};
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/~fps).wait})}).play(AppClock);
};
)

//change these while the program is running
~radius= 150;
~radius= 25;
~fps= 30;
~fps= 15;
~spready= 400;
~fps= 5;
~radius= 5;

//close the window to stop
