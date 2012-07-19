//Example16 - amptrack
(
s.waitForBoot{
	c= Buffer.read(s, "sounds/a11wlk01.wav");
	SynthDef(\avTrk, {|in, t_trig, time= 0.01, cutoff= 400, index= 0|
		var z= In.ar(in, 1);
		var val= Amplitude.kr(BPF.ar(BPF.ar(z, cutoff, 0.1, 5), cutoff, 0.1, 5), time, time);
		SendTrig.kr(t_trig, index, val);
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
	var width= 500, height= 500;
	var w= Window("Example16 - amptrack", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var fps= 30;
	var num= 100;									//number of tuned filter synths
	var cnt= 0;									//vertical drawing position
	var amps= 0.dup(num);							//array of current amplitudes
	var o= OSCresponder(s.addr, '/tr', {|t, r, m| amps= amps.put(m[2], m[3])}).add;
	var syns= {|i|								//each tracker with an unique peakfilter
		Synth(\avTrk, [\in, 0, \index, i, \cutoff, i.linexp(0, num-1, 200, 6000)]).play;
	}.dup(num);
	var snd= Synth(\avSnd, [\out, 0, \bufnum, c]).play;	//something that generates sound
	
	//--interface
	~width= 120;
	~speed= 1;
	~version= 1;
	
	//--main loop
	u.drawFunc= {
		var wn= width/num;
		switch(~version,
			0, {
				Pen.translate(wn*0.5, cnt%height);
				amps.do{|amp, i|
					Pen.fillColor= Color.grey((amp).clip(0, 1));
					Pen.fillRect(Rect.aboutPoint(Point(wn*i, 0), wn*0.5, ~width));
				};
				cnt= cnt+~speed;
			},
			1, {
				amps.do{|amp, i|
					Pen.rotate(cnt, width*0.5, height*0.5);
					Pen.strokeColor= Color.grey(amp.clip(0, 1));
					Pen.strokeRect(Rect.aboutPoint(Point(wn*i, 0), ~width*0.1, ~width));
					cnt= cnt+(~speed*0.000001);
				};
			},
			2, {
				Pen.rotate(cnt, width*0.5, height*0.5);
				Pen.translate(width*0.5, height*0.5);
				
				amps.do{|amp, i|
					Pen.strokeColor= Color.grey(amp.clip(0, 1));
					Pen.strokeOval(Rect.aboutPoint(Point(i*~speed, 0), ~width*0.5, ~width*0.5));
				};
				cnt= cnt+(~speed*0.01);
			}
		);
		syns.do{|x| x.set(\t_trig, 1)};				//request amp data
	};
	
	//--window management
	u.clearOnRefresh= false;						//do not erase - just draw on top of
	w.onClose= {
		snd.free;
		syns.do{|x| x.free};
		o.remove;
	};
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/fps).wait})}).play(AppClock);
)

//change these while the program is running
~width= 220;
~speed= 2;
~speed= -0.1;
~speed= pi;
~version= 0;
~width= 1;
~speed= 1;
~width= 10;
~speed= 10;
~width= 500;
~version= 2;
~width= 100;
~speed= 1;
~speed= -1.5;
~width= 20;

//close the window to stop
c.free;		//free the soundfile buffer
