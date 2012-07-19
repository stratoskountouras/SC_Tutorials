//--

updated 090703 for sc 3.3.1 (and swingosc 0.62)
* now using view redirect classes
* lower initial framerate for ex 01-11
* removed all relativeOrigin_

//--

all examples have been written for supercollider version 3.2 or greater and tested on mac osX.4.8 ppc 1ghz and mac osX.4.11 intel 2.16ghz.  see these as minimal and optimal requirements.

all examples have been tested with swingosc0.59 on mac and psycollider under xp.  also tested with the current version of supercollider (3.3) and swingosc (0.61) on mac.

note to windows users:
there are some latency problems with version 3.2 of psycollider and the standard MME drivers.  please make sure your server's latency is set to something lower than ~0.1 (0.05 preferably).  use ASIO drivers if possible.  if psycollider doesn't report a low latency after you booted the server, all these examples will _not function properly.
so for my examples: "suggestedLatency used: 0.2" is bad and audio and video will not be in sync.  "suggestedLatency used: 0.006" is very good.

redFrik feb'09


