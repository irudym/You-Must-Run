//
//  YMRControlLayer.m
//  You Must Run
//
//  Created by Igor on 14/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRControlLayer.h"
#import "YMREvent.h"
#include <math.h>
#import "YMRRunner.h"


@implementation YMRControlLayer

@synthesize mainRunner;

-(id) initWithRunner: (YMRRunner*) runner andMap: (YMRTileMap*) map {
    self = [super init];
    if(!self) return nil;
    
    mainRunner = runner;
    _mainMap = map;
    
    //enable touch handling
    self.userInteractionEnabled = TRUE;
    
    YMRControlButton *rightButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    [rightButton setPosition:CGPointMake(520,90)];
    [rightButton setButtonDownTarget:@selector(rightButtonDown) fromObject:self];
    [rightButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild: rightButton];
    
    YMRControlButton *leftButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    leftButton.xScale = -1;
    [leftButton setPosition:CGPointMake(430,90)];
    [leftButton setButtonDownTarget:@selector(leftButtonDown) fromObject:self];
    [leftButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild:leftButton];
    
    YMRControlButton* upButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    [upButton setPosition:CGPointMake(475,120)];
    upButton.zRotation = M_PI/2;
    [upButton setButtonDownTarget: @selector(upButtonDown) fromObject: self];
    [upButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild:upButton];
    
    YMRControlButton *downButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    [downButton setPosition:CGPointMake(475, 75)];
    downButton.zRotation = -M_PI/2;
    [downButton setButtonDownTarget:@selector(downButtonDown) fromObject:self];
    [downButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild:downButton];
    
    YMRControlButton *actionButton = [YMRControlButton controlButtonWithImage:@"action-retina@2x.png"];
    [actionButton setPosition:CGPointMake(25,75)];
    [actionButton setButtonDownTarget:@selector(actionButtonDown) fromObject:self];
    [actionButton setButtonUpTarget:@selector(actionButtonUp) fromObject:self];
    [self addChild:actionButton];
    
    [self setZPosition:2000];
    
    return self;
}


-(void) buttonUp {
    [mainRunner handleEvent:[YMREvent createEventByType:EVENT_STOP]];
}

-(void) leftButtonDown {
    // check if Runner should turn to right direction: Left
    if(![YMRRunner isDirectionLeft: [mainRunner currentDirection]])
        [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_TURN andDirection:LEFT]];
    else
        [mainRunner handleEvent:[YMREvent createEventByType:EVENT_RUN]];
}

-(void) rightButtonDown {
    // check if Runner should turn to right direction: Right
    if(![YMRRunner isDirectionRight: [mainRunner currentDirection]])
        [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_TURN andDirection: RIGHT]];
    else
        [mainRunner handleEvent:[YMREvent createEventByType:EVENT_RUN]];
}

-(BOOL)compare:(CGFloat)param1 and:(CGFloat)param2 withDelta: (CGFloat)delta {
    CGFloat diff = param1 - param2;
    if(fabs(diff) <= delta) return YES;
    return NO;
}

