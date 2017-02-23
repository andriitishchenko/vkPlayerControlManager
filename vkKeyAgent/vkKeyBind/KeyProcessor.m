//
//  keyProcessor.m
//  vkKeyBind
//
//  Created by andrux on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "KeyProcessor.h"

#import <stdio.h>
#import <time.h>
#import <string.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>

@interface KeyProcessor()
//    @property(strong, nonatomic) NSMutableArray<KeyProcessorDelegate>* observers;

@end

@implementation KeyProcessor
+ (KeyProcessor *)sharedInstance{
    static dispatch_once_t  onceToken;
    static KeyProcessor * sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [KeyProcessor new];
        sSharedInstance.state = NO;
    });
    
    return sSharedInstance;
}

-(BOOL)start{
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @NO};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    
    if(accessibilityEnabled){
        CGEventMask eventMask = (1 << kCGEventKeyDown);
        CFRunLoopSourceRef  eventSrc;
        CFMachPortRef machPortRef =
        
        CGEventTapCreate(
                         kCGSessionEventTap,
                         kCGHeadInsertEventTap,
                         0,
                         eventMask,
                         CGEventCallback,
                         NULL
                         );
        
        
        
        
        
        if (machPortRef == NULL)
        {
            NSLog(@"CGEventTapCreate failed!\n");
        } else {
            eventSrc = CFMachPortCreateRunLoopSource(NULL, machPortRef, 0);
            if ( eventSrc == NULL )
            {
                NSLog( @"No event run loop src?\n" );
            }else {
                CFRunLoopRef runLoop =  CFRunLoopGetCurrent(); //GetCFRunLoopFromEventLoop(GetMainEventLoop ());
                
                // Get the CFRunLoop primitive for the Carbon Main Event Loop, and add the new event souce
                CFRunLoopAddSource(runLoop, eventSrc, kCFRunLoopDefaultMode);
                self.state = YES;
            }
        }

    
    }
    
    return accessibilityEnabled;
}

CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if (type != kCGEventKeyDown && type != kCGEventFlagsChanged  && type != kCGEventKeyUp) { return event; }
    
//    CGKeyCode keyCode = (CGKeyCode) CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
//    CGEventFlags flagsP = CGEventGetFlags(event);
//    BOOL isKeyCMD = (flagsP & kCGEventFlagMaskCommand) == kCGEventFlagMaskCommand;
//    BOOL isKeyALT = (flagsP & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate;
//    BOOL isKeyCTRL = (flagsP & kCGEventFlagMaskControl) == kCGEventFlagMaskControl;
    
    
    [KeyProcessor sharedInstance].event = [NSEvent eventWithCGEvent:event];
    
//    
//    for(id<KeyProcessorDelegate> delegate in [[KeyProcessor sharedInstance] observers])
//    {
//        if ([delegate respondsToSelector:@selector(KeyProcessorEvent:)]) {
//            NSEvent *theEvent = [NSEvent eventWithCGEvent:event];
//            [delegate KeyProcessorEvent:theEvent];
//        }
//    }
    
//    NSLog(@"%i, ALT:%@ CTRL:%@ CMD:%@",keyCode,
//          isKeyALT ? @"Yes" : @"No",
//          isKeyCTRL ? @"Yes" : @"No",
//          isKeyCMD ? @"Yes" : @"No"
//          );
//    NSEvent *theEvent = [NSEvent eventWithCGEvent:event];
//    NSEventModifierFlags flagsP2 = theEvent.modifierFlags;
//    NSLog(@"======%i",flagsP2);
    
//    if (keyCode == 18 && isKeyALT) {
//        [(AppDelegate*)[NSApplication sharedApplication].delegate callOSAScript];
//    }
    return event;
}

CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;
    
    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);
    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

CGKeyCode keyCodeForChar(const char c)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    CGKeyCode code;
    UniChar character = c;
    CFStringRef charStr = NULL;
    
    /* Generate table of keycodes and characters. */
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;
        
        /* Loop through every keycode (0 - 127) to find its current mapping. */
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
                //                CFRelease(string);
            }
        }
    }
    
    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
    
    /* Our values may be NULL (0), so we need to use this function. */
    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                       (const void **)&code)) {
        code = UINT16_MAX;
    }
    
    //    CFRelease(charStr);
    return code;
}

@end
