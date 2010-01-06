/*

Examples
(aka future helpfile)

*/

// Create an instance of GimpOSC (this also creates the necessary
// OSCresponders etc.
g = GimpOSC.new;

// in Gimp: send an image to SC. ("SendOSC")
// Please send moderately sized images (less than 800x600) ...
// If you are on Linux: make sure it sends to the right port:
NetAddr.langPort;

// if everything worked (you get messages in the PostBuffer), 
// the Bitmap is stored in:
g.pic;
// (If you start "ReceiveOSC" in Gimp, this Bitmap will be sent)


/// g.pic is an instance of Bitmap, so you can f. e.

// create a task out of it:
//   (you probably need to load the SynthDefs in gimposc-synths.scd first)

(Document.current.path.dirname ++ "/gimposc-synths.scd").load;
y = g.pic.asTask(type: \seq);
y.start;
y.stop;

y = g.pic.asTask;
y.start;
y.stop;

// store it as a PPM image file
g.pic.asPPM

// get its dimensions
g.pic.width * g.pic.height * 4

// get a 2-dimensional array with the brightness of every pixel
g.pic.asBrightnessMap

// get a specific pixel
g.pic.at(42,42)

//// other things which should be mentioned in a future helpfile
// you can set the size of the messages (in bytes) to Gimp via 
g.messageSize
g.messageSize = 1000
g.messageSize = 8000


////////// more interesting examples:

/// use the picture as FFT-Spectrum:
// extremely fragile - try with small pics first (e. g. 512x60) 
// the height shouldn't be more than 85 
// anything in the region of 1024x120 will certainly crash sc
p = ProxySpace.push(s);
p.fadeTime = 1;

(
~fft = {
	var mags, phases, chain, sig;
	// Create magnitudes from the brightness of a column
	mags = Dseq(g.pic.asBrightnessMap.flop,inf); 
	// Then give them a "rolloff" to make the sound less unpleasant
	mags = mags * (g.pic.height..0).normalize.squared;
	// Let's turn the bins on and off at different rates, I'm *sure* that'll
	//sound interesting
	//mags = mags * {LFPulse.kr(2 ** IRand(-3, 5)).range(0, 1)}.dup(100);
	// Take the MSPan-Value (i. e. (-1 * red) + (green)) as phase 
	phases = Dseq(g.pic.array.collect(_.asMSPan).clump(g.pic.width).flop, inf);
	//phases = 0!g.pic.height;
	// We need to create an FFT chain to feed our data in to.
	// The easiest way is to do an FFT on some signal which we then ignore!
	chain = FFT(LocalBuf(512), FSinOsc.ar);
	// Now we can do the packing
	chain = PackFFT(chain, 512, [mags, phases].flop.flatten, 0, g.pic.height - 1, 1);
	sig = IFFT(chain);
	sig.dup;
}
)
~fft.play

p.end(50);









