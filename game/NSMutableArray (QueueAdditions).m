//
//  NSMutableArray (QueueAdditions).m
//  You Must Run
//
//  Created by Igor on 19/12/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "NSMutableArray (QueueAdditions).h"

@implementation NSMutableArray (QueueAdditions)

- (id)pop
{
    // nil if [self count] == 0
    id lastObject = [self lastObject];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}

- (void)push:(id)obj
{
    [self addObject: obj];
}


@end
