//
//  YMRTurnState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 04/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRTurnState.h"
#import "YMRStopState.h"

@implementation YMRTurnState

@synthesize direction;

+ (nonnull id)createState { 
    YMRTurnState* state = [[YMRTurnState alloc] init];
    return state;
}

- (void)enterWithObject:(nonnull id<StateObject>)object {
    NSLog(@"Enter to TURN state with Direction: (%f, %f)", direction.dx, direction.dy);
    [object turnTo: direction];
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object {
    if (![object hasActions]) return [YMRStopState createState];
    return self;
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object { 
    return nil;
}

+ (nonnull id)createStateWithDirection:(CGVector)direction { 
    YMRTurnState *state = [YMRTurnState createState];
    if(state) {
        [state setDirection:direction];
    }
    return state;
}

@end
