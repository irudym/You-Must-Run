//
//  YMRFallState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 04/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRFallState.h"
#import "YMRLandState.h"

@implementation YMRFallState

+ (nonnull id)createState { 
    YMRFallState* state = [[YMRFallState alloc] init];
    return state;
}

- (void)enterWithObject:(nonnull id<StateObject>)object {
    NSLog(@"Enter to FALL state");
    [object fall];
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object { 
    return self;
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object { 
    if (event.type == EVENT_LAND) {
        // object need to land
        return [YMRLandState createStateWithPoint:event.point];
    };
    return nil;
}

@end
