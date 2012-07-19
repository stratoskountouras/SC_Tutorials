//Example17 - ffttrack
(
s.waitForBoot{
	l= 256;					//try with 512 if you have a fast machine
	b= Buffer.alloc(s, l, 1);
	c= Buffer.read(s, "sounds/a11wlk01.wav");
	SynthDef(\avTrk, {|in= 0, t_trig= 0|
		var z= In.ar(in, 1);
		var chain= FFT(b, z);
		Array.fill(l.div(2), {|i|
			var a= Unpack1FFT(chain, l, i, 0);
			var b= Demand.kr(chain>=0, 0, a);
			SendTrig.kr(t_trig, i, b);
		});
	}).send(s);
	SynthDef(\avSnd, {|out= 0, bufnum|
		var z= PlayBuf.ar(
			1,
			bufnum,
			BufRateScale.ir(bufnum)*LFPulse.kr(0.05, 0, 0.5, 0.2, -1.5),
			Impulse.kr(LFPulse.kr(0.1, 0, 0.1, 2, 1)),
			BufFrames.ir(bufnum)*LFNoise0.kr(0.2, 0.5, 0.5).round(0.2),
			1
		);
		Out.ar(out, Pan2.ar(z));
	}).send(s);
};
)

(
	//--window setup
	var width= 512+10, height= 512+10;
	var w= Window("Example17 - ffttrack", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var scale= if(l<=256, {2}, {1});					//scale can be 1 or 2
	var cnt= 0;									//horizontal drawing position
	var fftArray= Array.fill(l, 0);
	var o= OSCresponder(s.addr, '/tr', {|t, r, m|
		var v= m[3].min(1);						//brutal clip of mags here
		var i= l.div(2);
		fftArray= fftArray.put([i-m[2], i+m[2]], v);	//mirror middle of array
	}).add;
	var trk= Synth(\avTrk, [\in, 0]).play;
	var snd= Synth(\avSnd, [\out, 0, \bufnum, c]).play;
	
	//--interface
	~speed= 1;
	~version= 0;
	~radius= 2/scale;
	~depth= 0.01;
	~trails= 0.5;
	~fps= 30;
	
	//--main loop
	u.drawFunc= {
		switch(~version,
			0, {									//rectangles
				Pen.translate(5, 5);
				fftArray.do{|a, y|
					var p= Point(cnt*scale, height-10-(y*scale));
					Pen.fillColor= Color.grey((1-a).clip(0, 1));
					Pen.fillRect(Rect.aboutPoint(p, scale*~radius, scale*~radius));
				};
				cnt= cnt+~speed%fftArray.size;
				Pen.strokeColor= Color.red;
				Pen.line(Point(cnt*scale, 0), Point(cnt*scale, l*scale));
				Pen.stroke;
			},
			1, {									//ovals with a little transparency
				Pen.translate(5, 5);
				fftArray.do{|a, y|
					var p= Point(cnt*scale, height-10-(y*scale));
					Pen.fillColor= Color.grey((1-a).clip(0, 1), 0.5);
					Pen.fillOval(Rect.aboutPoint(p, scale*~radius, scale*~radius));
				};
				cnt= cnt+~speed%fftArray.size;
			},
			2, {									//rotation
				Pen.fillColor= Color.grey(1, ~trails);//clear color with some alpha
				Pen.fillRect(Rect(0, 0, width, height));//manually clear with rect
				fftArray.do{|a, y|
					var p= Point(cnt*scale, height-(y*scale));
					Pen.rotate(y/l*0.25*scale*2pi*~depth, width*0.5, height*0.5);
					Pen.fillColor= Color.grey((1-a).clip(0, 1));
					Pen.fillOval(Rect.aboutPoint(p, scale*~radius, scale*~radius));
				};
				cnt= cnt+~speed%fftArray.size;
			},
			3, {									//lines
				Pen.fillColor= Color.grey(1, ~trails);
				Pen.fillRect(Rect(0, 0, width, height));
				fftArray.do{|a, y|
					var p= Point(cnt.fold(0, l*scale), height-y);
					Pen.strokeColor= Color.grey(1-(a+0.5).clip(0, 1), 0.5);
					Pen.moveTo(p*a);			//move to before rotation special here
					Pen.rotate(y/l*pi*0.5*scale*~depth, width*0.5, height*0.5);
					Pen.lineTo(p);
					Pen.stroke;
				};
				cnt= cnt+~speed;
			}
		);
		trk.set(\t_trig, 1);						//to all send trigs
	};
	
	//--window management
	u.clearOnRefresh= false;						//do not erase - just draw on top of
	w.onClose= {
		snd.free;
		trk.free;
		o.remove;
	};
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/~fps).wait})}).play(AppClock);
)

//change these while the program is running
~version= 1;
~radius= 4;
~speed= 8;
~speed= l/6;
~radius= l/25;
~speed= -1;
~version= 2;
~trails= 0.01;
~radius= 5;
~speed= 2;
~radius= 0.5;
~depth= -0.002;
~depth= 3;
~radius= 1;
~trails= 0.5;
~version= 3;
~depth= 0.5;
~speed= 5;
~depth= -0.1;
~depth= -0.01
~trails= 0.01;

//close the window to stop
b.free;		//free the fft buffer
c.free;		//free the soundfile buffer
