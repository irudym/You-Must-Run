//
//  YMRAction.h
//  You Must Run
//
//  Created by Igor on 07/08/16.
//  Copyright © 2016 Igor Rudym. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

/*
typedef enum {
    NONE, IDLE,  RUN_ACTION = 100, TURN_ACTION, STEP_ACTION, STOP_ACTION, MOVE_ACTION, JUMP_ACTION, FALL_ACTION, CLIMB_ACTION, LANDING_ACTION, STEPTO_ACTION, DUCK_ACTION, LOCKED_ACTION
} ActionTags;
*/

@interface YMRAction : NSObject

@property int tag; //action identificator
@property SKAction* _Nonnull action;

//TODO: this could be changed to hash?
@property float param1;
@property float param2;

+(nullable id) performSelector: (nonnull SEL) sel onTarget: (nonnull id) target withTag: (int) tag;
+(nullable id) performSelector: (nonnull SEL) sel onTarget: (nonnull id) target withTag: (int) tag andParam1: (float)p1 andParam2: (float)p2;
+(nonnull id) moveToX: (CGFloat) x duration: (NSTimeInterval) duration withTag: (int) tag;
+(nonnull id) moveBy: (CGVector) vector duration: (NSTimeInterval) duration withTag: (int) tag;
+(nonnull id) animateWithTextures:  (nonnull NSArray<SKTexture*> *) textures timePerFrame: (NSTimeInterval) duration resize: (BOOL) res restore: (BOOL) rest withTag: (int) tag;
+(nonnull id) moveToY: (CGFloat) y duration: (NSTimeInterval) duration withTag: (int) tag;


-(YMRAction*) reversedAction;

@end
