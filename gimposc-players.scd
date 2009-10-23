///////////////////// PLAYER (originally by rukano)
/////////////////// Grain-Painting-like player
q.grains =  {|dict, ipos, compamp, item| 
	if(item[0] > 150){ 
		Synth.grain(\pgrain, 
			[
				\sndbuf, b, 
				\density, 	item.last.linlin(0,255,0,10),
				\position, ipos.linlin(0,(q.pic.rows-1),0,1),
				//\rate, item[1].linlin(0,255,0.5,),
				\rate, 0.5,
				\sustain, q.sustain
			]);
	};
};
/////////////////// Sequencer-like player
q.sequencer = {|dict, ipos, compamp, item|
			switch(q.synths[ipos].isNil.asArray ++ (item[0] != 0),
				[true, true], {
					// ("create " ++ pos).postln;
					q.synths.put(ipos, 
						Synth(\pping,
							[
								//\scale, ~scale,
								\amp, item.last.linlin(0,255,0,compamp),
								\gate, 1, 
								//\sustain, q.sustain,
								//\octave, ~octave,
								//\root, ~root,
								//\ctranspose, ~transp,
								//shape:      item[1].linlin(0,255,0,1),
								\pan, (item[0].linlin(0,255,-1,0) 
									+ item[1].linlin(0,255,0,1)),
								\freq, ipos.midicps
							]));
				},
				[false,true],{
					// ("mod " ++ pos).postln;
					q.synths[ipos].set(
					\amp, item[0].linlin(0,255,0,compamp));
				},				
				[false,false],{
					// ("kill " ++ pos).postln;
					q.synths[ipos].set(\gate,0);
					q.synths.put(ipos,nil);	
				});
};
////////////// Matrixsequencer-like player
q.matrix = {|dict, ipos, compamp,item|
				if(item[0] != 0){ 
				//item[0].postln;
				(
					instrument:	\transping,
					scale:		q.scale,
					amp:		item.last.linlin(0,255,0,compamp),
					//gate:       item[-1],
					sustain:	q.sustain,
					octave:		q.octave,
					root:		q.root,
					ctranspose:	q.transp,
					degree:		ipos,
					shape:      item[1].linlin(0,255,0,1),
					pan:        item[2].linlin(0,255,-1,1)
				).play;
			};
};
////////////// Player framework
q.player = Task({
	var compamp,sumamp,col,ipos;
	q.synths = nil!(q.pic.rows + 1);
	inf.do{ |counter|
		col = counter % q.pic.cols;
		
		if(q.slider != nil, {q.slider.value_(col / q.pic.cols)});
		// scale amplitudes
		if(q.scaleamps == true, 
			{
				sumamp = q.pic.colAt(col)
				.flop.[3].drop(-1).linlin(0,255,0,1).sum;
				(sumamp > 0).if(compamp = q.amp /sumamp, compamp = q.amp);
			}, { 
				compamp = q.amp;
			});
		// main func
		q.pic.colAt(col).do{ |item, pos|
			var ipos = (pos - (q.pic.rows-1)).abs;
			q.sequencer(ipos, compamp, item);
		};
		col.postln;
		(q.sustain/2).wait;
		}
}, TempoClock.new(queueSize:512));


"player loaded"