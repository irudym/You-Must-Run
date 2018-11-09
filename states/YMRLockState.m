//
//  YMRLockState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 07/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRLockState.h"
#import "YMRFallState.h"
#import "YMRStopState.h"

@implementation YMRLockState

+ (nonnull id)createState {
    YMRLockState* state = [[YMRLockState alloc] init];
    return state;
}

- (void)enterWithObject:(nonnull id<StateObject>)object { 
    // doing nothing as we just skeep all events except fall and unlock
    NSLog(@"Enter to LOCK state");
}

/**
 *  Response only to FALL and UNLOCK events
 **/
- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object {
    if (event.type == EVENT_FALL) {
        //the object must fall
        return [YMRFallState createState];
    }
    if (event.type == EVENT_UNLOCK) {
        return [YMRStopState createState];
    }
    return nil;
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object { 
    return self;
}

@end
