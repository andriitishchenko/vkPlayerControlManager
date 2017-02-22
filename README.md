# vkPlayerControlManager
VK Player Safari shortcuts

Also it demonstrate how to handle keyboard events and transfer messages it to the specific tab.


#How to:
-  open https://vk.com/
-  play music track
-  while Safari active press ALT+F9 from any other tab to play next track.

0r
- send keystroke through AppleScript/Services

0r
- use vkKeyBind agent app. While it running the ALT+F7 and other shurtcuts will be routed to Safari.
!You must add the app to trusted for handling keyboard events!

#Extention handle keyboard events 
-  ALT+F7 - play prev
-  ALT+F8 - play/pause
-  ALT+F9 - play next
-  ALT+F11 - volume control
-  ALT+F12 - volume control

#Download signed extension
https://github.com/andriitishchenko/vkPlayerControlManager/raw/master/VKPlayerHotkeys.safariextz

#For developers:

1 to make works unsigned extension in Safari need select: Safari->Developer->Allow unsigned Estensions

2 to allow handling keyboard events need add to trusted apps in Settings->Security&Privacy->Accessibility both Xcode and builded app.
