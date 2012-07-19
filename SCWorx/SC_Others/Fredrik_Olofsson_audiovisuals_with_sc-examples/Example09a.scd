//Example09a - brighter is sharper
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example09a - brighter is sharper", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var pat= Pn(Pshuf(#[0, 0, 0, 0, 0.1, 0.25, 0.5, 0.75, 1, 1], 8), inf).asStream;
	var syn= SynthDef(\av, {|cutoff= 2000|
		var z= LPF.ar(LFSaw.ar(#[300, 301, 80, 81]).mean, cutoff);
		Out.ar(0, Pan2.ar(z));
	}, #[0.15]).play(s);		//lag time to avoid clipping
	var cnt= 0;
	var cut= 0;
	var drawStar= {|point, num, outer, inner|	//function that draws a star
		num.do{|i|
			Pen.moveTo(point+Polar(inner, i/num*2pi).asPoint);
			Pen.lineTo(point+Polar(outer, i/num*2pi+(pi/num)).asPoint);
			Pen.lineTo(point+Polar(inner, i+1/num*2pi).asPoint);
		};
		Pen.stroke;
	};
	
	//--interface
	~radius= 100;
	~fps= 30;
	~num= 20;
	~speed= 2;
	~spread= 0;
	~depth= 0.3;
	
	//--main loop
	u.drawFunc= {
		var r= ~radius+(cut*~spread);
		if(cnt%~fps.div(~speed)==0, {				//pick a new cutoff
			cut= pat.next;						//get the next value from the stream
			syn.set(\cutoff, cut*3000+500);			//send to the synth
		});
		cnt= cnt+1;
		Pen.translate(width*0.5, height*0.5);			//offset drawing to the centre
		Pen.strokeColor= Color.white;				//always stroke with white color
		drawStar.value(Point(0, 0), ~num, r, r*(1-(cut*~depth)));
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
~num= 5;
~speed= 12;
~radius= 25;
~num= 25;
~spread= 25;
~radius= 150;
~depth= 0.9;
~depth= -1.25;

//close the window to stop
