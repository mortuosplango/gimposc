/*
Image class - Wrapper around the NSImage class using the SCNSObject Bridge
require : Cocoa Bridge additions
*/

Image : Collection {
	var <width, <height, <color, <alpha, <array, <bpp;
	*new { arg width=128, height=64, color=1, alpha=1;
		^super.new.init(width,height);
	}
	init { arg argWidth, argHeight;
		height = argHeight;
		width = argWidth;
		// TODO: wie s/w-Bilder repräsentieren?!
		bpp = 4;
		array = Array.newClear(argHeight * argWidth);
		array.fill(Color.black)
	}

	size {
		^[width,height]
	}
	at { arg row, col;
		^array.at(row*width + col)
	}
	put { arg row, col, val;
		if( val.isKindOf(Color),
			{ array.put(row*width + col, val) },
			{ try {	array.put(row*width + col, Color.new(val)) }
				{ "not a valid color"}; })
	}

	asArray { ^array }
	
	// TODO: besserer Name
	asSimpleArray {
		^array.collect{|item| item.asArray255 }
	}
	
	asPattern { arg threshold = 0.6;
		var pattern = 'pause'!width;
		this.colsDo({|colValue,col| 
			colValue.do({ |val,pos|
				if(val.brightness > threshold,
					{ 
						if( pattern.at(col) != \pause,
							{ 
								pattern.put(col,(pos / height).asArray 
									++ pattern.at(col));
							},
							{  
								pattern.put(col,(pos / height));
							}
						);
					})})});
		^pattern
	}
	
	*fromArray { arg rows,cols, array;
		^this.new(rows,cols).with(array);
	}
	with { arg aarray;	array = aarray; }

	do { arg func;
		array.do(func)
	}
	colsDo { arg func;
		width.do({ arg ci;
			func.value( Array.fill(height,{ arg ri; this.at(ri,ci) }), ci )
		})
	}
	rowsDo { arg func;
		height.do({ arg ri;
			func.value( Array.fill(width,{ arg ci; this.at(ri,ci) }), ri )
		})
	}

	colAt { arg ci;
		^Array.fill(height,{ arg ri; this.at(ri,ci) })
	}
	rowAt { arg ri;
		^array.copyRange(ri * width, ri * width + width - 1)
	}

	// overide Array
	// add { ^thisMethod.shouldNotImplement }
	printOn { arg stream;
		// not a compileable string
		stream << this.class.name << "[ " ;
		this.rowsDo({ arg r;
			r.printOn(stream);
		});
		stream << " ]" ;
	}
	storeOn { arg stream;
		var title;
		stream << this.class.name << ".fromArray("
			<<<* [height,width,this.asArray] << ")";
		this.storeModifiersOn(stream);
	}
}