-(void) upButtonDown {
    //check if ladder is near and climb up
    //TODO: Need to get rid of that adjustment!
    CGPoint check_pos = CGPointMake([mainRunner position].x, [mainRunner position].y);
    int ladder_gid = [_mainMap isLadderAt:check_pos];
    NSLog(@"Check the tile_gid (is_ladder): %d", ladder_gid);
    //if(ladder_gid >= 0 && ladder_gid != 12)
    SKNode<YMRMapObject>* obj = [_mainMap getObjectAtPosition:[mainRunner position]];
    if(ladder_gid!=-1)
    {
        CGFloat ladderX = [_mainMap getTileScreenPositionAtPoint:check_pos].x + [_mainMap getTileWidthAtPoint: check_pos]/2;
        // NSLog(@"Check the ladder\n\tPlayerX: %f\n\tLadderX: %f", mainRunner.position.x, ladderX);
        //NSLog(@"Compare runner and ladder position %f <=> %f", mainRunner.position.x, ladderX);
        if(![self compare:mainRunner.position.x and:ladderX withDelta:0.01f]) {
            //stepTo the ladder position
            //compare direction
            if(ladderX - mainRunner.position.x < 0 && [YMRRunner isDirectionRight:mainRunner.currentDirection]) {
                [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_TURN andDirection:LEFT]];
            } else
            if(ladderX - mainRunner.position.x > 0 && [YMRRunner isDirectionLeft:mainRunner.currentDirection])
            {
                [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_TURN andDirection:RIGHT]];
            } else {
                //NSLog(@"===> Need to STEP.TO: %f", ladderX);
                [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_STEPTO andPoint:CGPointMake(ladderX, mainRunner.position.y)]];
            }
        } else {
            // set direction UP
            //NSLog(@"Check if Runner looks UP");
            if(![YMRRunner isDirectionUp:[mainRunner currentDirection]]) {
                //NSLog(@"===> Turn it UP");
                [mainRunner handleEvent:[YMREvent createEventWithType: EVENT_TURN andDirection: UP]];
                
                //and fix player position as SpriteKit is not so precise (see compare with Delta)
                [mainRunner setPosition:CGPointMake(ladderX, [mainRunner position].y)];
             } else {
                // and climb!
                [mainRunner handleEvent:[YMREvent createEventByType:EVENT_CLIMB]];
            }
        }
    } else //some other objects which can be activated
    if(obj) {
        NSLog(@"activate object: %@", [obj name]);
        [obj activateWithObject:mainRunner];
    } else
        //otherwise just jump (in case there is ground under the feet!)
        [mainRunner handleEvent:[YMREvent createEventByType:EVENT_JUMP]];
}

-(void) downButtonDown {
    
    //check if ladder is near and climb up
    //TODO: Need to get rid of that adjustment!
    CGPoint check_pos = CGPointMake([mainRunner position].x, [mainRunner position].y);
    int ladder_gid = [_mainMap isLadderAt:check_pos];
    NSLog(@"Check the tile_gid: %d", ladder_gid);
    if(ladder_gid >= 0) {
        CGFloat ladderX = [_mainMap getTileScreenPositionAtPoint:check_pos].x + [_mainMap getTileWidthAtPoint: check_pos]/2;
        
        if(![self compare:mainRunner.position.x and:ladderX withDelta:0.01f]) {
            //stepTo the ladder position
            //compare direction
            if(ladderX - mainRunner.position.x < 0 && [YMRRunner isDirectionRight:mainRunner.currentDirection]) {
                [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_TURN andDirection:LEFT]];
            } else
                if(ladderX - mainRunner.position.x > 0 && [YMRRunner isDirectionLeft:mainRunner.currentDirection])
                {
                    [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_TURN andDirection:RIGHT]];
                } else {
                    //NSLog(@"===> Need to STEP.TO: %f", ladderX);
                    [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_STEPTO andPoint:CGPointMake(ladderX, mainRunner.position.y)]];
                }
        } else {
            //[mainRunner climb:DOWN withX: [_mainMap getTileScreenPositionAtPoint:check_pos].x + [_mainMap getTileWidthAtPoint: check_pos]/2];
            if(![YMRRunner isDirectionDown:[mainRunner currentDirection]]) {
                [mainRunner handleEvent:[YMREvent createEventWithType:EVENT_TURN andDirection:DOWN]];
            } else {
                [mainRunner handleEvent:[YMREvent createEventByType:EVENT_CLIMB]];
            }
        }
    } //else
        //otherwise duck!
}

-(void) actionButtonDown {
    //[mainRunner turn:LEFT];
    //[mainRunner nextAction];
}

-(void) actionButtonUp {
    
}

- (void)update:(CFTimeInterval)currentTime { 
    for(YMRControlButton* element in self.children) {
        [element update: currentTime];
    }
}

@end
