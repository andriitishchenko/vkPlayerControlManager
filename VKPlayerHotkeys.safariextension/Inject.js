
if (window.top === window) {
	window.addEventListener("keydown", keypressHandlerForAllOpenPages, false);
	safari.self.addEventListener("message", vkCMD, false);
}

//will run in active tab
// ALT+F7 - back
// ALT+F8 - play
// ALT+F9 - next
// ALT+ARROW_UP - vol up
// ALT+ARROW_DOWN - vol down
function keypressHandlerForAllOpenPages() 
{
	const s = safari.self.tab;
	const e = event;
	if ( e.altKey && event.target.nodeName.toLowerCase() !== 'input')
	{      
		safari.self.tab.dispatchMessage("keypressHandler",e.keyCode.toString());
	}
 	
}

// this function will call only for /vk.com/
// - cmd.name - extention cmd ID
// - cmd.message - extention cmd for web
function vkCMD(cmd) { 
	console.log(cmd);
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
		  	actionForClass("audio_page_player_ctrl audio_page_player_play");
		  break;
		  case "volumedown":
		  	actionForClass("audio_page_player_ctrl audio_page_player_play");
		    break;
		  default:break;
		  
		}
	}
}

function actionForClass(classElm)
{
	var x = document.getElementsByClassName(classElm);
	// console.log(x);
	// var clickEvent = new MouseEvent("click", {
 //    "view": window,
 //    "bubbles": true,
 //    "cancelable": false
	// });
	// x[0].dispatchEvent(clickEvent);
	var ev = new Event("click", {"bubbles":true, "cancelable":false});
	x[0].dispatchEvent(ev);

	
}