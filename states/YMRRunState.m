//
//  YMRRunState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 04/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRRunState.h"
#import "YMRStoppingState.h"
#import "YMRFallState.h"

@implementation YMRRunState

- (void)enterWithObject:(nonnull id<StateObject>)object { 
    NSLog(@"Enter to RUN state");
    [object run];
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object { 
    return self;
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object {
    if (event.type == EVENT_FALL) {
        return [YMRFallState createState];
    }
    if (event.type == EVENT_STOP) {
        return [YMRStoppingState createState];
    }
    return nil;
}

+ (nonnull id)createState { 
    YMRRunState* state = [[YMRRunState alloc] init];
    return state;
}

@end
