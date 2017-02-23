//
//  AppDelegate.m
//  vkKeyBind
//
//  Created by andrux on 2/15/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "AppDelegate.h"
#import "KeyProcessor.h"

@interface AppDelegate ()
    @property (strong, nonatomic) NSStatusItem *statusItem;
    @property (nonatomic) ProcessSerialNumber psnSafari;
@end

@implementation AppDelegate
static void *KeyProcessorEventContext = &KeyProcessorEventContext;

const static NSString* safari_id = @"com.apple.Safari";
static NSDictionary* map;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    map = @{//F7:ALT modif
            @98:@8913184,
            @100:@8913184,
            @101:@8913184,
            @109:@8913184,
            @103:@8913184
            };

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *icon = [NSImage imageNamed: @"icon_menu"];
    icon.template = YES;
    
    _statusItem.button.image = icon;
    _statusItem.toolTip = @"ctrl+click to QUIT\n alt+F7 - prew\n alt+F8 - play/stop, 3- clicks\n alt+F9 - next, 2-clicks";
    [_statusItem setAction:@selector(itemClicked:)];
    
//    if (AXIsProcessTrustedWithOptions != NULL) {
//        // 10.9 and later
//        const void * keys[] = { kAXTrustedCheckOptionPrompt };
//        const void * values[] = { kCFBooleanTrue };
//        
//        CFDictionaryRef options = CFDictionaryCreate(
//                                                     kCFAllocatorDefault,
//                                                     keys,
//                                                     values,
//                                                     sizeof(keys) / sizeof(*keys),
//                                                     &kCFCopyStringDictionaryKeyCallBacks,
//                                                     &kCFTypeDictionaryValueCallBacks);
//        
//         AXIsProcessTrustedWithOptions(options);
//    }
    
    
    if (![[KeyProcessor sharedInstance] start]) {
        NSString *urlString = @"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility";
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
        [[NSApplication sharedApplication] terminate:self];
    }
    else{
        [[KeyProcessor sharedInstance] addObserver:self
                  forKeyPath:@"event"
                     options:(NSKeyValueObservingOptionNew |
                              NSKeyValueObservingOptionOld)
                     context:KeyProcessorEventContext];
        
        
        NSLog(@"-[AppDelegate testNSWorkspace:]");
        NSNotificationCenter *  center;
        // Get the custom notification center.
        center = [[NSWorkspace sharedWorkspace] notificationCenter];
        // Install the notifications.
        [center addObserver:self
                   selector:@selector(appLaunched:)
                       name:NSWorkspaceDidLaunchApplicationNotification
                     object:nil
         ];
        [center addObserver:self
                   selector:@selector(appTerminated:)
                       name:NSWorkspaceDidTerminateApplicationNotification 
                     object:nil
         ];

        
        
        //get safar PID and send messages
        NSArray*apps = [NSRunningApplication runningApplicationsWithBundleIdentifier: safari_id];
        NSRunningApplication*app = [apps firstObject];

        if (app && GetProcessForPID(app.processIdentifier, &_psnSafari) != noErr )
        {
            NSLog(@"Failed to get process serial number for %@!", app.localizedName);
        }
//        
//        NSDictionary * info = CFBridgingRelease(ProcessInformationCopyDictionary(&_psnSafari, kProcessDictionaryIncludeAllInformationMask));
//        if ( info == nil )
//        {
//            NSLog(@"Failed to get process information for %@!", app.localizedName);
//        }
//
    }
}

- (void)appLaunched:(NSNotification *)note
{
    NSDictionary* dictionary = [note userInfo];
//    NSLog(@"launched %@\n", [dictionary objectForKey:@"NSApplicationName"]);
    if ([[dictionary objectForKey:@"NSApplicationBundleIdentifier"] isEqual: safari_id]) {
        NSNumber* psnLow = [dictionary valueForKey: @"NSApplicationProcessSerialNumberLow"];
        NSNumber* psnHigh = [dictionary valueForKey: @"NSApplicationProcessSerialNumberHigh"];
        _psnSafari.highLongOfPSN = [psnHigh intValue];
        _psnSafari.lowLongOfPSN = [psnLow intValue];
    }
}

- (void)appTerminated:(NSNotification *)note
{
    NSDictionary* dictionary = [note userInfo];
//    NSLog(@"terminated %@\n", [dictionary objectForKey:@"NSApplicationName"]);
    if ([[dictionary objectForKey:@"NSApplicationBundleIdentifier"] isEqual: safari_id]) {
        _psnSafari.highLongOfPSN = 0;
        _psnSafari.lowLongOfPSN = 0;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == KeyProcessorEventContext) {
        NSEvent * newValue = [change objectForKey:NSKeyValueChangeNewKey];
        [self onEvent:newValue];
        
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

-(void)onEvent:(NSEvent*)event{
    
    if([ [map allKeys] containsObject:@(event.keyCode)]){
        NSEventModifierFlags flagsP = event.modifierFlags;
        NSNumber*mod = [map objectForKey: @(event.keyCode)];
        if (mod.integerValue == (NSInteger)flagsP) {
            NSArray*apps = [NSRunningApplication runningApplicationsWithBundleIdentifier: safari_id];
            NSRunningApplication*app = [apps firstObject];
            if (app && app.active == NO) {
                [self sendKeyCode:event.keyCode];
            }
        }
    }
}



-(void)sendALTDown:(BOOL)isDown
{
    CGEventRef key = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)65535, isDown==YES);
    CGEventPostToPSN (&_psnSafari, key);
    CFRelease(key);
}


-(void)sendKeyCode:(CGKeyCode)keyKode
{
    [self sendALTDown:YES];
    CGEventRef keyup, keydown;
    keydown = CGEventCreateKeyboardEvent (NULL, keyKode, true);
    keyup = CGEventCreateKeyboardEvent (NULL, keyKode, false);
    CGEventPostToPSN (&_psnSafari, keydown);
    CGEventPostToPSN (&_psnSafari, keyup);
    CFRelease(keydown);
    CFRelease(keyup);
    [self sendALTDown:NO];
}

- (void)itemClicked:(id)sender {
    //Look for control click, close app if so
    NSEvent *event = [NSApp currentEvent];
    if([event modifierFlags] & NSEventModifierFlagControl) {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }
    if (event.clickCount == 3){
        [self sendKeyCode:100];
    }
    else if (event.clickCount == 2){
        [self sendKeyCode:101];
    }
    
//    [[NSApplication sharedApplication].keyWindow makeKeyAndOrderFront:nil];
//    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
//    [[NSApplication sharedApplication].mainWindow makeKeyAndOrderFront:self];
}


-(void)callOSAScript:(NSString*)cmd{
    if (!cmd) {
        NSLog(@"CMD == NIL!");
        return;
    }
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
                                  cmd];
    
    returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
    if (returnDescriptor != NULL)
    {
        // successful execution
        if (kAENullEvent != [returnDescriptor descriptorType])
        {
            // script returned an AppleScript result
            if (cAEList == [returnDescriptor descriptorType])
            {
                // result is a list of other descriptors
            }
            else
            {
                // coerce the result to the appropriate ObjC type
            }
        } 
    }
    else
    {
        NSLog(@"%@", @"Some error!");
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag) {
        return NO;
    }
    else
    {
        //[YourWindow makeKeyAndOrderFront:self];// Window that you want open while click on dock app icon
        return YES;
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return NSTerminateNow;
}

- (void)dealloc {
    [[KeyProcessor sharedInstance] removeObserver:self
                                       forKeyPath:@"event"
                                          context:KeyProcessorEventContext];
}


@end
