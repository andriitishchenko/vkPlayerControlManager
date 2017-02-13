
if (window.top === window) {
	window.addEventListener("keydown", keypressHandlerForAllOpenPages, false);

	//filter events for out tab by URL
	const patt = new RegExp("vk.com");
	if (patt.test(window.location.host)) {
		safari.self.addEventListener("message", vkCMD, false);

		//this for changing page title with playing track title
		var observer11 = new MutationObserver(trackTitleChangedHandler),
        elTarget = document.querySelector('div.top_audio_player_title_wrap'),
        objConfig = {
            childList: true,
            subtree : false,
            attributes: false, 
            characterData : false
        };
		observer11.observe(elTarget, objConfig);
		// //observer11.disconnect(); //unUbserve
	}
}

//will run in active tab
// ALT+F7 - back
// ALT+F8 - play
// ALT+F9 - next
// ALT+F11 - vol up
// ALT+F12 - vol down
const allowExtentionKeys = ["F7", "F8", "F9", "F11","F12"];
function keypressHandlerForAllOpenPages() 
{
	const s = safari.self.tab;
	const e = event;
	if ( e.altKey && allowExtentionKeys.indexOf(e.keyIdentifier)!=-1 && event.target.nodeName.toLowerCase() !== 'input')
	{      
		safari.self.tab.dispatchMessage("keypressHandler",e.keyCode.toString());
	}
 	
}

// this function will call only for /vk.com/
// - cmd.name - extention cmd ID
// - cmd.message - extention cmd for web
function vkCMD(cmd) { 
	//console.log(cmd);
	var name = cmd.name;	
	var message = cmd.message;
	if (name == "vkPlayerControl") {
		switch (message) {
		  case "playtoggle":
		  	// actionForClass("audio_page_player_ctrl audio_page_player_play");
		  	actionForClass("top_audio_player_btn top_audio_player_play");
		    break;
		  case "next":
		    // actionForClass("audio_page_player_ctrl audio_page_player_next");
		    actionForClass("top_audio_player_btn top_audio_player_next");
		    break;
		  case "prew":
		  	// actionForClass("audio_page_player_ctrl audio_page_player_prev");
		  	actionForClass("top_audio_player_btn top_audio_player_prev");
		    break;
		  case "volumeup":
		  	//actionForClass("audio_page_player_ctrl audio_page_player_play");
		  	cmd_Volume(0.3);
		  break;
		  case "volumedown":
		  	cmd_Volume(-0.3);
		    break;
		  default:break;
		  
		}
	}
}

function cmd_Volume(value)
{
	//var _val = window.getAudioPlayer().getVolume();
	//getAudioPlayer().setVolume(_val+value);
}

function actionForClass(classElm)
{
	var x = document.getElementsByClassName(classElm);
	if (x === undefined || x.length == 0) { return; }
	// console.log(x);
	var clickEvent = new MouseEvent("click", {
    "view": window,
    "bubbles": true,
    "cancelable": true
	});
	x[0].dispatchEvent(clickEvent);

	// var ev = new Event("click", {"bubbles":true, "cancelable":true});
	// x[0].dispatchEvent(ev);	
}

function trackTitleChangedHandler (mutations) {
	var track_title = document.querySelector('div.top_audio_player_title');
	document.title = "VK Music: " + track_title.innerText;
	 //    mutations.forEach(function(mutation){
		// 	console.log(mutation.type);
		// });    
}
