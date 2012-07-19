/**** 
	Note: all these examples require tracking data to produce sounds.
	As the subtleties of the tracking data are very hard to simulate, 
	we decided not to provide a (misleading) simulation. To hear the 
	examples in action, please see and hear the videos on the book website.
****/

// example juggling 12 - Rotational Grain Train

(
~rotater = {|amp = 1|
	var rotVel = ~rotVel.kr;	// rotVel and height from tracking data proxies
	BPF.ar(
		Impulse.ar((rotVel > 0.5) * rotVel * 5).lag(0.0001),
		(~height.kr * 120 + 36 + [[0, 7], [0, 12], [0, 16]]).midicps, 
		0.2
	).collect({ |pair| (pair * [1, 0.125]).sum }) 	* 6 * amp
};
)



// example juggling 13 - Rotation Trigger
(
~planeTicker = {|saw2sin = 1, filterFreq = 2000, fSpread = 0.4, amp = 0.1|
	
	
)



// example juggling 14 - Distances to the Head
(
~backCross = {|amp = 1|
	var aEnv, fEnv, aEnvNoise;
	
)


// example juggling 15 -  Left-right Trigger
(
~distances = {|amp = 0.2795| 
)


// example juggling 16 - Rain on Bells
(
~clackUp = { |amp = 0.1|