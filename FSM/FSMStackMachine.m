//
//  FSMStackMachine.m
//  tappa
//
//  Created by Igor on 07/11/2017.
//  Copyright © 2017 Igor Rudym. All rights reserved.
//

#import "FSMStackMachine.h"
#import "../utils/Stack.h"

@implementation FSMStackMachine
{
    Stack* stateMachine;
}

@synthesize object;

-(id) init {
    self = [super init];
    if(self == nil) return nil;
    
    stateMachine = [[Stack alloc] init];

    return self;
}

-(id) initWithObject:(id<StateObject>)object {
    self = [self init];
    if(self == nil) return nil;
    
    [self setObject:object];
    
    return self;
}

+(id) createWithObject:(id<StateObject>)object {
    FSMStackMachine* machine = [[FSMStackMachine alloc] initWithObject:object];
    return machine;
}

-(void) update {
    id<FSMState> state = [self getCurrentState];
    
    if (state != nil) {
        id<FSMState> nextState = [state updateWithObject:object];
        if (nextState == nil) {
            //remove the state from the Machine Stack
            [self popState];
            
            //activate previous state
            id<FSMState> newState = [self getCurrentState];
            if (newState != nil) [newState enterWithObject:object];
        } else
            if (state != nextState) {
                //remove current state
                [self popState];
                
                //push and activate the next state which was provided by the current state
                [self pushState:nextState];
            }
    }
}

-(void) handleEvent:(YMREvent *)event {
    id<FSMState> state = [self getCurrentState];
    
    if (state != nil) {
        id<FSMState> newState = [state handleEvent:event withObject:object];
        
        if (newState != nil) {
            [self pushState:newState];
        }
    }
}


#pragma mark Stack operations

-(id<FSMState>) getCurrentState {
    return [stateMachine empty] ? nil : [stateMachine peekObject];
}

-(void) pushState:(id<FSMState>)state {
    if([self getCurrentState] != state && state != nil) {
        [stateMachine pushObject:state];
        [state enterWithObject:object];
    }
}

-(id<FSMState>) popState {
    return (id<FSMState>)[stateMachine popObject];
}


@end
