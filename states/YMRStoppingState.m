//
//  YMRStoppingState.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 04/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//
//  Intertial stoppoing
//

#import "YMRStoppingState.h"
#import "YMRStopState.h"

@implementation YMRStoppingState

+ (nonnull id)createState { 
    YMRStoppingState* state = [[YMRStoppingState alloc] init];
    return state;
}

- (void)enterWithObject:(nonnull id<StateObject>)object { 
    NSLog(@"Enter to STOPPING state");
    [object stopping];
}

- (nonnull id<FSMState>)updateWithObject:(nonnull id<StateObject>)object { 
    // check if all actions finished
    if(![object hasActions]) return [YMRStopState createState];
    return self;
}

- (nonnull id<FSMState>)handleEvent:(nonnull YMREvent *)event withObject:(nonnull id<StateObject>)object { 
    return nil;
}

@end
