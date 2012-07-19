//Example14 - particle system
//click and drag in the window
(
s.waitForBoot{

	//--window setup
	var width= 640, height= 480;
	var w= Window("Example14 - particle system", Rect(99, 99, width, height), false);
	var u= UserView(w, Rect(0, 0, width, height));
	
	//--variables
	var synths= ();								//keep track of synths objects
	var prev= Point(0, 0);							//previous mouse position
	var mouse= prev;
	var parts= [];
	var makePart= {|pnt|							//pseudo class
		(
			\vel: Point(2.0.rand2, 10.rand.neg),		//velocity vector
			\pos: pnt,
			\age: (~dead*0.5).linrand,
			\mas: ~mass.rand,
			\syn: Synth(\av)
		)
	};
	SynthDef(\av, {|freq= 400, fm= 1, beat= 1, amp= 0, pan= 0, gate= 1|
		var e= EnvGen.ar(Env.asr(0.01, 1, 0.02), gate, doneAction:2);
		var z= SinOsc.ar(freq*SinOsc.ar(0, SinOsc.ar(fm, 0, 2pi), beat), 0, amp);
		Out.ar(0, Pan2.ar(z, pan, e));
	}, #[0.05, 0.05, 0.05, 0.05, 0.05]).send(s);
	u.mouseMoveAction_{|v, x, y| mouse= Point(x, y)};	//update mouse position
	
	//--interface
	~fps= 30;
	~dead= 500;									//max age
	~mass= 1.5;									//max mass
	~damp= 0.98;									//general damping
	~grav= Point(0, 0.98);							//gravity vector
	
	//--main loop
	u.drawFunc= {
		if(mouse!=prev, {
			prev= mouse;
			parts= parts.add(makePart.value(prev));	//new particle
			
		});
		parts= parts.select{|p|						//remove old ones
			if(p.age<~dead, {
				true;
			}, {
				p.syn.release;
				false;
			});
		};
		parts.do{|p|								//update each ball
			var r;
			p.vel= p.vel+(~grav*p.mas);				//apply gravity force
			p.vel= p.vel*~damp;					//general damping
			if(p.pos.x>width or:{p.pos.x<0}, {		//bounce leftright bounds
				p.vel= p.vel*Point(-1, 1);
			});
			if(p.pos.y>height or:{p.pos.y<0}, {		//bounce topbottom bounds
				p.vel= p.vel*Point(1, -1);
			});
			p.pos= p.pos+p.vel;					//move the ball
			p.age= p.age+1;
			p.syn.set(							//system maps to sound
				\freq, p.pos.y.linexp(0, height, 2000, 200),
				\amp, p.pos.y.linlin(0, height, p.mas, 0)*(1-(p.age/~dead))*0.1,
				\fm, p.mas*p.pos.x,
				\beat, p.vel.asComplex.magnitude,	//ball velocity mapped to beat
				\pan, p.pos.x.linlin(0, width, -1, 1)
			);
			r= 1-(p.age/~dead)*p.mas*10;			//radius
			Pen.fillColor= Color.grey(1-(p.age/~dead), 1);
			Pen.fillOval(Rect.aboutPoint(p.pos, r, r));
		};
	};
	
	//--window management
	u.clearOnRefresh= true;
	u.background= Color.black;
	w.onClose= {parts.do{|p| p.syn.free}};
	w.front;
	Routine({while({w.isClosed.not}, {u.refresh; (1/~fps).wait})}).play(AppClock);
};
)

//change these while the program is running
~mass= 4;
~grav= Point(0.1, 0.1);
~grav= Point(-0.1, -0.1);
~damp= 0.9;

//close the window to stop
