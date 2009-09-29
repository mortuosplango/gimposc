(
var f, g;
f = File("test.ppm","w");

f.write("P3\n" ++ "\n");
f.close;
)
(
~writePPM = {|filename="test", array|
	var content,file;
	content = ("P3\n" ++ array.cols ++ "\n"
		++ array.rows ++ "\n" ++ "255" ++ "\n");
	array.rowsDo({|row|
		content = (content 
			++ row.flat.asCompileString.replace(",").replace("[").replace("]")
			++ "\n");
	});
	file = File(filename ++ ".ppm","w");
	file.write(content ++ "\n");
	file.close;
};
)
~writePPM.value("test2", ~pic);
"test"

~pic.unbubble