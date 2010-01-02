/*
Image class - Wrapper around the NSImage class using the SCNSObject Bridge
require : Cocoa Bridge additions
*/

Bitmap : Collection {
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
	
	*fromArray { arg rows,cols, array;
		^this.new(rows,cols).with(array);
	}

	*fromArray255 { arg rows,cols, array;
		^this.new(rows,cols).with255(array);
	}

	with255 { arg aarray;	
		array = aarray.collect({|item| Color.fromArray255(item) }); }

	with { arg aarray;	
		array = aarray.collect({|item| Color.fromArray(item) }); }

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
	/*
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
	*/
	// TODO: besserer Name
	asSimpleArray { arg stripAlpha = false;
		^array.collect{|item| item.asArray255(stripAlpha) }
	}

	asBrightnessMap { 
		^array.collect({ |item|	item.brightness }).clump(width)
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


	// http://en.wikipedia.org/wiki/Portable_pixmap#PPM_example
	asPPM { arg filename="out";
		var content,file,bitmap;
		// P3 is the easiest format
		content = ("P3\n" ++ width ++ "\n"
			++ height ++ "\n" ++ "255" ++ "\n");
		bitmap = this.asSimpleArray(true).flat.clump(width * 3);
		height.do({|line|
			content = (content ++ bitmap[line]
				.asCompileString
				.removeEvery(",")
				.drop(-1).drop(1) ++ "\n");
		});
		file = File(filename ++ ".ppm","w");
		file.write(content ++ "\n");
		file.close;
		^"Written as " ++ filename ++ ".ppm."
	}
	/* not ready yet
	fromPPM { arg pathName;
		var file,line,array,format,newWidth,newHeight;
		if(File.exists(pathName),
			{
				file = File(pathName, r);
				format = file.getLine;
				newWidth = file.getLine.asInteger;
				newHeight = file.getLine.asInteger;
				// 255
				file.getLine;
				while( { line = file.getLine; line.notNil },
					{
						array = array ++ line
					}
				)
				
				
			},
			{ ^"File not found" })
	}
	*/
}