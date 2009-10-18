[q.oscPic, q.oscSpec].do({|item| (item.notNil).if({item.remove})});

q.oscSpec = OSCresponderNode(nil, '/gimp/spec', { arg time, resp, msg; 
	q.newpicwidth = msg[1];
    q.newpicheight = msg[2];
	q.newpicbpp = msg[3];
	q.newpic = [];
	q.delay = time;
	(time.asString ++ ": Receiving new Array...").postln;
}).add;

q.oscPic = OSCresponderNode(nil, '/gimp', { arg time, resp, msg;
	if( msg[1] == -1, 
		{   
			q.pic = Array2D.fromArray(
				q.newpicheight,
				q.newpicwidth, 
				q.newpic.clump(q.newpicbpp));
			q.bpp = q.newpicbpp;
			q.delay = time - q.delay;
			(time.asString 
				++ ": Updated Array in " 
				++ q.delay ++ " seconds.").postln; 
		},
		{ 
			//msg.postln;
			//msg.size.postln;
			msg.removeAt(0);
			q.newpic = q.newpic ++ msg; 
		}
		)
}).add;

"responders loaded";