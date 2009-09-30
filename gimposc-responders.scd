[~oscW, ~oscPic].do({|item| (item.notNil).if({item.remove})});

~oscW = OSCresponderNode(nil, '/gimp/spec', { arg time, resp, msg; 
	~newpicwidth = msg[1];
    ~newpicheight = msg[2];                                                 
	~newpicbpp = msg[3];
	~newpic = [];
	~delay = time;
	(time.asString ++ ": Receiving new Array...").postln;
}).add;

~oscPic = OSCresponderNode(nil, '/gimp', { arg time, resp, msg;
	if( msg[1] == -1, 
		{   
			~pic = Array2D.fromArray(
				~newpicheight,
				~newpicwidth, 
				~newpic.clump(~newpicbpp));
			~bpp = ~newpicbpp;
			~delay = time - ~delay;
			(time.asString 
				++ ": Updated Array in " 
				++ ~delay ++ " seconds.").postln; 
		},
		{ 
			//msg.postln;
			//msg.size.postln;
			msg.removeAt(0);
			~newpic = ~newpic ++ msg; 
		}
		)
}).add;

"responders loaded";