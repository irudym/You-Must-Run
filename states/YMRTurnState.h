//
//  YMRTurnState.h
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 04/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../FSM/FSMState.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMRTurnState : NSObject <FSMState>

+(id) createState;
+(id) createStateWithDirection: (CGVector)direction;

-(id<FSMState>) handleEvent: (YMREvent*) event withObject: (id<StateObject>)object;

/**
 * updateWithObject
 * @param object - object which the state controls
 * @return     null - in case no more action
 *              pointer to current state - in case state is in a process
 *              pointer to next state - in case object needs to perform next state after current
 */
-(id<FSMState>) updateWithObject: (id<StateObject>)object;

-(void) enterWithObject: (id<StateObject>) object;

@property CGVector direction;

@end

NS_ASSUME_NONNULL_END
