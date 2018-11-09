//
//  Stack.m
//  tappa
//
//  Created by Igor on 07/11/2017.
//  Copyright © 2017 Igor Rudym. All rights reserved.
//
#if ! __has_feature(objc_arc)
#error This file requires ARC to be enabled. Either enable ARC for the entire project or use -fobjc-arc flag.
#endif

#import "Stack.h"

@interface Stack ()
@property (nonatomic, strong) NSMutableArray *objects;
@end

@implementation Stack

@synthesize objects = _objects;

-(id)init {
    if((self = [self initWithArray:nil])) {}
    return self;
}

-(id)initWithArray:(NSArray *)array {
    if((self = [super init])) {
        _objects = [[NSMutableArray alloc] initWithArray:array];
    }
    return self;
}

-(NSUInteger)count {
    return _objects.count;
}

-(BOOL)empty {
    if([self count] == 0) return TRUE;
    return FALSE;
}

#pragma mark Stack functions

-(NSUInteger) pushObject:(id)object {
    if(object) {
        [_objects addObject:object];
    }
    return [self count];
}

-(NSUInteger) pushObjects:(NSArray *)objects {
    for(id object in objects) {
        [self pushObject:object];
    }
    return [self count];
}

-(id)popObject {
    if([self count] > 0 ) {
        id object = [_objects objectAtIndex:_objects.count - 1];
        [_objects removeLastObject];
        return object;
    }
    return nil;
}

-(id)peekObject {
    if([self count] > 0 ) {
        id object = [_objects objectAtIndex:(_objects.count - 1)];
        return object;
    }
    return nil;
}

#pragma mark - NSFastEnumeration methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [_objects countByEnumeratingWithState:state objects:buffer count:len];
}

@end
