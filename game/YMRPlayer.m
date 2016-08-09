//
//  YMRPlayer.m
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRPlayer.h"

@implementation YMRPlayer

-(id) init {
    self = [super initWithName:@"player" AndPosition:CGPointMake(0,0)];
    if(!self) return nil;
    
    [self setZPosition:1000];
    
    return self;
}


/**
 * move the character by X points d
 **/
-(void) runByX: (float)x {
    NSLog(@"Player Run by X: %f", x);
    [self.taskQueue push: [YMRAction performSelector:@selector(beforeActionRun) onTarget:self withTag: RUN_ACTION]];
    [self.taskQueue push: [YMRAction moveBy:CGVectorMake(x, 0) duration: self.moveSpeed * fabs(x)/80 withTag: RUN_ACTION]];
}

-(void) run:(CGVector)direct {
    
    //we cannot run while falling
    if(self.currentAction  == FALL_ACTION) return;
    
    NSLog(@"Player Run direction: %f,%f where current direction: %f,%f", direct.dx, direct.dy, self.currentDirection.dx, self.currentDirection.dy);
    if(direct.dx != self.currentDirection.dx) {
        //need to turn the runner
        NSLog(@"Turn the runner to %f, %f", direct.dx, direct.dy);
        [self turn: direct];
    }
    
    //add task to task Queue
    if(direct.dx < 0 /*LEFT*/)
        [self runByX: -1000]; else [self runByX: 1000];
    
    NSLog(@"Player Run:: Curent action: %d", self.currentAction);
    if(self.currentAction == NONE) {
        [self runNextTask];
    }
}

@end
