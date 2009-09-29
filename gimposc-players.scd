///////////////////// PLAYER (originally by rukano)

////// Global Settings

(
//~synthName = \transping;

~scale = nil;
~octave = 0;
~root = 0;
~transp = 0;
~sustain = 0.2;
~amp = 0.05;
~synthspec = ~sSequencer;
~scale = Scale.choose(7, 12).tuning_(Tuning.choose(12).postln);
~scaleamps = false;
~tempoclock = TempoClock.new(queueSize:512);
)
~pic.cols



~synthName = \pping;
(
// stop all still running synths
~synths.do({|item,i| (item.notNil).if(item.set(\gate, 0));});
~synths = nil!(~pic.rows + 1);
)
~synthspec = ~sMatrixlike
~synthspec = ~sSequencer
~synthspec = ~sGrains

~player.start;
~player.stop;
~player.reset;

//~synthName = \transping;
~synthName = \pgrain;
//~synthName = \welshping;
//~synthName = \pping;
~sustain = 0.1;


(
/////////////////// Grain-Painting-like player
~sGrains =  {|ipos, compamp, item| 
	if(item[0] > 150){ 
		Synth.grain(\pgrain, 
			[
				\sndbuf, b, 
				\density, 	item[0].linlin(0,255,0,10),
				\position, ipos.linlin(0,(~pic.rows-1),0,1),
				//\rate, item[1].linlin(0,255,0.5,),
				\rate, 0.5,
				\sustain, ~sustain
			]);
	};
};
/////////////////// Sequencer-like player
~sSequencer = {|ipos, compamp, item|
			switch(~synths[ipos].isNil.asArray ++ (item[0] != 0),
				[true, true], {
					// ("create " ++ pos).postln;
					~synths.put(ipos, 
						Synth(\pping,
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
					~synths[ipos].set(
					\amp, item[0].linlin(0,255,0,compamp));
				},				
				[false,false],{
					// ("kill " ++ pos).postln;
					~synths[ipos].set(\gate,0);
					~synths.put(ipos,nil);	
				});
};
////////////// Matrixsequencer-like player
~sMatrixlike = {|ipos, compamp,item|
				if(item[0] != 0){ 
				//item[0].postln;
				(
					instrument:	\transping,
					scale:		~scale,
					amp:		item[0].linlin(0,255,0,compamp),
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

~player = Task({
	var compamp,sumamp,col,ipos;
	~synths = nil!(~pic.rows + 1);
	inf.do{ |counter|
		col = counter % ~pic.cols;
		if(~slider != nil, {~slider.value_(col / ~pic.cols)});
		// scale amplitudes
		if(~scaleamps == true, 
			{
				sumamp = ~pic.colAt(col)
				.flop.[0].drop(-1).linlin(0,255,0,1).sum;
				(sumamp > 0).if(compamp = ~amp /sumamp, compamp = ~amp);
			}, { 
				compamp = ~amp;
			});
		// main func
		~pic.colAt(col).do{ |item, pos|
			var ipos = (pos - (~pic.rows-1)).abs;
			~synthspec.value(ipos, compamp, item);
		};
		col.postln;
		(~sustain/2).wait;
		}
}, ~tempoclock);
)