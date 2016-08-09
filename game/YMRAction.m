//
//  YMRAction.m
//  You Must Run
//
//  Created by Igor on 07/08/16.
//  Copyright © 2016 Igor Rudym. All rights reserved.
//

#import "YMRAction.h"

@implementation YMRAction

@synthesize tag;

@synthesize param1, param2;
@synthesize action;

+(nullable id) performSelector:(SEL)sel onTarget:(id)target withTag:(int)tag {
    YMRAction* ymrAction = [[YMRAction alloc] init];
    
    [ymrAction setTag: tag];
    [ymrAction setAction: [SKAction performSelector:sel onTarget: target]];
    
    return ymrAction;
}

+(nullable id) performSelector: (nonnull SEL) sel onTarget: (nonnull id) target withTag: (int) tag andParam1: (float)p1 andParam2: (float)p2 {
    YMRAction* action = [YMRAction performSelector:sel onTarget:target withTag:tag];
    [action setParam1:p1];
    [action setParam2:p2];
    return action;
}


+(nonnull id) moveToX: (CGFloat) x duration: (NSTimeInterval) duration withTag: (int) tag {
    YMRAction* ymrAction = [[YMRAction alloc] init];
    
    [ymrAction setTag: tag];
    [ymrAction setAction: [SKAction moveToX:x duration:duration]];
    
    return ymrAction;
}

+(nonnull id) moveBy: (CGVector) vector duration: (NSTimeInterval) duration withTag: (int) tag {
    YMRAction* ymrAction = [[YMRAction alloc] init];
    
    [ymrAction setTag: tag];
    [ymrAction setAction: [SKAction moveBy:vector duration:duration]];
    
    return ymrAction;
}

+(nonnull id) moveToY: (CGFloat) y duration: (NSTimeInterval) duration withTag: (int) tag {
    YMRAction* ymrAction = [[YMRAction alloc] init];
    
    [ymrAction setTag: tag];
    [ymrAction setAction: [SKAction moveToY:y duration:duration]];
    
    return ymrAction;
}

+(nonnull id) animateWithTextures:  (nonnull NSArray<SKTexture*> *) textures timePerFrame: (NSTimeInterval) duration resize: (BOOL) res restore: (BOOL) rest withTag: (int) tag {
    YMRAction* ymrAction = [[YMRAction alloc] init];
    
    [ymrAction setTag: tag];
    [ymrAction setAction:[SKAction animateWithTextures:textures timePerFrame:duration resize: res restore: rest]];
    return  ymrAction;
}

-(YMRAction*) reversedAction {
    YMRAction* ymrAction = [[YMRAction alloc] init];
    ymrAction.tag = self.tag;
    ymrAction.param1 = self.param1;
    ymrAction.param2 = self.param2;
    
    [ymrAction setAction: [self.action reversedAction]];
    
    return ymrAction;
}



@end
