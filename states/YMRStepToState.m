//
//  YMRStepToState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 06/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRStepToState.h"
#import "YMRStopState.h"

@implementation YMRStepToState

@synthesize point;

+ (nonnull id)createStateWithPoint:(CGPoint)point {
    YMRStepToState* state = [[YMRStepToState alloc] init];
    [state setPoint:point];
    return state;
}

- (void)enterWithObject:(nonnull id<StateObject>)object {
    NSLog(@"Enter to STEP.TO state");
    [object stepTo:point];
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object {
    if(![object hasActions]) return [YMRStopState createState];
    return self;
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object {
    if (event.type == EVENT_FALL) {
        //the object must fall but before it needs to Stop
        return [YMRStopState createState];
    }
    return nil;
}

@end
