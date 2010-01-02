+ Color {
	asArray255 { arg stripAlpha = false;
		if(stripAlpha,
			{	^[red, green, blue].linlin(0.0,1.0,0,255) },
			{ 	^[red, green, blue, alpha].linlin(0.0,1.0,0,255) })
	}
	*fromArray255 { arg array;
		^this.new255(*array)
	}
	brightness {
		// 0,299 * R + 0,587 * G + 0,114 * B
		// taken from wikipedia
		^((0.299 * red)
		+ (0.587 * green)
		+ (0.114 * blue))
	}
	// as MetaSynth-Panning
	asMSPan {
		^((-1 * red) + (green))
	}
}