/*[q.oscPic, q.oscSpec, q.oscPing].do({|item| (item.notNil).if({item.remove})});

q.oscSpec = OSCresponderNode(nil, '/gimp/spec', { arg time, resp, msg; 
	q.newpicwidth = msg[1];
    q.newpicheight = msg[2];
	q.newpicbpp = msg[3];
	q.newpic = [];
	q.delay = time;
	(time.asString ++ ": Receiving new Array...").postln;
}).add;

q.oscPic = 

// x.performList("sendMsg".asSymbol, ["/gimp/rec",1,2])
q.oscPing = 

"responders loaded";
*/

GimpOSC {
	var <respSpec, <respSender, <respReceiver, <pic, <>delay, <>specs, <>newPic, <>messageSize;
	*new {
		^super.new.init;
	}
	init{
		messageSize = 1000;
		respSender = OSCresponderNode(nil, '/gimp/ping', 
			{ arg time, resp, msg;
				var net, tarray, newMsg;
				// number of pixels in every message
				if( msg[1] == -1, 
					{   
						"ping triggered".postln;
						net = NetAddr.new("127.0.0.1", 57130);
						// flatten the array & discard alpha
						tarray = Int8Array.new;
						tarray = tarray.addAll(
							this.pic.asSimpleArray(true).flat);
						net.sendMsg("/gimp/spec", 
							this.pic.width, 
							this.pic.height,
							(this.pic.bpp - 1));// bpp without alpha
						// send the image as chunks to gimp
						(tarray.size / this.messageSize).floor.asInteger.do(
							{ |index|
								newMsg = Int8Array.new;
								// was passiert wenn index > 127?!
								/*newMsg = newMsg.addAll("/gimp/pic".ascii 
									++ [0,0] ++ ",ib".ascii 
									++ (0!4) ++ index ++ (0!4))*/
								newMsg = newMsg.addAll(tarray.copyRange(
								index * this.messageSize, 
								(index * this.messageSize) 
									+ (this.messageSize - 1)));
							net.sendMsg("/gimp/pic", index, newMsg);
							("sent slice " ++ index).postln;
							//net.performList(
							//	'sendMsg', 
							//	["/gimp/pic"] ++ index ++ newMsg);
						});
						newMsg = Int8Array.new;
						newMsg = newMsg.addAll(
							tarray.copyRange(
								tarray.size - 
								(tarray.size % this.messageSize), 
								tarray.size));
						net.sendMsg("/gimp/pic", 9999, newMsg);
						// end communication
						net.sendMsg("/gimp/end", -1);
						(time.asString 
							++ ": Sent Array").postln; 
					}
				)
		}).add;
		respSpec = OSCresponderNode(nil, '/gimp/spec', 
			{ arg time, resp, msg; 
				// width, height, bpp
				this.specs = [ msg[1], msg[2], msg[3]];
				this.newPic = [];
				this.delay = time;
				(time.asString ++ ": Receiving new Array...").postln;
			}).add;
		respReceiver = OSCresponderNode(nil, '/gimp', 
			{ arg time, resp, msg;
				if( msg[1] == -1, 
					{   
						this.pic = Bitmap.fromArray255(
							this.specs[0],
							this.specs[1], 
							(this.newPic%255).clump(specs[2]));
						this.delay = time - this.delay;
						(time.asString 
							++ ": Updated Array in " 
							++ this.delay ++ " seconds.").postln; 
					},
					{ 
						("Received chunk " ++ msg[1]).postln;
						this.newPic = this.newPic ++ msg[2]; 
					}
				)
			}).add;
		"Responders ready"
	}
	/* seems to crash sc */
	pic_ { arg img;
		if(img.isKindOf(Bitmap),
			{ pic = img },
			{ "Error: Not an image" });
		}
}