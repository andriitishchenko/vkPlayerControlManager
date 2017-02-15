
if (window.top === window) {
	window.addEventListener("keydown", keypressHandlerForAllOpenPages, false);

	//filter events for out tab by URL
	const patt = new RegExp("vk.com");
	if (patt.test(window.location.host)) {
		safari.self.addEventListener("message", vkCMD, false);

		//this is example how to track element change event
		// var observer11 = new MutationObserver(trackTitleChangedHandler),
  //       elTarget = document.querySelector('div.top_audio_player_title_wrap'),
  //       objConfig = {
  //           childList: true,
  //           subtree : false,
  //           attributes: false, 
  //           characterData : false
  //       };
		// observer11.observe(elTarget, objConfig);
		// observer11.disconnect(); //unUbserve
		//______
		// function trackTitleChangedHandler (mutations) {
	    //    mutations.forEach(function(mutation){
		// 	console.log(mutation.type);
		// });    
		// }

		var s1 = document.createElement('script');
		s1.type = 'text/javascript';
		s1.src = safari.extension.baseURI + 'contentbridge.js';
		document.head.appendChild(s1);
	}	
}

//will run in active tab
// ALT+F7 - back
// ALT+F8 - play
// ALT+F9 - next
// ALT+F11 - vol down
// ALT+F12 - vol up
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
		window.postMessage(message, window.location.origin);
	}
}
