//
//  YMRClimbState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 06/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRClimbState.h"
#import "YMRStopState.h"

@implementation YMRClimbState

+ (nonnull id)createState { 
    YMRClimbState* state = [[YMRClimbState alloc] init];
    return state;
}

- (void)enterWithObject:(nonnull id<StateObject>)object { 
    NSLog(@"Enter to CLIMB state");
    [object climb];
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object {
    if (event.type == EVENT_STOP) {
        return [YMRStopState createState];
    }
    if (event.type == EVENT_FALL) {
        return [YMRStopState createState];
    }
    /*
     if (event.type == EVENT_TURNDOWN) {
        return [YMRTurnDownState createState];
     }
     */
    return nil;
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object { 
    return self;
}

@end
