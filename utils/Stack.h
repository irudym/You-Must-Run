//
//  Stack.h
//  tappa
//
//  Created by Igor on 07/11/2017.
//  Copyright © 2017 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject<NSFastEnumeration>

@property (nonatomic, assign, readonly) NSUInteger count;

-(id)initWithArray:(NSArray*) array;

//return amount of elemenst after adding an object/objects
-(NSUInteger)pushObject:(id)object;
-(NSUInteger)pushObjects:(NSArray*)objects;

-(id)popObject;
-(id)peekObject;

-(BOOL)empty;

@end
