window.addEventListener('message', function (e) {
	// console.log(e);
    if (e.origin != window.location.origin) return;

	switch (e.data) {
	  case "playtoggle":
	  	if (getAudioPlayer().isPlaying()) {
	  		getAudioPlayer().pause();
	  	}
	  	else
	  	{
	  		getAudioPlayer().play();
	  	}
	    break;
	  case "next":
	  	getAudioPlayer().playNext();
	    break;
	  case "prew":
	  	getAudioPlayer().playPrev();
	    break;
	  case "volumeup":
	  	cmd_Volume(0.1);
	  break;
	  case "volumedown":
	  	cmd_Volume(-0.1);
	    break;
	  default:break;		  
	}
	if (getAudioPlayer().isPlaying()){
		var trk = getAudioPlayer().getCurrentAudio();
		document.title = "VK Music: " + trk[4]+" "+trk[5];
	}

}, false);

function cmd_Volume(value)
{
	var _val = window.getAudioPlayer().getVolume();
	getAudioPlayer().setVolume(_val+value);
}
