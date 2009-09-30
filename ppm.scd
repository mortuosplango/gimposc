~writePPM = {|filename="test", array|
	var content,file;
	// P3 is the easiest format
	content = ("P3\n" ++ array.cols ++ "\n"
		++ array.rows ++ "\n" ++ "255" ++ "\n");
	array.rowsDo({|row|
		content = (content 
			++ row.flat.asCompileString.removeEvery(",").drop(-1).drop(1)
			++ "\n");
	});
	file = File(filename ++ ".ppm","w");
	file.write(content ++ "\n");
	file.close;
};

"ppm export function loaded"
