//
//  YMRJumpState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 14/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMRJumpState.h"
#import "YMRFallState.h"

@implementation YMRJumpState

+ (nonnull id)createState { 
    YMRJumpState* state = [[YMRJumpState alloc] init];
    return state;
}

- (void)enterWithObject:(nonnull id<StateObject>)object { 
    NSLog(@"Enter to JUMP state");
    [object jump];
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object {
     if(![object hasActions]) return [YMRFallState createState];
    return self;
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object { 
    return nil;
}

@end
