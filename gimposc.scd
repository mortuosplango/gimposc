
NetAddr.langPort

~oscW.remove;
~oscPic.remove;
 


(

~oscW = OSCresponderNode(nil, '/gimp/spec', { arg time, resp, msg; 
	~newpicwidth = msg[1];
	~newpicbpp = msg[2];
	~newpic = [];
	~delay = time;
	(time.asString ++ ": Receiving new Array...").postln;
}).add;

~oscPic = OSCresponderNode(nil, '/gimp', { arg time, resp, msg;
	if( msg[1] == -1, 
		{   
			~pic = Array2D.fromArray(
				(~newpic.size / (~newpicwidth * ~newpicbpp)),
				~newpicwidth, 
				~newpic.clump(~newpicbpp));
			~bpp = ~newpicbpp;
			~delay = time - ~delay;
			(time.asString ++ ": Updated Array in " 
				++ ~delay 
				++ " seconds.").postln; 			
		},
		{ 
			//msg.postln;
			//msg.size.postln;
			msg.removeAt(0);
			~newpic = ~newpic ++ msg; }
		)
}).add;

)





~pic = [1,[1,2]]

~pic = ~pic ++ ~pic
~pic = Array2D.fromArray(
	~newpicwidth, 
	(~newpic.size * 0.5 / ~newpicwidth), 
	~newpic.clump(2).clump(~newpic.size * 0.5 / ~newpicwidth).flop.flatten(1));

~pic.rows
~pic.cols


~pic
~pic.asArray.flatten.size
~pic.size

~pic.size

256*88/2



~pic.asArray.flop
