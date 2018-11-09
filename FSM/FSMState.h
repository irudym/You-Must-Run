//
//  FSMState.h
//  tappa
//
//  Created by Igor on 07/11/2017.
//  Copyright © 2017 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMREvent.h"
#import "StateObject.h"

@protocol FSMState <NSObject>

-(id<FSMState>) handleEvent: (YMREvent*)event withObject: (id<StateObject>)object;

/**
 * updateWithObject
 * @param object - object which the state controls
 * @return     null - in case no more action
 *              pointer to current state - in case state is in a process
 *              pointer to next state - in case object needs to perform next state after current
 */
-(id<FSMState>) updateWithObject: (id<StateObject>)object;

-(void) enterWithObject: (id<StateObject>) object;
@end
