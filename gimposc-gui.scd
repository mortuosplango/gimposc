/////// GUI
var win,bStart,bReset,bFree;
win = Window.new("GimpOSC",Rect(1280-600, 800-60, 540, 60)).front;
~slider = Slider(win, Rect(10,30, 520, 40));
~slider.action = { ~slider.value.postln; };
bStart = Button.new(win, Rect(10,10,100,15))
.states_([
["Play", Color.black, Color.red],
["Stop", Color.white, Color.black]
])
.action_({ arg butt;
switch( bStart.value,
0, {~player.stop},
1, {~player.play}
);
});
bReset = Button.new(win, Rect(120,10,100,15))
.states_([
["Reset", Color.black, Color.green],
])
.action_({ ~player.reset });
bFree = Button.new(win, Rect(230,10,100,15))
.states_([
["Free Synths", Color.black, Color.red],
])
.action_({ 
	~synths.do({|item,i| (item.notNil).if(item.set(\gate, 0));});
	~synths = nil!(~pic.rows + 1);
});


"gui loaded"