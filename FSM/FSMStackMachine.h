//
//  FSMStackMachine.h
//  tappa
//
//  Created by Igor on 07/11/2017.
//  Copyright © 2017 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMREvent.h"
#import "FSMState.h"
#import "StateObject.h"

@interface FSMStackMachine : NSObject

@property id object;

-(id) initWithObject: (id<StateObject>)object;

+(id) createWithObject: (id<StateObject>)object;

-(void) update;
-(void) handleEvent:(YMREvent*)event;

-(void) pushState:(id<FSMState>)state;
-(id<FSMState>) popState;
-(id<FSMState>) getCurrentState;

@end
