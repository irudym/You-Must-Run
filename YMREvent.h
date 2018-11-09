//
//  YMREvent.h
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 18/10/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS || TARGET_OS_TV
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    EVENT_RUN,
    EVENT_STOP,
    EVENT_JUMP,
    EVENT_TURN,
    EVENT_DUCK,
    EVENT_FALL,
    EVENT_LAND,
    EVENT_STEPTO,
    EVENT_CLIMB,
    EVENT_LOCK,
    EVENT_UNLOCK
} EventTypes;

@interface YMREvent : NSObject

@property EventTypes type;
@property CGPoint point;
@property CGVector direction;

-(id) initWithType: (EventTypes)type;
+(id) createEventByType: (EventTypes)type;
+(id) createEventWithType: (EventTypes)type andPoint: (CGPoint)point;
+(id) createEventWithType: (EventTypes)type andDirection: (CGVector)direction;

@end

NS_ASSUME_NONNULL_END
