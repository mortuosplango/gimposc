[q.oscPic, q.oscSpec, q.oscPing].do({|item| (item.notNil).if({item.remove})});

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

q.oscPing = OSCresponderNode(nil, '/gimp/ping', { arg time, resp, msg;
	if( msg[1] == -1, 
		{   
			var net, tarray;
			net = NetAddr.new("127.0.0.1",57130);
			tarray = q.pic.asArray.flat;
			net.sendMsg("/gimp/spec", q.pic.cols, q.pic.rows, q.bpp - 1);
			(tarray.size / 1024).trunc.do({ |index|
				net.sendMsg("/gimp/pic", 
					tarray.copyRange(index * 1024, (index * 1024) + 1023));
			});
			net.sendMsg("/gimp/pic", tarray.copyRange(tarray.size - (tarray.size % 1024), tarray.size));
			q.pic = Array2D.fromArray(
				q.newpicheight,
				q.newpicwidth, 
				q.newpic.clump(q.newpicbpp));
			q.bpp = q.newpicbpp;
			q.delay = time - q.delay;
			(time.asString 
				++ ": Updated Array in " 
				++ q.delay ++ " seconds.").postln; 
		}
		)
}).add;

"responders loaded";