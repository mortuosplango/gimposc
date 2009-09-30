////// (1) set global settings
(
//~synthName = \transping;

~scale = nil;
~octave = 0;
~root = 0;
~transp = 0;
~sustain = 0.5;
~amp = 0.05;
~synthspec = ~sSequencer;
~scale = Scale.choose(7, 12).tuning_(Tuning.choose(12).postln);
~scaleamps = false;
~tempoclock = TempoClock.new(queueSize:512);
)

//////// (2) load everything
(
(Document.current.path.dirname ++ "/gimposc-responders.scd").load;
(Document.current.path.dirname ++ "/gimposc-synths.scd").load;
(Document.current.path.dirname ++ "/gimposc-players.scd").load;
(Document.current.path.dirname ++ "/gimposc-gui.scd").load;
(Document.current.path.dirname ++ "/ppm.scd").load;
NetAddr.langPort;
)

/////////// (3) get some image and send it!
///////////////// (4) start!


~synthName = \pping;
(
// stop all still running synths
~synths.do({|item,i| (item.notNil).if(item.set(\gate, 0));});
~synths = nil!(~pic.rows + 1);
)
~synthspec = ~sMatrix
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


