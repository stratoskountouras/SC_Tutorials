/*
Class 110315

Patterns
*/
s.boot;

// run this line
a = Pbind.new.play;

a.stop;		// Or stop it with cmd+period; 

// now run this line
Pbind(\freq, 440).play;

// run this, go back and run some of the others at the same time
(
Pbind(
	\dur,0.125,
	\midinote, Pseq([0, 4, 0, 7, 4, 0, 2] + 60,inf), 
	\amp, Prand([0.125, 0.2, 0.25],inf)
).play
)

// loops through the sequence of the array, perpetually:
Pseq([0,1,2,3],inf)	 

// next value is a random member of the array, after 5 times stop:
Prand([0,1,2,3],5)

// next value is a random member of the array 
// except you can't repeat the previous value:
Pxrand([0,1,2,3],inf)	

// next value is a weighted choice from the first array
// using the weights given in the second argument. 
// After returning one value, stop:
Pwrand([0,1,2,3], [0.5,0.3,0.1,0.1], 1)	
// next value is the result of evaluating the 
// given function, in this case 4.rand:
Pfunc({ 4.rand })

//	Patterns are generators for Streams. An example of a Stream is the Routine (see Scheduling)
//	To demonstrate how a Pattern turns into a Stream, ".asStream" is used:

//	run this one line at a time, observing the Post window  (Pattern help ...)

a = Pseq([1, 3, 400], inf);  	//make Pattern, a Pseq
x = a.asStream;			//turn this Pattern into a specific Stream
x.next;					//ask for the next value in the Stream


// Examples of nested Patterns
(
Pbind(
	\freq, Pseq([Pseq([100, 200, 300], 2), 400, 500, 600],inf)
).play;
)


(
Pbind(
	\freq, Pseq([Prand([440, 442, 445, 448]), Pxrand([840, 741, 642], 2)], inf)
// Pxrand never repeats the same value from the array twice in a row
).play;
)

//	Let's bring some of the hidden variables into view!

(
var clock;

clock = TempoClock(1.5); // tempoclock at 90 bpm

Pbind(
	\freq, Pseq([440, 660, 990, 880, 770], inf),     // frequency in hertz
	\dur, Pseq([1.0, 0.5],inf),			            // duration of event in beats
	\legato, 0.5,							       // proportion of inter onset time to play
	\pan, Pseq([0.5, -0.5],inf),
	\instrument, \default					
).play(clock);
)

//	The Pbind class always takes pairs of arguments, a literal \property and an associated Pattern (or value, or stream) that returns the values to be tied to that property. 

// Resonant filter http://en.wikipedia.org/wiki/LC_circuit
// http://en.wikipedia.org/wiki/Tuning_fork

Env.new([0,1,0.9,0], [0.1,0.5, 1],[-5,0,-5]).plot;
Env.new([0, 0.9, 0.3, 0.9, 0], [0.1, 0.1, 0.1, 0.1]).plot
Env.new([0, 0.9, 0], [0.1, 0.1], [2, 4]).plot
Env.new([0, 0.9, 0], [0.1, 0.1], 'sine').plot

(
SynthDef(\mySynth, {
	arg rezFreq = 100;
	var z;			
	z = Resonz.ar(WhiteNoise.ar(0.7), rezFreq);
	Out.ar(0, EnvGen.kr(Env.new([0, 0.9, 0], [0.1, 0.1], 'sine')) * z);
	}
).store
)

Synth(\mySynth).play


(
var clock;

clock = TempoClock(3.5); // tempoclock at 90 bpm

Pbind(
	\dur, Pseq([0.25,0.25,0.5, 1, 2],inf),				\legato, 0.2,	
	\rezFreq, Pseq([1000, 200, 500, 0, 5000], inf),			
	\instrument, \mySynth
).play(clock);
)

// two simultaneous voices using Ppar
(
	var melodypat, basspat;
	
	melodypat = Pbind( 
			[\midinote, \dur], 
			Prand([
				[60, 0.75],[64, 0.5],[66, 0.5],[69, 0.25],
				[67,0.75],[64,0.5],[60,0.5],[57,0.25]
			],8)
	);
	
	basspat = Pbind( 
			\midinote, Pseq([48, 42], inf),
			\dur, 1
	);
	
	Ppar([ melodypat, basspat ]).play(TempoClock(1)); 		
)


//  Nick Collins examples
(
// run me first-
SynthDef(\pulsepan,{arg freq;
		Out.ar(0,
			Pan2.ar(
				LFCub.ar(freq*0.5, Rand(0.4, 0.6), 0.2)
				* XLine.kr(0.001, 1, 0.9, doneAction:2),
				Rand(-1.0, 1.0)
			)
		)
}).send(s)
)


(
var p, t;

p = Pseq([100, 200, 300, 330, 478, Prand([987, 789], 1)],inf).asStream;

t = Routine({
		loop({
			Synth(\pulsepan,[\freq,p.next]); // get next frequency value from pattern
			0.1.wait;
		});
	});
SystemClock.sched(0.0,t)
)


(
SynthDef(\nickinstr, { arg out=0, freq=440, amp=0.1, pan=0, gate=1;
			var z;
			z = LPF.ar(
				Mix.ar(LFSaw.ar(freq*[0.99,1,1.01],0.0,amp)),
				XLine.kr(5000, 1000, 1.5)) 
			* EnvGen.kr(Env.new([0,1,0],[0.01,0.01],\lin,1), gate, doneAction:2); 
			Out.ar(out, Pan2.ar(z, pan));
		}).store; 
)

(
Pbind(
	\dur, 1.25,
	\midinote, Pseq([0,5,0,7,4,0,0]+60,inf), 
	\amp, Prand([0.125,0.2,0.25],inf), 
	\instrument, Pseq([\nickinstr,\default],inf),
	\pan, Prand([-1,0,1],inf)
).play
)






