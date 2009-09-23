///////////////////// PLAYER (originally by rukano)

/////// GUI
(
var win,bStart,bReset,bFree;
win = Window.new("GimpOSC",Rect(1280-600, 800-60, 540, 60)).front;
~slider = Slider(win, Rect(10,30, 520, 40));
~slider.action = { ~slider.value.postln; };
bStart = Button.new(win, Rect(10,10,100,15))
.states_([
["Play", Color.black, Color.red],
["Stop", Color.white, Color.black]
])
.action_({ arg butt;
	switch( bStart.value,
		0, {~player.stop},
		1, {~player.play}
	);
});
bReset = Button.new(win, Rect(120,10,100,15))
.states_([
["Reset", Color.black, Color.green],
])
.action_({ ~player.reset });
bFree = Button.new(win, Rect(230,10,100,15))
.states_([
["Free Synths", Color.black, Color.red],
])
.action_({ ~synths.do({|item,i| (item.notNil).if(item.set(\gate, 0));}) });
)

////// Global Settings

(
~synthName = \transping;

~scale = nil;
~octave = 0;
~root = 0;
~transp = 0;
~sustain = 0.5;
~amp = 0.02;
~scale = Scale.choose(7, 12).tuning_(Tuning.choose(12).postln);
~tempoclock = TempoClock.new(queueSize:512);
)

~player.play;
~player.stop;
~player.reset;

Synth.grain(~synthName, [\sndbuf, b, \envbuf, z])
~synthName
/////////////// GRAIN-Player
//http://www.freesound.org/samplesViewSingle.php?id=7806
(
//~synthName = \transping;
~synthName = \pgrain;
//~synthName = \welshping;
//~synthName = \pping;
~sustain = 0.1;


~player = Task({
	//	var playing = nil!~pic.cols;
	inf.do{ |counter|
		var col = counter % ~pic.cols;
		// scale amplitudes
		~sumamp = ~pic.colAt(col).flop.[0].drop(-1).linlin(0,255,0,1).sum;
		(~sumamp > 0).if(~compamp = ~amp / ~sumamp, ~compamp = ~amp);
		// main func
		~pic.colAt(col).do{ |item, pos|
			var ipos = (pos - (~pic.rows-1)).abs;
			if(item[0] != 0){ 
				//item[0].postln;
				Synth.grain(~synthName, 
					[
						\sndbuf, b, 
						\density, 	item[0].linlin(0,255,0,10),
						\position, ipos.linlin(0,(~pic.rows-1),0,1),
						//\pan, item[2].linlin(0,255,-1,1),
						//\rate, item[1].linlin(0,255,0,1),
						\sustain, ~sustain
					]);
			};
			
		};
		col.postln;
		(~sustain/2).wait;
		}
}, ~tempoclock);
)

/////////////////// Sequencer-like player
~synthName = \pping;

// stop all still running synths
~synths.do({|item,i| (item.notNil).if(item.set(\gate, 0));});


(
~synthName = \pping;
~player = Task({
	~synths = nil!~pic.rows;
	inf.do{ |counter|
		var compamp,sumamp,col,ipos;

		col = counter % ~pic.cols;
		~slider.value_(col / ~pic.cols);
		// scale amplitudes
		sumamp = ~pic.colAt(col).flop.[0].drop(-1).linlin(0,255,0,1).sum;
		(sumamp > 0).if(compamp = ~amp /sumamp, compamp = ~amp);
		// main func
		~pic.colAt(col).do{ |item, pos|
			ipos = (pos - (~pic.rows-1)).abs;
			switch(~synths[pos].isNil.asArray ++ (item[0] != 0),
				[true, true], {
					// ("create " ++ pos).postln;
					~synths.put(pos, 
						Synth(~synthName,
							[
								//\scale, ~scale,
								\amp, item[0].linlin(0,255,0,compamp),
								\gate, 1, 
								\sustain, ~sustain,
								//\octave, ~octave,
								//\root, ~root,
								//\ctranspose, ~transp,
								//shape:      item[1].linlin(0,255,0,1),
								//pan:        item[2].linlin(0,255,-1,1)]);
								\freq, ipos.midicps
							]));
				},
				[false,true],{
					// ("mod " ++ pos).postln;
					~synths[pos].set(
					\amp, item[0].linlin(0,255,0,compamp));
				},				
				[false,false],{
					// ("kill " ++ pos).postln;
					~synths[pos].set(\gate,0);
					~synths.put(pos,nil);	
				})
		};
		col.postln;
		(~sustain/2).wait;
	}
}, ~tempoclock);
)

//////////////////// Grain-Like player
(
//~synthName = \transping;
~synthName = \ping;
//~synthName = \welshping;
//~synthName = \pping;

~player = Task({
	//	var playing = nil!~pic.cols;
	inf.do{ |counter|
		var col = counter % ~pic.cols;
		// scale amplitudes
		~sumamp = ~pic.colAt(col).flop.[0].drop(-1).linlin(0,255,0,1).sum;
		(~sumamp > 0).if(~compamp = ~amp / ~sumamp, ~compamp = ~amp);
		// main func
		~pic.colAt(col).do{ |item, pos|
			var ipos = (pos - (~pic.rows-1)).abs;
			if(item[0] != 0){ 
				//item[0].postln;
				(
					instrument:	~synthName,
					scale:		~scale,
					amp:		item[0].linlin(0,255,0,~compamp),
					gate:       item[0],
					sustain:	~sustain,
					octave:		~octave,
					root:		~root,
					ctranspose:	~transp,
					degree:		ipos,
					shape:      item[1].linlin(0,255,0,1),
					pan:        item[2].linlin(0,255,-1,1)
				).play;
			};
			
		};
		col.postln;
		(~sustain/2).wait;
		}
}, ~tempoclock);
)