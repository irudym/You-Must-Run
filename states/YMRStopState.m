//
//  YMRStopState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 18/10/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRStopState.h"
#import "YMRFallState.h"
#import "YMRRunState.h"
#import "YMRTurnState.h"
#import "YMRStepToState.h"
#import "YMRClimbState.h"
#import "YMRLockState.h"
#import "YMRJumpState.h"

@implementation YMRStopState

+ (nonnull id)createState { 
    YMRStopState* state = [[YMRStopState alloc] init];
    return state;
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object {
    
    if (event.type == EVENT_RUN) {
        // need to run!
        return [YMRRunState createState];
    }
    if (event.type == EVENT_FALL) {
        //the object must fall
        return [YMRFallState createState];
    }
    if (event.type == EVENT_TURN) {
        return [YMRTurnState createStateWithDirection:event.direction];
    }
    if (event.type == EVENT_STEPTO) {
        return [YMRStepToState createStateWithPoint:event.point];
    }
    if (event.type == EVENT_CLIMB) {
        return [YMRClimbState createState];
    }
    if (event.type == EVENT_LOCK) {
        return [YMRLockState createState];
    }
    if (event.type == EVENT_JUMP) {
        return [YMRJumpState createState];
    }
    return nil;
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object {
    return self;
}

- (void)enterWithObject:(nonnull id<StateObject>)object { 
    // YMRPhysicsObject* obj = (YMRPhysicsObject*)object;
    // [obj stopAnimation]
    NSLog(@"Enter to STOP state");
    [object stop];
}

@end
