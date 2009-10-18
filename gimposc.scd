////// (1) set global settings
(
//q.synthName = \transping;

q.scale = nil;
q.octave = 0;
q.root = 0;
q.transp = 0;
q = ();
q.sustain = 0.5;
q.amp = 0.05;
q.synthspec = q.sequencer;
q.scale = Scale.choose(7, 12).tuning_(Tuning.choose(12).postln);
q.scaleamps = false;
q.synths = nil;
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


OpenObject

q.synthName = \pping;
(
// stop all still running synths
q.synths.do({|item,i| (item.notNil).if(item.set(\gate, 0));});
q.synths = nil!(q.pic.rows + 1);
)
q.synthspec = q.sMatrix
q.synthspec = q.sSequencer
q.synthspec = q.sGrains

q.player.start;
q.player.stop;
q.player.reset;

//q.synthName = \transping;
q.synthName = \pgrain;
//q.synthName = \welshping;
//q.synthName = \pping;
q.sustain = 0.1;


