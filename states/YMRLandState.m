//
//  YMRLandState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 04/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRLandState.h"
#import "YMRStopState.h"

@implementation YMRLandState

- (void)enterWithObject:(nonnull id<StateObject>)object {
    NSLog(@"Enter to LAND state with point: %f, %f", _point.x, _point.y);
    [object setPosition:_point];
    [object land];
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object { 
    return nil;
}

+ (nonnull id)createState { 
    YMRLandState* state = [[YMRLandState alloc] init];
    return state;
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object {
    //check if animation is finished, and after that switch to STAND state
    if (![object hasActions]) return [YMRStopState createState];
    return self;
}

+ (nonnull id)createStateWithPoint:(CGPoint)point { 
    YMRLandState* state = [YMRLandState createState];
    if(state) {
        [state setPoint:point];
    }
    return state;
}

@end
