// make an Instance of GimpOSC to create the OSC-Responders etc.
x = GimpOSC.new

// you can set the size of the messages (in bytes) to Gimp via 
x.messageSize
x.messageSize = 1000
x.messageSize = 8000


// in Gimp: send an image to SC. ("SendOSC")
// If you are on Linux: make sure it is the right port:
NetAddr.langPort;

// if everything worked (you get messages in the PostBuffer), 
// the Bitmap is stored in:
x.pic

// If you make "ReceiveOSC" in Gimp, x.pic will be sent

// This is an instance of Bitmap, so you can f. e.
/// create a task out of it:

y = x.pic.asTask(type: \seq);
y.start;
y.stop;

y = x.pic.asTask;
y.start;
y.stop;

/// store it as a PPM-image file
x.pic.asPPM

/// get its dimensions
x.pic.width * x.pic.height * 4
