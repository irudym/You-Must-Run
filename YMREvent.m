//
//  YMREvent.m
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 18/10/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#import "YMREvent.h"

@implementation YMREvent

@synthesize type;
@synthesize point;
@synthesize direction;

-(id) initWithType:(EventTypes)type {
    self = [super init];
    if (self!=nil) {
        [self setType:type];
    }
    return self;
}

+(id) createEventByType:(EventTypes)type {
    YMREvent *event  = [[YMREvent alloc] initWithType:type];
    return event;
}

+ (nonnull id)createEventWithType:(EventTypes)type andPoint:(CGPoint)point { 
    YMREvent *event = [YMREvent createEventByType:type];
    if(event) {
        [event setPoint:point];
    }
    return event;
}

+ (nonnull id)createEventWithType:(EventTypes)type andDirection:(CGVector)direction { 
    YMREvent *event = [YMREvent createEventByType:type];
    if(event) {
        [event setDirection:direction];
    }
    return event;
}

@end
