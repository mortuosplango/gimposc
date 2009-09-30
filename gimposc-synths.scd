b = Buffer.readChannel(s, Document.current.path.dirname ++ "/sounds/strangetown.aiff", channels: [0]);

SynthDef(\pgrain, { |gate=1, amp=1, position=0.5 sustain=0.1,dur=0.1, rate=1, pan=0, density=1, sndbuf='b'|
	var env;
	env = EnvGen.ar(Env.sine(sustain,amp), doneAction:2);
	OffsetOut.ar(0,
		GrainBuf.ar(2, 
			Dust.ar(density), 
			dur, 
			sndbuf, 
			rate * Rand(0.5,1.5),
			//MouseX.kr(0,1),
			//LFNoise2.kr(0.1).range(0, 1), 
			position,
			2, 
			pan,
			-1) 
		* env)
}).send(s);
/*
SynthDef(\ggrain, { |gate=1, amp=1, dur=0.1, rate=1, pan=0, density=1, sndbuf='b', envbuf='z'|
	var env, freqdev;
	// use mouse x to control panning
	env = EnvGen.ar(
		Env([0, 1, 0], [1, 1], \sin, 1),
		gate,
		levelScale: amp,
		doneAction: 2);
	Out.ar(0,
		GrainBuf.ar(2, 
			Dust.kr(10 * density.lag), 
			dur.lag, 
			sndbuf, 
			LFNoise1.kr.range(0.5, 1.5) * rate.lag,
			//MouseX.kr(0,1),
			LFNoise2.kr(0.1).range(0, 1), 
			2, 
			pan, 
			envbuf) 
		* env)
}).send(s);
*/
SynthDef(\pping, { |freq=440, sustain=0.1, gate=1, amp=0.1|
	var signal = SinOsc.ar(freq).clip(-0.9,0.9) * 
	EnvGen.ar(Env.adsr(0.1, 0.4, 0.8, 1, 1, -4), gate, doneAction:2);
	Out.ar(0, signal.dup * amp.lag(sustain));
}).send(s);

SynthDef(\welshping, { |freq=440, sustain=1, gate=0, amp=0.1|
	var signal = SinOsc.ar(freq,1.0.rand);
	var env = EnvGen.ar(Env.sine(sustain,amp), doneAction:2);
	Out.ar(0, env * signal.dup);
}).send(s);

SynthDef(\transping, { |freq=440, sustain=1, gate=0, amp=0.1, shape=1, pan=0|
	var signal, env;
	// make sure shape is between 0 and 1
	//	shape = shape % 1;
	//shape = MouseX.kr(0,1,0);
	// low level interpolation between Saw and Sine
	signal = (shape * SinOsc.ar(freq)) + ((1-shape) * Saw.ar(freq));
	env = EnvGen.ar(Env.sine(sustain,amp), doneAction:2);
	Out.ar(0, Pan2.ar(env * signal,pan));
}).send(s);


~synthList = [\ping, \sine, \pong];

// pong
SynthDef(~synthList[2], { |out, freq=440, pan, amp=0.1, sustain=0.25, gate = 1|
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.adsr, gate, doneAction:2);
	snd = Pan2.ar(snd, pan);
	OffsetOut.ar(out, snd*amp);
}).send(s);


// ping
SynthDef(~synthList[0], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.perc(0.01, sustain), doneAction:2);
	snd = Pan2.ar(snd, pan);
	OffsetOut.ar(out, snd*amp);
}).send(s);

// sine
SynthDef(~synthList[1], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.sine(sustain), doneAction:2);
	snd = Pan2.ar(snd, pan);
	OffsetOut.ar(out, snd*amp);
}).send(s);

"synths loaded"
