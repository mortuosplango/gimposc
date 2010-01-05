/// this is currently broken


(
q.pic.do({ |rowValue,row|
			rowValue.do({ |val,pos|
				(val == 1).if({ 
					if(	array.at(row) != \pause,
						{ array.put(row,(max - pos).asArray 
							++ array.at(row)) },
						{ array.put(row,max - pos) }
					);
				});
			});
		}); 
)
q.pic.colsDo({|val,index| if(val.isNil, { index.postln }, {"no".postln;});});

q.pic.at(87,40)
x.add(17)
x

q.pic.rowAt(44).do({|val| x.add(val.first.linlin(0,255,-1.0,1.0)) })
x


q.pic.rows

(
var note = 'pause'!q.pic.cols;
var amp = 'pause'!q.pic.cols;
var pan = 'pause'!q.pic.cols;

q.pic.colsDo({ |colValue,col| 
	colValue.do({ |val,pos|
		(val.last > 200).if({ 
			if(	note.at(col) != \pause,
				{ 
					note.put(col,(pos / q.newpicheight).asArray 
						++ note.at(col));
					amp.put(col,
						val.last.linlin(0,255,0,1).asArray 
						++ amp.at(col));
					pan.put(col,(val[0].linlin(0,255,0,-1) 
						+ val[1].linlin(0,255,0,1)).asArray 
						++ pan.at(col));
				},
				{  
					note.put(col,(pos / q.newpicheight));
					amp.put(col,
							val.last.linlin(0,255,0,1));
					pan.put(col,(val[0].linlin(0,255,0,-1) 
						+ val[1].linlin(0,255,0,1)));			
				}
			);
		})})});

x = note;
y = amp;
z = pan;
)

x.do({ |v| v.postln });

y = x.copyRange(25,30)
y


// sehr langsam:
Pdef(\test, Pbind(\instrument, \default, \midinote, Pseq((x * 127) + 30,inf), \dur, 0.2, \amp, 0.01));

x.size

y

Pdef(\test).play;
Pdef(\test).stop;


// zu viel:
//Pdef(\test, Pbind(\instrument, \default, \midinote, Pseq((x * 127) + 30,inf), \dur, y, \amp, 0.1)).play;



// scanned synthesis aka take a list - make it a waveform

p = ProxySpace.push(s);
x = List.new;
q.pic.rowAt(20).do({ |val| x.add(val.last.linlin(0,255,-1.0,1.0)); })
x
~test2 = { Demand.ar(Impulse.ar(Demand.kr(Impulse.kr(0.2),0,Dwhite(10000,20000))), 0, Dseq(x,inf)).dup * 0.05};
x.size
~test2.stop
~test2.play


b = Buffer.loadCollection(s, x);
b.get(229,{|msg| (msg == a[229]).postln});
~test3 = { PlayBuf.ar(1, b, LFNoise0.kr(1), loop: 1).dup * 0.01 };
~test3.play
~test3.stop

s.scope

// interleave a multi-dimensional array
(
l = Signal.sineFill(16384, Array.fill(200, {0}).add(1));
r = Array.fill(16384, {1.0.rand2});
m = [Array.newFrom(l), r]; // a multi-dimensional array
m = m.lace(32768); // interleave the two collections 
b = Buffer.loadCollection(s, m, 2, {|buf|
x = { PlayBuf.ar(2, buf, BufRateScale.kr(buf), loop: 1) * 0.5 }.play;
});
)
b.plot;
x.free; b.free;


Pdef(\test).stop