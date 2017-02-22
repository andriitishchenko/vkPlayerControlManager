//
//  keyProcessor.h
//  vkKeyBind
//
//  Created by andrux on 2/20/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSEvent;
//@protocol KeyProcessorDelegate;

@interface KeyProcessor : NSObject
    +(KeyProcessor *)sharedInstance;
    -(BOOL)start;
//    -(void)addEventListener:(id<KeyProcessorDelegate>)object;
    @property(nonatomic) BOOL state;
    //@property(assign,nonatomic) id<KeyProcessorDelegate>delegate;
    @property(strong,nonatomic) NSEvent* event;
@end

//
//@protocol KeyProcessorDelegate <NSObject>
//    @optional
//        -(void)KeyProcessorEvent:(NSEvent*)event;
//@end
