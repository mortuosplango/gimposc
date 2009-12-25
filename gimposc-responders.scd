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

// x.performList("sendMsg".asSymbol, ["/gimp/rec",1,2])
q.oscPing = OSCresponderNode(nil, '/gimp/ping', { arg time, resp, msg;
	var net, tarray, msize, newMsg;
	msize = 127;
	if( msg[1] == -1, 
		{   
			"ping triggered".postln;
			net = NetAddr.new("127.0.0.1", 57130);
			tarray = q.pic.asArray.flat;
			net.sendMsg("/gimp/spec", q.pic.cols, q.pic.rows, q.bpp);
			(tarray.size / msize).floor.asInteger.do({ |index|
				newMsg = tarray.copyRange(
					index * msize, 
					(index * msize) + (msize - 1));
				//net.sendMsg("/gimp/pic",newMsg);
				("sent slice " ++ index).postln;
				net.performList('sendMsg', ["/gimp/pic"] ++ index ++ newMsg);
			});
			net.performList('sendMsg',["/gimp/pic"] ++ 9999 ++
			//			net.sendMsg("/gimp/pic", 
				tarray.copyRange(
					tarray.size - (tarray.size % msize), tarray.size));
			net.sendMsg("/gimp/end", -1);
			(time.asString 
				++ ": Sent Array").postln; 
		}
		)
}).add;

"responders loaded";
