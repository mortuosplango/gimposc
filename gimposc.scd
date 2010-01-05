/*

Examples
(aka future helpfile)

*/

// Create an instance of GimpOSC (this also creates the necessary
// OSCresponders etc.
x = GimpOSC.new

// in Gimp: send an image to SC. ("SendOSC")
// If you are on Linux: make sure it sends to the right port:
NetAddr.langPort;

// if everything worked (you get messages in the PostBuffer), 
// the Bitmap is stored in:
x.pic
// (If you start "ReceiveOSC" in Gimp, this Bitmap will be sent)


/// x.pic is an instance of Bitmap, so you can f. e.

// create a task out of it:
//   (you probably need to load the SynthDefs in gimposc-synths.scd first)

(Document.current.path.dirname ++ "/gimposc-synths.scd").load;
y = x.pic.asTask(type: \seq);
y.start;
y.stop;

y = x.pic.asTask;
y.start;
y.stop;

// store it as a PPM image file
x.pic.asPPM

// get its dimensions
x.pic.width * x.pic.height * 4

// get a 2-dimensional array with the brightness of every pixel
x.pic.asBrightnessMap

// get a specific pixel
x.pic.at(42,42)

//// other things which should be mentioned in a future helpfile
// you can set the size of the messages (in bytes) to Gimp via 
x.messageSize
x.messageSize = 1000
x.messageSize = 8000
